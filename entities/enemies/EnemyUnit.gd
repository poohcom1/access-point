extends Enemy
class_name EnemyUnit

# States
enum State { Default, Knockback, Stunned, Dead }
var state = State.Default

# Properties
export var MULTITHREADED_PATHFIND := false
export var PATHFIND_EPSILON := 16
export var DEBUG_PATH := false
var debug_path: Line2D


# Navigation
var path := []

var navigation: Navigation2D
var navigation_target := WeakRef.new()

var direction = AnimUtil.Dir.Right

# Nodes
onready var state_timer := Timer.new()

# Setup
func _ready():
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


# States
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
		
	#mutex.unlock()
		
	return mv

	
func generate_path():
	var target = navigation_target.get_ref()
	var _navigation = GameManager.navigation
	if not target or _navigation == null: return
	
	GameManager.add_pathfind_lazy_list([self, global_position, target.global_position])


