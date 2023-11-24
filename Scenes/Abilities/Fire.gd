extends Node

@onready var bullet_scene = load("res://Scenes/Bullet/Bullet.tscn")
@onready var player = get_parent()

@rpc("any_peer", "call_local")
func use():
	var gunRay = player.hitboxRay
	player.gunshot_emitter.play()
	if not gunRay.is_colliding():
		return
	if gunRay.get_collider() is HitboxComponent:
		gunRay.get_collider().on_hit(25)
		return
	var bulletInst = bullet_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	player.get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point() + gunRay.get_collision_normal()),Vector3.BACK)
	
func un_use(_player):
	pass


func _input(event):
	if not player.is_local_player():
		return 
	if event.is_action_pressed("Fire"):
		use.rpc()
		
	if event.is_action_released("Fire"):
		un_use(get_parent())
