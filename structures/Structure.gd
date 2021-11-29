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



func _ready():
	add_to_group("map")
	add_to_group("obstacle")
	
	health = MAX_HEALTH
	

func on_hit(damage, _attacker=null):
	health -= damage
	
	if not destroyed and health <= 0:
		destroyed = true
		on_destroyed()
		
func on_destroyed():
	pass

