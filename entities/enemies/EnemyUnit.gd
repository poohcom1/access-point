tool
extends Enemy
class_name EnemyUnit


# States
enum State { Passive=-1, Default=-2, Knockback=-3, Stunned=-4, Dead=-5 }
var state = State.Passive

# Properties
export var MULTITHREADED_PATHFIND := false
export var PATHFIND_EPSILON := 16
export var DEBUG_PATH := false

var debug_path: Line2D

export var SHOW_RANGE := false setget _debug_range
export var AGGRO_RANGE := 300 setget _set_aggro_range

var can_knockback = true


# Navigation
export var PATHFIND_INTERVAL := 0.25
export var OFF_SCREEN_PATHFIND_INTERVAL := 2.0

var path := []

var navigation: Navigation2D
var navigation_target := WeakRef.new()

var direction = AnimUtil.Dir.Right

# Nodes
onready var pathfind_timer := Timer.new()
onready var state_timer := Timer.new()

var _aggro_area := Area2D.new()
var _aggro_shape := CollisionShape2D.new()
var _aggro_circle := CircleShape2D.new()

# Setup
func _ready():
	if Engine.editor_hint: 
		_aggro_circle.radius = AGGRO_RANGE
		_aggro_shape.shape = _aggro_circle
		_aggro_area.visible = SHOW_RANGE
		_aggro_area.add_child(_aggro_shape)
		add_child(_aggro_area)
		return
	
	state_timer.one_shot = true
	add_child(state_timer)
	
	# State timer
	state_timer.connect("timeout", self, "on_state_timeout")
	
	pathfind_timer.connect("timeout", self, "generate_path")
	pathfind_timer.autostart = false
	add_child(pathfind_timer)
	
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
	
	if state == State.Default:
		to_aggro()

func _init_pathfind():
	pathfind_timer.start(PATHFIND_INTERVAL)
	
	assert(GameManager.player != null)
	
	# Set navigation target
	set_target($"/root/GameManager".player)

# States
func change_state(new_state, timeout=0):
	if timeout > 0:
		state_timer.start(timeout)
	state = new_state

func to_aggro():
	_init_pathfind()
	state = State.Default

func on_hit_knockback(_dir, time = 0.1):
	if can_knockback and state != State.Dead:
		state = State.Knockback
		mv = _dir * 10
		state_timer.start(time)

func on_death():
	pass
	
func on_state_timeout():
	match state:
		State.Knockback:
			state = State.Default

# Pathfinding
func _physics_process(_delta):
	if Engine.editor_hint: return
	
	if GameManager.player and state == State.Passive and global_position.distance_to(GameManager.player.global_position) < AGGRO_RANGE:
		to_aggro()
	
	if DEBUG_PATH:
		debug_path.global_position = Vector2.ZERO
		debug_path.points = path
		
	# potential fix for bugs not moving
	if state == State.Default and path == []:
		generate_path()

	
## Pathfinding
func set_target(target):
	navigation_target = weakref(target)

func navigate():
	if path.size() <= 1: 
		return Vector2.ZERO

	var mv = global_position.direction_to(path[1])
	
	if global_position.distance_to(path[1]) < PATHFIND_EPSILON:
		path.pop_front()
		
	return mv

	
func generate_path():
	var target = navigation_target.get_ref()
	
	if GameManager.navigation == null: return
	
	if not target:
		navigation_target = weakref(GameManager.player)
		target = GameManager.player
	
	if MULTITHREADED_PATHFIND:
		GameManager.add_pathfind_lazy_list([self, global_position, target.global_position])
	else:
		path = GameManager.navigation.get_simple_path(global_position, target.global_position, false)

	pathfind_timer.start(PATHFIND_INTERVAL)
	
# Eight-direction animation
onready var previous_position := global_position

func _set_animation(anim_node = $AnimatedSprite):
	if not is_instance_valid(anim_node):
		return
	
	#todo: Use idle anim when states are added
	var moveanim = "run"
	
	if mv != Vector2.ZERO:
		if global_position.distance_squared_to(previous_position) > 100:
			
			var angle = global_position.angle_to_point(previous_position)
			previous_position = global_position
			
			
			direction = AnimUtil.get_dir(angle)

		
	var diranim = AnimUtil.Dir2Anim[direction]
	
	anim_node.flip_h = abs(AnimUtil.Dir2Angle[direction]) > 90
	anim_node.play("%s_%s" % [moveanim, diranim])
	
# Tool
func _set_aggro_range(aggro_range):
	AGGRO_RANGE = aggro_range
	_aggro_circle.radius = aggro_range

func _debug_range(show):
	SHOW_RANGE = show
	_aggro_shape.visible = show
	_aggro_shape.modulate = Color(1, 0, 0, 0.25)

func distance_sqr_to_player() -> float:
	if not GameManager.player: 
		return INF
	return global_position.distance_squared_to(GameManager.player.global_position)
