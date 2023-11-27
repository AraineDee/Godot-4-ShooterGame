extends Control

@export var _player_bar_scene : PackedScene
@export var _map_scene : PackedScene
@onready var _main_menu_scene = load("res://Scenes/MainMenu/MainMenu.tscn") as PackedScene

var player_count := 0
var my_bar : Control

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	$ReadyButton.button_down.connect(toggle_my_bar)
	
	if GameManager.last_winner != 0:
		$WinnerArea/WinnerLabel.text = GameManager.Players[GameManager.last_winner]["name"] + " won last game! Congratulations!"

var update_timer = 0.2
func _process(delta):
	if update_timer <= 0:
		update_player_bars()
		update_timer = 1.0
	else:
		update_timer -= delta


func peer_connected(id):
	pass

func peer_disconnected(id):
	if id == 1:
		get_tree().change_scene_to_packed(_main_menu_scene)
		queue_free()
	remove_player_bar.rpc(id)
	GameManager.Players.erase(id)

@rpc("any_peer", "call_local")
func update_player_bars():
	for id in GameManager.Players:
		if not bar_exists(id):
			add_player_bar(id)

func bar_exists(id):
	for bar in get_tree().get_nodes_in_group("player_bars"):
		if bar.name == str(id):
			return true
	return false

@rpc("authority", "call_local")
func add_player_bar(id):
	var barInst = _player_bar_scene.instantiate() as Control
	$Players.add_child(barInst)
	barInst.add_to_group("player_bars")
	barInst.set_player(id)
	if id == multiplayer.get_unique_id():
		my_bar = barInst
	align_player_bars()

@rpc("authority", "call_local")
func remove_player_bar(id):
	for bar in get_tree().get_nodes_in_group("player_bars"):
		if bar.name == str(id):
			bar.queue_free()
	align_player_bars()

func align_player_bars():
	var count = 0
	for bar in get_tree().get_nodes_in_group("player_bars"):
		bar.position.y = count * 26 
		count += 1


func toggle_my_bar():
	my_bar.toggle_ready.rpc()
	check_bars.rpc()

@rpc("any_peer", "call_local")
func check_bars():
	for bar in get_tree().get_nodes_in_group("player_bars"):
		if not bar.is_ready:
			$StartButton.disabled = true
			return
	$StartButton.disabled = false
			

@rpc("any_peer", "call_local")
func start():
	if multiplayer.get_unique_id() == 1:
		GameManager.reset_scores.rpc()
	get_tree().change_scene_to_packed(_map_scene)
	queue_free()
	

func _on_start_button_button_down():
	start.rpc()
