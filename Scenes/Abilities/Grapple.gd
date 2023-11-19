extends Node

@onready var grapple_scene = load("res://Scenes/Grapple.tscn")
@onready var player = get_parent()

@rpc("any_peer","call_local")
func use():
	var gunRay = player.bodyRay
	var grappleInst
	if not gunRay.is_colliding():
		return
	grappleInst = grapple_scene.instantiate() as Node3D
	grappleInst.set_as_top_level(true)
	player.add_child(grappleInst)
	grappleInst.position = gunRay.get_collision_point() as Vector3
	player.grapple_length = grappleInst.position.distance_to(player.position)
	player.is_grappled = true
	player.grappleInst = grappleInst
	
@rpc("any_peer","call_local")
func un_use():
	if(player.grappleInst != null):
		player.grappleInst.queue_free()
	player.is_grappled = false


func _input(event):
	if not player.is_local_player():
		return 
	if event.is_action_pressed("Grapple"):
		use.rpc()
		
	if event.is_action_released("Grapple"):
		un_use.rpc()
