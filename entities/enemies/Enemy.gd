extends Entity
class_name Enemy

# Properties
export var MAX_HEALTH := 20.0
export var value := 0
export var enemy_class := ""

export var revealed := false

export var MULTITHREADED_PATHFIND := false
export var PATHFIND_EPSILON = 16
export var DEBUG_PATH := false
var debug_path: Line2D

const groups := ["enemy", "map"]
const OFF_SCREEN = 250

# Fields
var health := 0.0 # Set in ready from max_health
var state: int = State.Passive

var post_hit := false # Flag for the frame after hit

# Navigation
var path := []

var navigation: Navigation2D
var navigation_target := WeakRef.new()

var direction = AnimUtil.Dir.Right

# States
enum State { Passive, Search, Aggro, Dead }

# Signals
signal on_damage(dmg)
signal on_death()

# Thread
#var mutex := Mutex.new()

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


# Events
func _physics_process(_delta):
	if DEBUG_PATH:
		debug_path.global_position = Vector2.ZERO
		debug_path.points = path

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
func set_target(target):
	#mutex.lock()
	navigation_target = weakref(target)
	#mutex.unlock()

func navigate():
	#mutex.lock()
	if path.size() <= 1: 
		#mutex.unlock()
		return Vector2.ZERO

	var mv = global_position.direction_to(path[1])
	
	if global_position.distance_to(path[1]) < PATHFIND_EPSILON:
		path.pop_front()
		
	#mutex.unlock()
		
	return mv

	
func generate_path():
	var target = navigation_target.get_ref()
	var _navigation = $"/root/GameManager".navigation
	if not target or _navigation == null: return
	
	$"/root/GameManager".add_pathfind_lazy_list([self, global_position, target.global_position])


