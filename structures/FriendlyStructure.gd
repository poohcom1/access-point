tool
extends Structure
class_name FriendlyStructure

# Properties
export var MAX_BATTERY: float = 4

# Fields
export var battery: float
export var bugged := false

# Nodes


# Signals


func _ready():
	# warning-ignore:return_value_discarded
	$ClickArea.connect("mouse_entered", self, "_on_mouse_enter")
	# warning-ignore:return_value_discarded
	$ClickArea.connect("mouse_exited", self, "_on_mouse_exit")
	
	

## Mouse Check
func _on_mouse_enter():
	mouse_hover = true
	
func _on_mouse_exit():
	mouse_hover = false
	
func add_battery(val):
	set_battery(battery + val)
	
func _unhandled_input(event):
	if event.is_action_pressed("interact", false) and mouse_hover:
		if GameManager.player.battery > 0 and battery < MAX_BATTERY:
			GameManager.player.battery -= 1
			add_battery(1)

func set_battery(val):
	if battery == 0:
		emit_signal("on_activate")
		
	battery = val
	
	if battery <= 0:
		emit_signal("on_deactivate")
		battery = 0
		

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
