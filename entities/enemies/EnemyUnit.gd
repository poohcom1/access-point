extends Enemy
class_name EnemyUnit


# States
enum State { Passive, Default, Knockback, Stunned, Dead }
var state = State.Passive

# Properties
export var MULTITHREADED_PATHFIND := false
export var PATHFIND_EPSILON := 16
export var DEBUG_PATH := false
var debug_path: Line2D


export var AGGRO_RANGE = 10000
export var SHOW_RANGE := true setget _debug_range


# Navigation
export var PATHFIND_INTERVAL := 0.25
export var OFF_SCREEN_PATHFIND_INTERVAL := 2.0

var path := []

var navigation: Navigation2D
var navigation_target := WeakRef.new()

var pathfind_timer := Timer.new()

var direction = AnimUtil.Dir.Right

# Nodes
onready var state_timer := Timer.new()

# Setup
func _ready():
	if Engine.editor_hint: return
	
	state_timer.one_shot = true
	add_child(state_timer)
	
	# State timer
		# warning-ignore:return_value_discarded
	state_timer.connect("timeout", self, "_on_state_timeout")
	
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
	set_collision_layer_bit(GameManager.COL_TILE, false)
	set_collision_mask_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_PLAYER_BULLET, true)

func _init_pathfind():
	yield(get_tree(), "idle_frame")
	
	# Set navigation target
	set_target($"/root/GameManager".player)

	# warning-ignore:return_value_discarded	
	pathfind_timer.connect("timeout", self, "_on_generate_path")
	add_child(pathfind_timer)
	pathfind_timer.start(PATHFIND_INTERVAL)
	
	
	generate_path()

# States
func check_aggro():
	if (GameManager.player
		and global_position.distance_squared_to(GameManager.player.global_position)
		< AGGRO_RANGE * AGGRO_RANGE):
		_init_pathfind()
		state = State.Default
	

func on_hit_knockback(_dir, time = 0.1):
	if state != State.Dead:
		state = State.Knockback
		mv = _dir * 10
		state_timer.start(time)

# Pathfinding
func _physics_process(_delta):
	if DEBUG_PATH:
		debug_path.global_position = Vector2.ZERO
		debug_path.points = path


		
func on_death():
	pass
	
func _on_state_timeout():
	match state:
		State.Knockback:
			state = State.Default

	
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
		
	return mv

	
func generate_path():
	var target = navigation_target.get_ref()
	
	if not target or GameManager.navigation == null: return
	
	if MULTITHREADED_PATHFIND:
		GameManager.add_pathfind_lazy_list([self, global_position, target.global_position])
	else:
		path = GameManager.navigation.get_simple_path(global_position, target.global_position, false)

# Tool

func _debug_range(_val):
	print("hello")
