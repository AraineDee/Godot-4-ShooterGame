extends CharacterBody3D

@onready var bodyRay = $Head/Camera3d/bodyRay as RayCast3D
@onready var hitboxRay = $Head/Camera3d/hitboxRay as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@onready var Equipment_Manager = $EquipmentManager

@export var gunshot_emitter : AudioStreamPlayer3D
@export var health : Node

var mouseSensitivity = 1000
var mouse_relative_x = 0
var mouse_relative_y = 0
@export var speed := 8.0
const JUMP_VELOCITY = 4.5

enum INPUTMOVEMENTSTATE {IDLE, RUNNING, WALKING, JUMPING}
enum CONTEXTMOVEMENTSTATE {GROUND, AIR, WALL, GRAPPLE}

var last_state = 0
var movement_state = INPUTMOVEMENTSTATE.IDLE

var is_crouched := false
var is_sliding := false
var input_dir : Vector2

var grappleInst
var grapple_length : float
var is_grappled := false

var ziplineInst
var on_zipline := false
var in_range_of_zipline := false

var turretInst
var on_turret := false
var in_range_of_turret := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var authority : int

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(authority)
	if str(authority) == str(multiplayer.get_unique_id()):
		Cam.current = true
	#Captures mouse and stops rgun from hitting yourself
	bodyRay.add_exception(self)
	hitboxRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func is_local_player():
	return $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func _physics_process(delta):
	if not is_local_player():
		return
	_process_input(delta)
	_process_movement(delta)


func _process_input(delta):
	input_dir = Input.get_vector("moveLeft", "moveRight", "moveFoward", "moveBack")
	if(input_dir.is_equal_approx(Vector2.ZERO)):
		movement_state = INPUTMOVEMENTSTATE.IDLE
	else:
		movement_state = INPUTMOVEMENTSTATE.RUNNING
	
	if(Input.is_action_just_pressed("Crouch")):
		_crouch()
	if(Input.is_action_just_released("Crouch")):
		_uncrouch()
	if(Input.is_action_just_pressed("Jump")):
		_jump()
	if(Input.is_action_just_pressed("Respawn")):
		respawn()

func _input(event):
	if $MultiplayerSynchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	if event is InputEventKey:
		if(event.is_action_pressed("Pause")): #if key is "escape"
			$Head/Camera3d/PauseMenu.visible = !$Head/Camera3d/PauseMenu.visible
			_swap_mouse_mode()
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not on_turret:
			rotation.y -= event.relative.x / mouseSensitivity
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensitivity
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func _swap_mouse_mode():
	if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


var friction_mod = 1
func _process_movement(delta):
	if velocity.length() > 0.1 and is_on_floor():
		$MovementAudioEmitter.volume_db = 0
	else: 
		$MovementAudioEmitter.volume_db = -100
	
	if on_turret:
		_handle_turret_movement(delta)
	elif(is_on_floor()):
		_handle_ground_movement(delta)
	elif(is_on_wall()):
		_handle_wall_movement(delta)
	else:
		_handle_air_movement(delta)
	
	if(on_zipline):
		_handle_zipline_movement(delta)
	if(is_grappled):
		_handle_grapple_movement(delta)
	
	move_and_slide()


func _handle_ground_movement(delta):
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_crouched and velocity.length() > 1 and Equipment_Manager.has_movement("Slide"):
		friction_mod = 0.9
	else:
		friction_mod = 0
	match movement_state:
		INPUTMOVEMENTSTATE.IDLE:
			_ground_idle_movement(delta)
		INPUTMOVEMENTSTATE.RUNNING:
			_ground_running_movement(direction, delta)
		_:
			pass

func _ground_idle_movement(delta):
	velocity.x = move_toward(velocity.x, 0, speed * delta * 10 * (1-(friction_mod*1.05)))
	velocity.z = move_toward(velocity.z, 0, speed * delta * 10 * (1-(friction_mod*1.05)))
	last_state = 0

func _ground_running_movement(direction, delta):
	velocity.x = move_toward(velocity.x, direction.x * speed, speed * delta * (1-friction_mod))
	velocity.z = move_toward(velocity.z, direction.z * speed, speed * delta * (1-friction_mod))
	last_state = 1


func _handle_wall_movement(delta):
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#identify what kind of movement to do
	#types of movement: wall slide(to jump off)-idle-crouched/walking-crouched, wall run(affected by gravity)-running-uncrouched
	#wall ride(not affected by gravity)-running-crouched, wall cling(to move around)-walking-uncrouched/idle-uncrouched
	match movement_state:
		INPUTMOVEMENTSTATE.IDLE: #wall slide
			_wall_idle_movement(delta)
		INPUTMOVEMENTSTATE.RUNNING: #wall ride
			_wall_running_movement(direction, delta)
		_:
			pass

func _wall_idle_movement(delta):
	if not Equipment_Manager.has_movement("WallSlide") or not is_crouched:
		_handle_air_movement(delta)
		last_state = 4
		return
	if(!_last_state_was_wall()):
		velocity.y = 0
	velocity.x = 0
	velocity.z = 0
	velocity.y -= gravity * delta * 0.2
	last_state = 2
	
func _wall_running_movement(direction, delta):
	if not is_crouched and Equipment_Manager.has_movement("WallRun"):
		if(!_last_state_was_wall()):
			velocity.y = JUMP_VELOCITY/2
		#get wall normal, determine which way player wants to go, move them along that way
		var wall_dir = get_wall_normal().rotated(Vector3.UP, PI/2)
		var vel_y = velocity.y
		if(direction.dot(wall_dir) > 0):
			velocity = (wall_dir * speed)
		else:
			velocity = (wall_dir * -1 * speed)
		velocity.y = vel_y - gravity * delta * 0.5
		last_state = 5
		return
	if Equipment_Manager.has_movement("WallRide"):
		#get wall normal, determine which way player wants to go, move them along that way
		var wall_dir = get_wall_normal().rotated(Vector3.UP, PI/2)
		if(direction.dot(wall_dir) > 0):
			velocity = (wall_dir * speed)
		else:
			velocity = (wall_dir * -1 * speed)
		last_state = 3
	else:
		_handle_air_movement(delta)


func _handle_air_movement(delta):
	velocity.y -= gravity * delta
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	match movement_state:
		INPUTMOVEMENTSTATE.IDLE:
			_air_idle_movement(delta)
		INPUTMOVEMENTSTATE.RUNNING:
			_air_running_movement(direction, delta)
		_:
			pass

func _air_idle_movement(delta):
	velocity.x = move_toward(velocity.x, 0.0, abs(velocity.x) * 0.05 * delta)
	velocity.z = move_toward(velocity.z, 0.0, abs(velocity.z) * 0.05 * delta)
	last_state = 6
	
func _air_running_movement(direction, delta):
	last_state = 7
	if velocity.length() > speed:
		return
	velocity.x = move_toward(velocity.x, direction.x * speed, speed * 0.5 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, speed * 0.5 * delta)


func _handle_grapple_movement(_delta):
	var dist = position.distance_to(grappleInst.position)
	if(dist > grapple_length):
		#remove outward velocity
		velocity = velocity - velocity.project(grappleInst.position.direction_to(position))
		#apply force inward
		velocity += position.direction_to(grappleInst.position) * (dist-grapple_length)

func _handle_zipline_movement(delta):
	velocity = velocity.project(ziplineInst.dir_normal)

func attach_to_zipline():
	var pos_diff = (position - ziplineInst.anchor1.global_position) as Vector3
	position -= (pos_diff - pos_diff.project(ziplineInst.dir_normal))

func _handle_turret_movement(delta):
	velocity = Vector3.ZERO
	position = turretInst.get_gunner_position()
	rotation.y = turretInst.get_gunner_rotation()

func _last_state_was_wall() -> bool:
	return last_state == 4 or last_state == 5 or last_state == 3 or last_state == 2


func _crouch():
	is_crouched = true
	
func _uncrouch():
	is_crouched = false

func _jump():
	if on_zipline:
		on_zipline = false
		velocity.y += 2*JUMP_VELOCITY
		
	
	elif(is_on_floor()):
		movement_state = INPUTMOVEMENTSTATE.JUMPING
		velocity.y = JUMP_VELOCITY
	elif(is_on_wall()):
		if(movement_state == INPUTMOVEMENTSTATE.IDLE):
			velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * JUMP_VELOCITY * 2
			velocity.y = JUMP_VELOCITY * sin(Cam.rotation.x)
		elif(movement_state == INPUTMOVEMENTSTATE.RUNNING):
			velocity.y = JUMP_VELOCITY
			velocity += get_wall_normal() * JUMP_VELOCITY * 1.5
		movement_state = INPUTMOVEMENTSTATE.JUMPING

func respawn():
	velocity = Vector3.ZERO
	set_position($Respawn_Anchor.position)


func set_respawn(pos : Vector3):
	$Respawn_Anchor.set_position(pos)


func on_hit(damage):
	health.take_damage(damage)
	
func die():
	health.health = 100
	respawn()
