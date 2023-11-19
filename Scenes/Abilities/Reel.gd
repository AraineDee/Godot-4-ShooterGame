extends Node


@onready var player = get_parent()
var is_active := false

func _physics_process(delta):
	if is_active:
		player.grapple_length -= 10 * delta

func _input(event):
	if not player.is_local_player():
		return 
	
	if event.is_action_pressed("Reel"):
		is_active = true
		
	if event.is_action_released("Reel"):
		is_active = false
