extends Node

@onready var player = get_parent() as CharacterBody3D

var points = 0


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

var ability_cost = {
	"Blast" : 1,
	"Grapple" : 1,
	"Reel" : 1,
	"Mine" : 1,
	"Wall" : 1,
	"Zipline" : 1,
	"Grenade" : 1,
	"Turret" : 1
}

var ability_dict = {}


@onready var movement_classes = {
	
}

var movement_cost = {
	"WallRide" : 1,
	"WallRun" : 1,
	"WallSlide" : 1,
	"Slide" : 1
}

var movement_dict = {}

func _ready():
	for ability in get_tree().get_nodes_in_group("Abilities"):
		ability_dict[ability.name] = ability

func set_points(p):
	points = p
	get_parent().set_points_label(p)

func clear_abilities():
	ability_dict.clear()
	
func clear_movement():
	movement_dict.clear()


func has_ability(ability_name) -> bool:
	for a in ability_dict:
		if a == ability_name:
			return true
			
	return false
	
@rpc("any_peer","call_local")
func add_ability(ability_name):
	if points < ability_cost[ability_name]:
		return
	if ability_dict.has(ability_name):
		return
	set_points(points - ability_cost[ability_name])
	var abilityInst = ability_classes[ability_name].new()
	player.add_child(abilityInst)
	ability_dict[ability_name] = abilityInst

@rpc("any_peer","call_local")
func remove_ability(ability_name):
	if ability_dict.has(ability_name):
		set_points(points + ability_cost[ability_name])
		ability_dict[ability_name].queue_free()
		ability_dict.erase(ability_name)


func has_movement(movement_name):
	for a in movement_dict:
		if a == movement_name:
			return true
			
	return false

@rpc("any_peer","call_local")
func add_movement(movement_name):
	if points < movement_cost[movement_name]:
		return
	if movement_dict.has(movement_name):
		return
	set_points(points - movement_cost[movement_name])
	movement_dict[movement_name] = null

@rpc("any_peer","call_local")
func remove_movement(movement_name):
	if movement_dict.has(movement_name):
		set_points(points + movement_cost[movement_name])
		movement_dict.erase(movement_name)



