extends Node

@onready var player = get_parent() as CharacterBody3D

@onready var mine_scene = load("res://Scenes/Mine.tscn")

@rpc("any_peer","call_local")
func place_mine():
	var gunRay = player.bodyRay
	if not gunRay.is_colliding():
		return
	var mineInst = mine_scene.instantiate() as Node3D
	mineInst.set_as_top_level(true)
	player.get_parent().add_child(mineInst)
	mineInst.global_transform.origin = gunRay.get_collision_point() as Vector3

func _input(event):
	if not player.is_local_player():
		return 
	
	if event.is_action_pressed("Mine"):
		place_mine.rpc()
