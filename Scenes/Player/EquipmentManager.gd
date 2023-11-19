extends Node

@onready var player = get_parent() as CharacterBody3D

@onready var ability_classes = {
	"Blast" : load("res://Scenes/Abilities/Blast.gd"),
	"Grapple" : load("res://Scenes/Abilities/Grapple.gd"),
	"Reel" : load("res://Scenes/Abilities/Reel.gd"),
	"Mine" : load("res://Scenes/Abilities/MineAbility.gd"),
	"Wall" : load("res://Scenes/Abilities/Wall.gd"),
	"Zipline" : load("res://Scenes/Abilities/ZiplineAbility.gd"),
	"Grenade" : load("res://Scenes/Abilities/GrenadeAbility.gd"),
	"Turret" : load("res://Scenes/Abilities/TurretAbility.gd")
}
var ability_dict = {}


@onready var movement_classes = {
	
}

var movement_dict = {}

func _ready():
	for ability in get_tree().get_nodes_in_group("Abilities"):
		ability_dict[ability.name] = ability

func has_ability(name) -> bool:
	for a in ability_dict:
		if a == name:
			return true
			
	return false
	
@rpc("any_peer","call_local")
func add_ability(name):
	if ability_dict.has(name):
		return
	var abilityInst = ability_classes[name].new()
	player.add_child(abilityInst)
	ability_dict[name] = abilityInst

@rpc("any_peer","call_local")
func remove_ability(name):
	if ability_dict.has(name):
		ability_dict[name].queue_free()
		ability_dict.erase(name)


func has_movement(name):
	for a in movement_dict:
		if a == name:
			return true
			
	return false

@rpc("any_peer","call_local")
func add_movement(name):
	if movement_dict.has(name):
		return
	movement_dict[name] = null

@rpc("any_peer","call_local")
func remove_movement(name):
	if movement_dict.has(name):
		movement_dict.erase(name)



