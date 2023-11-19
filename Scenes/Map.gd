extends Node3D



@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.authority = str(GameManager.Players[i].id)
		currentPlayer.add_to_group("Players")
		add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
				currentPlayer.set_respawn(spawn.global_position)
		index += 1

func get_random_player():
	return get_tree().get_nodes_in_group("Players").pick_random()

func _input(event):
	if event is InputEventKey and Input.is_action_just_pressed("Reset"):
		reset()

func reset():
	get_tree().call_group("Players", "respawn")
	get_tree().call_group("Targets", "reset")
