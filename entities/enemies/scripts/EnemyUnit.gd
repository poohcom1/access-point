tool
extends Enemy
class_name EnemyUnit

const CORPSE = preload("res://entities/enemies/objects/Corpse.tscn")
const DEFAULT_DEATH_SFX = preload("res://assets/SE/BugDeath2.mp3")

# States
enum State { Passive=-1, Rallying=-2, Default=-3, Knockback=-4, Stunned=-5, Dead=-6 }
var state = State.Passive

var rally_point: Vector2

# Properties
export var MULTITHREADED_PATHFIND := true
export var PATHFIND_EPSILON := 16

export var FRIEND_RANGE := 168

export var SHOW_RANGE := false setget _debug_range
export var AGGRO_RANGE := 500 setget _set_aggro_range

export var DEBUG_PATH := false
var debug_path: Line2D

var pause_state = true

# Navigation
export var FOCUS_PLAYER := false

export var PATHFIND_INTERVAL := 0.25
export var OFF_SCREEN_PATHFIND_INTERVAL := 3.0

var pathfind_interval

var path := []

var navigation: Navigation2D
var navigation_target := WeakRef.new()

var direction = AnimUtil.Dir.Right

# Animation
export(NodePath) var ANIMATION_NODE = "AnimatedSprite"

# Nodes
onready var pathfind_timer := Timer.new()
onready var state_timer := Timer.new()

onready var sightline := RayCast2D.new()

var anim_sprite: AnimatedSprite

var direct_chase = false # Ignoring pathfind and charging in a straight line
var onscreen = true

# Setup
func _ready():
	if Engine.editor_hint: return
	
	# Init search area (for nearby aggro)
	GameManager.connect("aggro_alert", self, "alert")
	
	
	# Check anim sprite
	if ANIMATION_NODE == null:
		ANIMATION_NODE = "AnimatedSprite"
		
	anim_sprite = get_node(ANIMATION_NODE)	
	
	# State timer
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
	
	# Groups
	for group in groups:
		add_to_group(group)
		
	set_collision_layer_bit(GameManager.COL_TILE, false)
	set_collision_mask_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_PLAYER_BULLET, true)
	
	# States
	if state == State.Default:
		to_aggro(search_nearest_target())
	elif state == State.Rallying:
		generate_path(false)
	
		
	## Pathfind setup
	pathfind_interval = PATHFIND_INTERVAL
	
	if has_node("VisibilityEnabler2D"):
		get_node("VisibilityEnabler2D").connect("screen_entered", self, "_on_screen_enter")
		get_node("VisibilityEnabler2D").connect("screen_exited", self, "_on_screen_exit")
		
		if not get_node("VisibilityEnabler2D").is_on_screen():
			pathfind_interval = OFF_SCREEN_PATHFIND_INTERVAL
			onscreen = false
		pass
	
		
	## Vision
	sightline.enabled = true
	sightline.set_collision_mask_bit(GameManager.COL_TILE, true)
	add_child(sightline)

func _init_pathfind():
	pathfind_timer.start(PATHFIND_INTERVAL)
	
	assert(GameManager.player != null)
	
# Default states

# States Management
func on_hit(dmg, from=null, type: String = ""):
	.on_hit(dmg, from, type)
	
	if state == State.Passive or state == State.Rallying:
		to_aggro()
		

func to_aggro(target=search_nearest_target()):
	set_target(target)
	_init_pathfind()
	state = State.Default
	
	GameManager.emit_signal("aggro_alert", global_position, target)

func alert(_position, target):
	if state == State.Passive and global_position.distance_squared_to(_position) < pow(FRIEND_RANGE, 2):
		to_aggro(target)

func change_state_with_timer(new_state, timeout=0):
	if timeout > 0:
		state_timer.start(timeout)
	state = new_state
	
func on_state_timeout():
	match state:
		State.Knockback:
			state = State.Default

func on_hit_knockback(vector: Vector2, time = 0.1):
	if not pause_state and state != State.Dead:
		state = State.Knockback
		mv = vector * 10
		state_timer.start(time)


# Default processes
func _process(_delta):
	if Engine.editor_hint or state == State.Dead: return
	
	if state == State.Passive or state == State.Rallying:
		
		var nearest_target = search_nearest_target()

		if nearest_target:
			to_aggro(nearest_target)
			
	if DEBUG_PATH:
		debug_path.global_position = Vector2.ZERO
		debug_path.points = path
		
	if state == State.Rallying:
		move_and_slide(navigate() * speed)
		set_move_animation()
	
	var target = navigation_target.get_ref()
	if not target or (target and target.is_in_group("friendly") and target.health <= 0):
		var new_target = search_nearest_target()
		if new_target:
			set_target(new_target)
		else:
			state = State.Passive		
	if GameManager.player and state == State.Default and FOCUS_PLAYER and in_aggro_range(GameManager.player):
		set_target(GameManager.player)
		

	
## Pathfinding ========================================
func search_nearest_target() -> Node2D:
	var nearest = null
	var nearest_dist = INF
	
	for node in get_tree().get_nodes_in_group("friendly"):
		var distance = global_position.distance_squared_to(node.global_position)

		if distance < nearest_dist and node.health > 0.1 and distance < pow(AGGRO_RANGE, 2):
			if FOCUS_PLAYER and node == GameManager.player:
				nearest = GameManager.player
				break
			
			nearest_dist = distance
			nearest = node
				
	
	return nearest


func set_target(target):
	navigation_target = weakref(target)

func navigate():
	if path.size() <= 1: 
		return Vector2.ZERO

	var mv = global_position.direction_to(path[1])
	
	if global_position.distance_to(path[1]) < PATHFIND_EPSILON:
		path.pop_front()
		
	return mv

func navigate_with_sightline():
	if not navigation_target.get_ref():
		return Vector2.ZERO
	sightline.cast_to = to_local(navigation_target.get_ref().global_position)
	
	if onscreen and sightline.is_colliding():
		mv = navigate()
		if pathfind_timer.is_stopped():
			generate_path()
	else:
		mv = global_position.direction_to(navigation_target.get_ref().global_position)
		if not pathfind_timer.is_stopped():
			pathfind_timer.stop()
			
	return mv

func generate_path(repeat=true):
	#GameManager.static_counter += 1
	#print_debug(GameManager.static_counter)
	
	var target = navigation_target.get_ref()
	
	if direct_chase or not GameManager.navigation or not target: return
	
	#if not target:
	#	navigation_target = weakref(GameManager.player)
	#	target = GameManager.player
	
	if MULTITHREADED_PATHFIND:
		GameManager.add_pathfind_lazy_list([self, global_position, target.global_position])
	else:
		path = GameManager.navigation.get_simple_path(global_position, target.global_position, false)

	if repeat:
		pathfind_timer.start(pathfind_interval)
	
func _on_screen_enter():
	onscreen = true
	if state != State.Rallying:
		pathfind_timer.start(PATHFIND_INTERVAL)
	
	pathfind_interval = PATHFIND_INTERVAL
	
func _on_screen_exit():
	onscreen = false
	pathfind_interval = OFF_SCREEN_PATHFIND_INTERVAL
	
# ANIMATION ===============================
# Eight-direction animation
onready var previous_position := global_position

var previous_direction = direction
var frames_since_changed = 0

func set_angle_animation(angle, anim="run", anim_node = anim_sprite):
	direction = AnimUtil.get_dir(angle)
	
	var diranim = AnimUtil.Dir2Anim[direction]
	
	anim_node.flip_h = abs(AnimUtil.Dir2Angle[direction]) > 90
	anim_node.play("%s_%s" % [anim, diranim])

func set_move_animation(anim_node = anim_sprite):
	if not anim_node: return
	#todo: Use idle anim when states are added
	var moveanim = "run"
	
	frames_since_changed += 1
	
	if mv != Vector2.ZERO:
		if global_position.distance_squared_to(previous_position) > 250 and frames_since_changed > 3:
			frames_since_changed = 0
			
			var angle = global_position.angle_to_point(previous_position)
			previous_position = global_position
			
			direction = AnimUtil.get_dir(angle)
	
	direction = AnimUtil.turn(previous_direction, direction)
	previous_direction = direction
		
	var diranim = AnimUtil.Dir2Anim[direction]
	
	anim_node.flip_h = abs(AnimUtil.Dir2Angle[direction]) > 90
	anim_node.play("%s_%s" % [moveanim, diranim])
	
# Tool
func _draw():
	if not Engine.editor_hint or not SHOW_RANGE: return
	
	draw_circle_outline(Vector2.ZERO, AGGRO_RANGE, Color(1, 0, 0))

func draw_circle_outline(circle_center, circle_radius, color):
	circle_radius = Vector2.UP * circle_radius
	var draw_counter = 1
	var line_origin = Vector2.ZERO
	var line_end = Vector2.ZERO
	line_origin = circle_radius + circle_center

	while draw_counter <= 30:
		
		draw_counter += 1
		
		line_end = circle_radius.rotated(deg2rad(draw_counter*12)) + circle_center
		
		if draw_counter % 3 == 0: 
			draw_line(line_origin, line_end, color, 4)
		line_origin = line_end

	line_end = circle_radius.rotated(deg2rad(360)) + circle_center
	draw_line(line_origin, line_end, color, 4)

func _set_aggro_range(aggro_range):
	AGGRO_RANGE = aggro_range
	update()

func _debug_range(show):
	SHOW_RANGE = show
	update()

func in_aggro_range(node):
	return distance_sqr_to_target(node) < pow(AGGRO_RANGE, 2)

func distance_sqr_to_target(target = navigation_target.get_ref()) -> float:
	if not target: 
		return INF
	return global_position.distance_squared_to(target.global_position)
