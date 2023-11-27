extends Node3D

enum GAMEMODE {RANGE, UNDERDOG}

@export var PlayerScene : PackedScene

@onready var lobby_scene = load("res://Scenes/Lobby/lobby.tscn") as PackedScene

@export var gamemode : GAMEMODE

var player_deaths = {
	
}

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	GameManager.scores_changed.connect(_check_win_condition)
	
	Console.add_command("reset_map", reset)
	Console.add_command("kill", kill_command, 1)
	Console.add_command("add_score", add_score_command, 2)
	
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
		GameManager.Players[i]	["node"] = currentPlayer
		if gamemode == GAMEMODE.RANGE:
			currentPlayer.Equipment_Manager.set_points(999)


func _check_win_condition():
	for id in GameManager.Players:
		if GameManager.Players[id]["score"] > 20:
			game_over(id)

func game_over(winner_id):
	GameManager.last_winner = winner_id
	go_to_lobby()
	
func go_to_lobby():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var lobbyInst = lobby_scene.instantiate()
	get_tree().root.add_child(lobbyInst)
	self.queue_free()


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

func got_kill(killer, killed):
	if killer.authority == multiplayer.get_unique_id():
		GameManager.add_score.rpc(killer.authority, 1)

func get_random_player():
	return get_tree().get_nodes_in_group("Players").pick_random()


func kill_command(player : String):
	for p in GameManager.Players:
		if p["name"] == player:
			p["node"].die()

func reset():
	get_tree().call_group("Players", "respawn")
	get_tree().call_group("Targets", "reset")

func add_score_command(p_name : String, num : String):
	GameManager.add_score.rpc(GameManager.get_id_from_name(p_name), num as int)

	
func peer_disconnected(id):
	if id == 1:
		get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
		queue_free()
	GameManager.Players[id]["node"].queue_free()
	GameManager.Players.erase(id)
