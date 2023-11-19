extends Node

@onready var player = get_parent() as CharacterBody3D

@onready var wall_scene = load("res://Scenes/Wall.tscn")

@rpc("any_peer","call_local")
func place_wall():
	var gunRay = player.bodyRay
	if not gunRay.is_colliding():
		return
	var wallInst = wall_scene.instantiate() as Node3D
	wallInst.set_as_top_level(true)
	player.get_parent().add_child(wallInst)
	wallInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	wallInst.look_at(player.position)
	wallInst.rotation.x = 0
	wallInst.rotation.z = 0

func _input(event):
	if not player.is_local_player():
		return 
	
	if event.is_action_pressed("Wall"):
		place_wall.rpc()
