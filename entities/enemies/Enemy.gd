extends Entity
class_name Enemy

# Properties
export var MAX_HEALTH := 20.0
export var value := 0
export var enemy_class := ""

const groups := ["enemy", "map"]

# Fields
var health := 0.0 # Set in ready from max_health
var state: int = State.Passive
var path: PoolVector2Array = []

var post_hit := false # Flag for the frame after hit

# States
enum State { Passive, Search, Aggro, Dead }


# Signals
signal on_damage(dmg)
signal on_death()

# Setup
func _ready():
	health = MAX_HEALTH
	
	for group in groups:
		add_to_group(group)
	#set_collision_layer_bit(ProjectSettings.get("global/TILEMAP_COL_BIT"), true)
	set_collision_layer_bit(ProjectSettings.get("global/PLAYER_BULLET_COL_BIT"), true)

	# warning-ignore:return_value_discarded
	connect("on_death", self, "on_death")

# Events


func on_hit(dmg: int):
	if health <= 0:
		return
	
	health -= dmg
	health = min(health, MAX_HEALTH)
	
	emit_signal("on_damage", dmg)
	
	if health <= 0:
		emit_signal("on_death")


func on_hit_knockback(vector: Vector2):
	position += vector
		
func on_death():
	pass
	
## Pathfinding

func navigate():
	if path.size() <= 1: return
	
	mv = global_position.direction_to(path[1]) * speed
	
	if global_position == path[0]:
		path.remove(0)
	
func generate_path(target: Node2D):
	var navigation = $"/root/GameManager".navigation
	
	if target == null or navigation == null: return
	
	path = navigation.get_simple_path(global_position, target.global_position, true)
