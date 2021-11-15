tool
extends StaticBody2D
class_name Structure

# Properties
export var MAX_HEALTH: float = 100
export var MAX_BATTERY: float = 4

# Fields
var bugged := false

var health: float
var battery: float
var destroyed := false

var mouse_hover := false


func _ready():
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

func _unhandled_input(event):
	if event.is_action_pressed("interact", false) and mouse_hover:
		if $"/root/GameManager".player.battery > 0 and battery < MAX_BATTERY:
			battery += 1.0
			$"/root/GameManager".player.battery -= 1

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
