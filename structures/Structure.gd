extends StaticBody2D
class_name Structure

# Properties

export var MAX_HEALTH: float = 100

export var revealed := false

var health: float

## =============================================================================

# Fields
var destroyed := false
var mouse_hover := false

# Signals

signal on_activate()
# warning-ignore:unused_signal
signal on_deactivate() # Must be implemented by each structure

func _ready():
	add_to_group("map")
	
	health = MAX_HEALTH
	

func on_hit(damage):
	health -= damage
	
	if not destroyed and health <= 0:
		destroyed = true
		on_destroyed()
		
func on_destroyed():
	pass

