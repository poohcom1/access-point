extends Entity
class_name Enemy

# Properties
export var MAX_HEALTH := 20.0
export var value := 0
export var enemy_class := ""

export var revealed := false

const groups := ["enemy", "map"]
const OFF_SCREEN = 250

# Fields
var health := 0.0 # Set in ready from max_health


# Signals
signal on_damage(dmg)
signal on_death()


# Setup
func _ready():
	
	health = MAX_HEALTH
	
	for group in groups:
		add_to_group(group)
	set_collision_layer_bit(GameManager.COL_TILE, false)
	set_collision_mask_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_PLAYER_BULLET, true)

	# warning-ignore:return_value_discarded
	connect("on_death", self, "on_death")


func on_hit(dmg: int):
	if health <= 0:
		return
	
	health -= dmg
	health = min(health, MAX_HEALTH)
	
	emit_signal("on_damage", dmg)
	
	if health <= 0:
		emit_signal("on_death")


func on_death():
	pass
	
