extends Node3D

@export var anchor0 : Node3D
@export var anchor1 : Node3D

var dir_normal : Vector3

func init(anchor_pos_0 : Vector3, anchor_pos_1 : Vector3):
	var dir = anchor_pos_1 - anchor_pos_0
	dir_normal = dir.normalized()
	global_position = anchor_pos_0 + (dir / 2)
	anchor0.position = dir / 2
	anchor1.position = dir * -1 / 2
	$Line.scale.z = anchor_pos_0.distance_to(anchor_pos_1)
	$Line.look_at(anchor_pos_1)


func _on_line_body_entered(body):
	if body is CharacterBody3D:
		body.ziplineInst = self
		body.in_range_of_zipline = true


func _on_line_body_exited(body):
	print("b")
	if body is CharacterBody3D:
		print("b")
		body.in_range_of_zipline = false
