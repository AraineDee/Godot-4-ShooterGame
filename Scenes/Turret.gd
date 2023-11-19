extends Node3D


var is_mounted := false	

func get_gunner_position():
	return position + Vector3.UP + Vector3.BACK.rotated(Vector3.UP, $TurretHead.rotation.y)

func get_gunner_rotation():
	return $TurretHead.rotation.y

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if is_mounted:
			$TurretHead.rotation.y -= event.relative.x / 1000


func _on_interact_area_body_entered(body):
	if body is CharacterBody3D and not is_mounted:
		body.turretInst = self
		body.in_range_of_turret = true


func _on_interact_area_body_exited(body):
	if body is CharacterBody3D:
		body.in_range_of_turret = false
