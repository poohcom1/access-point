extends Entity
class_name Enemy

# Properties
export var MAX_HEALTH := 2
export var value := 0
export var enemy_class := ""

const group := "enemy"

# Fields
var health := 0 # Set in ready from max_health
var state: int = State.Passive

# States
enum State { Passive, Search, Aggro, Dead }


# Signals
signal on_damage(dmg)
signal on_death()

# Setup
func _ready():
	health = MAX_HEALTH
	add_to_group(group)
	#set_collision_layer_bit(ProjectSettings.get("global/TILEMAP_COL_BIT"), true)
	set_collision_layer_bit(ProjectSettings.get("global/PLAYER_BULLET_COL_BIT"), true)

	# warning-ignore:return_value_discarded
	connect("on_death", self, "on_death")

#Update
func _process(_delta):
	pass

# Events

func on_hit(dmg: int):
	if health <= 0:
		return
	
	health -= dmg
	
	emit_signal("on_damage", dmg)
	
	if health <= 0:
		emit_signal("on_death")

	#on_hit_knockback(angle)


func on_hit_knockback(vector: Vector2):
	position += vector
		
func on_death():
	pass
