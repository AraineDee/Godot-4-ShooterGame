extends Node

class_name HealthComponent

@onready var parent = get_parent()

@export var health = 100

func take_damage(damage):
	health -= damage
	if health <= 0:
		owner.die()
