extends Node3D

enum GAMEMODE {RANGE, UNDERDOG}

@export var PlayerScene : PackedScene

@export var gamemode : GAMEMODE

var player_deaths = {
	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.authority = str(GameManager.Players[i].id)
		currentPlayer.add_to_group("Players")
		add_child(currentPlayer)
		player_deaths[currentPlayer.name] = 0
		set_random_spawn(currentPlayer)
		currentPlayer.respawn()
		index += 1
		if gamemode == GAMEMODE.RANGE:
			currentPlayer.Equipment_Manager.set_points(999)

func set_random_spawn(player):
	var spawn = get_tree().get_nodes_in_group("PlayerSpawnPoint").pick_random()
	player.set_respawn.rpc(spawn.global_position)

func player_died(player):
	set_random_spawn(player)
	player.respawn()
	player_deaths[player.name] += 1
	if gamemode == GAMEMODE.UNDERDOG:
		player.Equipment_Manager.clear_abilities()
		player.Equipment_Manager.clear_movement()
		player.Equipment_Manager.set_points(player_deaths[player.name])


func get_random_player():
	return get_tree().get_nodes_in_group("Players").pick_random()

func _input(event):
	if event is InputEventKey and Input.is_action_just_pressed("Reset"):
		reset()

func reset():
	get_tree().call_group("Players", "respawn")
	get_tree().call_group("Targets", "reset")
