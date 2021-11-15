extends Entity
class_name Enemy

# Properties
export var MAX_HEALTH := 20.0
export var value := 0
export var enemy_class := ""

export var revealed := false

export var DEBUG_PATH := false
var debug_path: Line2D

const groups := ["enemy", "map"]

# Fields
var health := 0.0 # Set in ready from max_health
var state: int = State.Passive

var post_hit := false # Flag for the frame after hit

# Navigation
var path := []

var navigation: Navigation2D
var navigation_target: Node2D

# States
enum State { Passive, Search, Aggro, Dead }

# Signals
signal on_damage(dmg)
signal on_death()

# Setup
func _ready():
	## DEBUG
	if DEBUG_PATH:
		debug_path = Line2D.new()
		debug_path.width = 1
		debug_path.global_position = Vector2.ZERO
		debug_path.z_index = 10
		add_child(debug_path)
	
	## DEBUG_END
	
	health = MAX_HEALTH
	
	for group in groups:
		add_to_group(group)
	#set_collision_layer_bit(ProjectSettings.get("global/TILEMAP_COL_BIT"), true)
	set_collision_layer_bit(ProjectSettings.get("global/PLAYER_BULLET_COL_BIT"), true)

	# warning-ignore:return_value_discarded
	connect("on_death", self, "on_death")
	
	yield(get_tree(), "idle_frame")
	navigation = $"/root/GameManager".navigation

# Events
func _physics_process(_delta):
	if DEBUG_PATH:
		debug_path.global_position = Vector2.ZERO

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
func navigate() -> Vector2:
	if path.size() <= 1: return Vector2.ZERO
	
	var mv = global_position.direction_to(path[1]) * speed
	
	if global_position.distance_squared_to(path[0]) < speed:
		path.pop_front()
		
	return mv
	
func generate_path():
	if not is_instance_valid(navigation_target) or navigation_target == null or navigation == null: return
	
	path = navigation.get_simple_path(global_position, navigation_target.global_position, false)
	if DEBUG_PATH:
		debug_path.points = path
