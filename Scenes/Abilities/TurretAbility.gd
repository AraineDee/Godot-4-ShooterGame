extends Node

@onready var player = get_parent() as CharacterBody3D

@onready var turret_scene = load("res://Scenes/Turret.tscn")

@rpc("any_peer","call_local")
func place_turret():
	var gunRay = player.bodyRay
	if not gunRay.is_colliding():
		return
	var turretInst = turret_scene.instantiate() as Node3D
	turretInst.set_as_top_level(true)
	player.get_parent().add_child(turretInst)
	turretInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	player.turretInst = turretInst

func _input(event):
	if not player.is_local_player():
		return 
	
	if event.is_action_pressed("Turret"):
		place_turret.rpc()
