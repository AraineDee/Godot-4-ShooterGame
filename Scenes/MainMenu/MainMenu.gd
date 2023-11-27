extends Control

@export var obstacle_course_scene : PackedScene
@export var range_scene : PackedScene
@onready var lobby_scene = load("res://Scenes/Lobby/lobby.tscn") as PackedScene

@export var port = 8910

var new_scene : PackedScene

var is_host

var address
var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_custom_commands()
	Console.add_command("bind", bind_command, 1)
	
	clear_gm_players()
	multiplayer.multiplayer_peer = null
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostGame()
		go_to_lobby()

func remove_custom_commands():
	Console.remove_command("bind")
	Console.remove_command("reset_map")
	Console.remove_command("kill")
	Console.remove_command("add_score")

func clear_gm_players():
	GameManager.Players = {}

# this get called on the server and clients
func peer_connected(id):
	$PlayerCounter.text = str(multiplayer.get_peers().size() + 1)
	print("Player Connected " + str(id))
	
# this get called on the server and clients
func peer_disconnected(id):
	$PlayerCounter.text = str(multiplayer.get_peers().size() + 1)
	print("Player Disconnected " + str(id))
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

# called only from clients
func connected_to_server():
	print("connected To Server!")
	GameManager.SendPlayerInformation.rpc_id(1, $NameEdit.text, multiplayer.get_unique_id())
	go_to_lobby()

# called only from clients
func connection_failed():
	print("Couldnt Connect")


@rpc("any_peer", "call_local")
func set_scene_range():
	new_scene = range_scene
	
@rpc("any_peer", "call_local")
func set_scene_obby():
	new_scene = obstacle_course_scene

@rpc("any_peer","call_local")
func StartGame():
	#REMOVE THIS!!!
	if !is_host:
		AudioServer.set_bus_mute(0, true)
	
	var sceneInst = new_scene.instantiate()
	get_tree().root.add_child(sceneInst)
	self.queue_free()
	
func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		
	multiplayer.set_multiplayer_peer(peer)
	is_host = true
	print("Waiting For Players!")
	

@rpc("authority")
func go_to_lobby():
	var lobbyInst = lobby_scene.instantiate()
	get_tree().root.add_child(lobbyInst)
	self.queue_free()

func _on_host_button_down():
	hostGame()
	GameManager.SendPlayerInformation($NameEdit.text, multiplayer.get_unique_id())
	go_to_lobby()
	


func _on_join_button_down():
	address = $IPEdit.text
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	is_host = false

func _on_play_button_button_down():
	for button in get_tree().get_nodes_in_group("PlayOptions"):
		button.visible = !button.visible

func _on_options_button_down():
	for button in get_tree().get_nodes_in_group("SettingOptions"):
		button.visible = !button.visible


func _on_quit_button_down():
	get_tree().quit()


func _on_obstacle_course_button_down():
	if peer == null:
		is_host = true
		GameManager.SendPlayerInformation($NameEdit.text, 1)
	set_scene_obby.rpc()
	StartGame.rpc()


func _on_range_button_down():
	if peer == null:
		GameManager.SendPlayerInformation($NameEdit.text, 1)
		is_host = true
	set_scene_range.rpc()
	StartGame.rpc()
	
@rpc("any_peer", "call_local")
func _go_to_scene(scene):
	get_tree().change_scene_to_packed(scene)

var new_bind_name = ""
var listening_for_keybind := false
func bind_command(bind_name : String):
	Console.print_line("Listening...")
	listening_for_keybind = true
	new_bind_name = bind_name
	Console.toggle_console()

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if listening_for_keybind:
			update_bind(new_bind_name, event)
	
	if event is InputEventMouseButton and event.is_pressed():
		if listening_for_keybind:
			update_bind(new_bind_name, event)

func update_bind(name, event):
	InputMap.action_erase_events(new_bind_name)
	InputMap.action_add_event(new_bind_name, event)
	listening_for_keybind = false
	for button in get_tree().get_nodes_in_group("KeyBinds"):
		button.set_pressed(false)
	Console.print_line(name + " has been set to: " + event.to_string())
	Console.toggle_console()


func _on_pause_bind_button_down():
	new_bind_name = "Pause"
	listening_for_keybind = true

func _on_grapple_bind_button_down():
	new_bind_name = "Grapple"
	listening_for_keybind = true
	
func _on_blast_bind_button_down():
	new_bind_name = "Blast"
	listening_for_keybind = true


func _on_reel_bind_button_down():
	new_bind_name = "Reel"
	listening_for_keybind = true






