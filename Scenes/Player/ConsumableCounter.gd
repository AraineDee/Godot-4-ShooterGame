extends Control

@export var equipment_manager : Node
@export var ability_name : String

func _ready():
	$AbilityName.text = ability_name
	$Decrement.button_down.connect(decrement)
	$Increment.button_down.connect(increment)

func _process(_delta):
	update_counter()

func increment():
	equipment_manager.increment_consumable.rpc(ability_name)
	update_counter()
	
func decrement():
	equipment_manager.decrement_consumable.rpc(ability_name)
	update_counter()	
	
	
func update_counter():
	$Counter.text = str(equipment_manager.get_consumable_count(ability_name))


