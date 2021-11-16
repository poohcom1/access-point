tool
extends StaticBody2D
class_name Structure

# Properties
## CUSTOM EXPORTS ==============================================================
# Some over complicated bs just for conditional exports
export var MAX_HEALTH: float = 100
export var MAX_BATTERY: float = 4

export var revealed := false

export var custom_stats: bool = false setget _set_custom_stats
var health: float
var battery: float setget set_battery

func _set_custom_stats(val):
	custom_stats = val
	property_list_changed_notify()
	
func _get_property_list():
	var property_list = []
	if custom_stats:
		property_list.append({
			"name": "health",
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,%f" % MAX_HEALTH
		})
		property_list.append({
			"name": "battery",
			"type": TYPE_REAL,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,%f" % MAX_BATTERY
		}) 
	return property_list
## =============================================================================

# Fields
var bugged := false

var destroyed := false
var mouse_hover := false

# Signals

signal on_activate()
# warning-ignore:unused_signal
signal on_deactivate() # Must be implemented by each structure

func _ready():
	if not custom_stats:
		health = MAX_HEALTH
		battery = MAX_BATTERY
	
	add_to_group("map")
	
	# warning-ignore:return_value_discarded
	$ClickArea.connect("mouse_entered", self, "_on_mouse_enter")
	# warning-ignore:return_value_discarded
	$ClickArea.connect("mouse_exited", self, "_on_mouse_exit")

## Mouse Check
func _on_mouse_enter():
	mouse_hover = true
	
func _on_mouse_exit():
	mouse_hover = false
	
	

func set_battery(val):
	if battery == 0:
		emit_signal("on_activate")
		
	battery = val
	
	if battery <= 0:
		emit_signal("on_deactivate")
		battery = 0
		
func add_battery(val):
	set_battery(battery + val)

func _unhandled_input(event):
	if event.is_action_pressed("interact", false) and mouse_hover:
		if $"/root/GameManager".player.battery > 0 and battery < MAX_BATTERY:
			$"/root/GameManager".player.battery -= 1
			add_battery(1)

func on_hit(damage):
	health -= damage
	
	if not destroyed and health <= 0:
		destroyed = true
		on_destroyed()
		
func on_destroyed():
	pass


func _process(_delta):	
	## Editor hints
	if Engine.editor_hint:
		update_configuration_warning()

func _get_configuration_warning():
	if not has_node("ClickArea"):
		return "Requires an Area2D named 'ClickArea'."
		
	if not get_node("ClickArea") is Area2D:
		return "ClickArea must be an Area2D!"
	
	return ""
