extends Node

@onready var player = get_parent() as CharacterBody3D

func interact():
	if player.in_range_of_zipline:
		player.on_zipline = !player.on_zipline
		if player.on_zipline:
			player.attach_to_zipline()
	
	if player.in_range_of_turret:
		player.on_turret = !player.on_turret
		player.turretInst.is_mounted = !player.turretInst.is_mounted
	elif player.on_turret:
		player.on_turret = false
		player.turretInst.is_mounted = false
		
	
func _input(event):
	if not player.is_local_player():
		return
	
	if event.is_action_pressed("Interact"):
		interact()
