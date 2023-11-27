extends Control


@onready var score_bar = load("res://Scenes/Player/Scoreboard/PlayerScoreBar.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.scores_changed.connect(_update_scores)
	
	var count = 0
	for id in GameManager.Players:
		var barInst = score_bar.instantiate() as Control
		add_child(barInst)
		barInst.name = str(id)
		barInst.set_player_name(GameManager.Players[id]["name"])
		barInst.position.y = count * 24
		count += 1


func _update_scores():
	for id in GameManager.Players:
		for bar in get_tree().get_nodes_in_group("player_score_bars"):
			if str(id) == bar.name:
				bar.set_score(GameManager.Players[id]["score"])
