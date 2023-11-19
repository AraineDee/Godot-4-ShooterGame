extends Area3D

class_name Target

func on_hit():
	visible = false
	$Shape.disabled = true
	
func reset():
	visible = true
	$Shape.disabled = false
