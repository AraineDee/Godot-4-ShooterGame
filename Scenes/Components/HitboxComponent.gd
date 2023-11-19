extends Area3D

class_name HitboxComponent

@onready var parent = get_parent()

func on_hit(damage):
	parent.on_hit(damage)
