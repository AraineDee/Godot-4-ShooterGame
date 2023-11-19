extends Node

@onready var player = get_parent() as CharacterBody3D

@onready var grenade_scene = load("res://Scenes/Grenade.tscn")

@rpc("any_peer","call_local")
func throw_grenade():
	var grenadeInst = grenade_scene.instantiate() as RigidBody3D
	grenadeInst.set_as_top_level(true)
	player.get_parent().add_child(grenadeInst)
	grenadeInst.position = player.position + Vector3(0, 0.8, 0)
	grenadeInst.apply_central_impulse(15 * Vector3.FORWARD.rotated(Vector3.RIGHT, player.Cam.rotation.x).rotated(Vector3.UP, player.rotation.y))
	

func _input(event):
	if not player.is_local_player():
		return 
	if event.is_action_pressed("Grenade"):
		throw_grenade.rpc()
