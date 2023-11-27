extends Area3D

class_name HitboxComponent

@onready var parent = get_parent()

func on_hit(source, damage):
	parent.on_hit(source, damage)
