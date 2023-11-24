extends Control

@export var equipment_manager : Node

func _on_menu_button_button_down():
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
	for c in get_tree().root.get_children():
		if c.name == "Map":
			c.queue_free()

func toggle_ability(ability_name):
	if equipment_manager.has_ability(ability_name):
		equipment_manager.remove_ability.rpc(ability_name)
		return
	equipment_manager.add_ability.rpc(ability_name)
	
func toggle_movement(movement_name):
	if equipment_manager.has_movement(movement_name):
		equipment_manager.remove_movement.rpc(movement_name)
		return
	equipment_manager.add_movement.rpc(movement_name)


func _on_grapple_toggled(_button_pressed):
	toggle_ability("Grapple")


func _on_reel_toggled(_button_pressed):
	toggle_ability("Reel")


func _on_blast_toggled(_button_pressed):
	toggle_ability("Blast")


func _on_grenade_toggled(_button_pressed):
	toggle_ability("Grenade")


func _on_mine_toggled(_button_pressed):
	toggle_ability("Mine")


func _on_wall_toggled(_button_pressed):
	toggle_ability("Wall")


func _on_turret_toggled(_button_pressed):
	toggle_ability("Turret")


func _on_zipline_toggled(_button_pressed):
	toggle_ability("Zipline")



func _on_wall_run_toggled(_button_pressed):
	toggle_movement("WallRun")

func _on_wall_slide_toggled(_button_pressed):
	toggle_movement("WallSlide")


func _on_wall_ride_toggled(_button_pressed):
	toggle_movement("WallRide")


func _on_slide_toggled(_button_pressed):
	toggle_movement("Slide")
