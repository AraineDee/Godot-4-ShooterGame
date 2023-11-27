extends Control

func set_player_name(p_name : String):
	$NameLabel.text = p_name
	
func set_score(score : int):
	$ScoreLabel.text = str(score)
