extends Node


@onready var player = get_parent() as CharacterBody3D

@onready var zipline_scene = load("res://Scenes/Zipline.tscn")
@onready var anchor_scene = load("res://Scenes/Grapple.tscn")

var anchorInst : Node3D
var anchor_count = 0

@rpc("any_peer","call_local")
func attach_anchor():
	var gunRay = player.bodyRay
	if not gunRay.is_colliding():
			return
	if anchor_count == 0:
		anchorInst = anchor_scene.instantiate()
		anchorInst.set_as_top_level(true)
		player.add_child(anchorInst)
		anchorInst.position = gunRay.get_collision_point() as Vector3
		anchor_count = 1
	elif anchor_count == 1:
		var ziplineInst = zipline_scene.instantiate() as Node3D
		ziplineInst.set_as_top_level(true)
		player.get_parent().add_child(ziplineInst)
		ziplineInst.init(anchorInst.global_position, gunRay.get_collision_point())
		anchorInst.queue_free()
		anchor_count = 0

func _input(event):
	if not player.is_local_player():
		return 
	
	if event.is_action_pressed("Zipline"):
		attach_anchor.rpc()
