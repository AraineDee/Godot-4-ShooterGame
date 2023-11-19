extends Control

@export var equipment_manager : Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_menu_button_button_down():
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func toggle_ability(name):
	if equipment_manager.has_ability(name):
		equipment_manager.remove_ability.rpc(name)
		return
	equipment_manager.add_ability.rpc(name)
	
func toggle_movement(name):
	if equipment_manager.has_movement(name):
		equipment_manager.remove_movement.rpc(name)
		return
	equipment_manager.add_movement.rpc(name)


func _on_grapple_toggled(button_pressed):
	toggle_ability("Grapple")


func _on_reel_toggled(button_pressed):
	toggle_ability("Reel")


func _on_blast_toggled(button_pressed):
	toggle_ability("Blast")


func _on_grenade_toggled(button_pressed):
	toggle_ability("Grenade")


func _on_mine_toggled(button_pressed):
	toggle_ability("Mine")


func _on_wall_toggled(button_pressed):
	toggle_ability("Wall")


func _on_turret_toggled(button_pressed):
	toggle_ability("Turret")


func _on_zipline_toggled(button_pressed):
	toggle_ability("Zipline")



func _on_wall_run_toggled(button_pressed):
	toggle_movement("WallRun")

func _on_wall_slide_toggled(button_pressed):
	toggle_movement("WallSlide")


func _on_wall_ride_toggled(button_pressed):
	toggle_movement("WallRide")


func _on_slide_toggled(button_pressed):
	toggle_movement("Slide")
