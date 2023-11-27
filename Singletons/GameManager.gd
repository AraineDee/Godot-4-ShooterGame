extends Node

var Players = {}

signal scores_changed

var last_winner : int

@rpc("any_peer")
func SendPlayerInformation(player_name, id):
	if !Players.has(id):
		Players[id] ={
			"name" : player_name,
			"id" : id,
			"score" : 0,
			"node" : null
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)

func get_id_from_name(p_name):
	for id in Players:
		if Players[id]["name"] == p_name:
			return id
	return -1

@rpc("any_peer", "call_local")
func add_score(id, num : int):
	Players[id]["score"] += num
	scores_changed.emit()

@rpc("any_peer", "call_local")
func reset_scores():
	for id in Players:
		Players[id]["score"] = 0
	scores_changed.emit()
