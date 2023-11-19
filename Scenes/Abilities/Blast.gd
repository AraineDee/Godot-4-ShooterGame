extends Node


func use(player):
	var look_vec = Vector3.FORWARD.rotated(Vector3.UP, player.rotation.y)
	player.velocity -= look_vec * player.JUMP_VELOCITY * 2
	player.velocity.y -= player.JUMP_VELOCITY * sin(player.Cam.rotation.x) * 2
	

func un_use(_player):
	pass


func _input(event):
	if event.is_action_pressed("Blast"):
		use(get_parent())
		
	if event.is_action_released("Blast"):
		un_use(get_parent())
