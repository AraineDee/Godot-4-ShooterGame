extends Control

@export var unready_color : Color
@export var ready_color : Color

var is_ready := false

func _ready():
	$Ready.color = unready_color

@rpc("any_peer", "call_local")
func toggle_ready():
	if is_ready:
		$Ready.color = unready_color
	else:
		$Ready.color = ready_color
	is_ready = !is_ready
		
		
func set_player(id):
	name = str(id)
	$Name.text = GameManager.Players[id]["name"]
