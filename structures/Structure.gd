tool
extends StaticBody2D
class_name Structure

# Properties
export var MAX_HEALTH: float = 100
export var MAX_BATTERY: int = 100

# Fields
var bugged := false

var health: float
var battery: int
var destroyed := false

# Nodes


# Signals


func _ready():
	health = MAX_HEALTH
	battery = MAX_BATTERY
	
	add_to_group("map")
	
	# warning-ignore:return_value_discarded
	$ClickArea.connect("mouse_entered", self, "_on_mouse_enter")
	# warning-ignore:return_value_discarded
	$ClickArea.connect("mouse_exited", self, "_on_mouse_enter")

func on_add_battery():
	pass

func on_hit(damage):
	health -= damage
	
	if not destroyed and health <= 0:
		destroyed = true
		on_destroyed()
		
func on_destroyed():
	pass


func _process(_delta):
	if Engine.editor_hint:
		update_configuration_warning()

func _get_configuration_warning():
	if not has_node("ClickArea"):
		return "Requires an Area2D named 'ClickArea'."
		
	if not get_node("ClickArea") is Area2D:
		return "ClickArea must be an Area2D!"
	
	return ""
