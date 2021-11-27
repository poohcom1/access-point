extends Area2D

export(Array, NodePath) var TRIGGERS := []

export var TRIGGERED := false
export var DISABLE_ON_SCREEN := true


export var SPAWN_COUNT := 1000
export var SPAWN_INTERVAL := 10.0
export var SPAWN_INCREMENT := 0.0
export var SPAWN_MAX_INTERVAL := 120.0
export var SPAWN_MIN_INTERVAL := 5.0

export var ENEMY_AMOUNT := 10
export var ENEMY_MAX_AMOUNT := 100
export var ENEMY_MIN_AMOUNT := 1

export var MELEE_PRIORITY = 90
export var HEALER_PRIORITY = 10
export var SUICIDE_PRIORITY = 1
export var RANGE_PRIORITY = 5

export var ENEMY_INCREMENT := 0
export var ENEMY_PRE_AGGRO := true

export var SPAWNS_PER_FRAME = 5

# Fields
var interval

var trigger_areas := []

var on_screen = false

var enemies_to_spawn := []

# Nodes
onready var timer := $Interval
onready var radius = $SpawnArea.shape.radius

# Enemies
const MeleeBug = preload("res://entities/enemies/MeleeBug.tscn")
const HealerBug = preload("res://entities/enemies/HealerBug.tscn")
const SuicideBug = preload("res://entities/enemies/SuicideBug.tscn")
const RangeBug = preload("res://entities/enemies/RangeBug.tscn")

var spawn_priorities := {}
var priority_total = 0

func _ready():
	spawn_priorities = {
		MeleeBug: MELEE_PRIORITY,
		HealerBug: HEALER_PRIORITY,
		SuicideBug: SUICIDE_PRIORITY,
		RangeBug: RANGE_PRIORITY,
	}
	
	
	for priority in spawn_priorities.values():
		priority_total += priority
		
	interval = SPAWN_INTERVAL
	
	if DISABLE_ON_SCREEN:
		$VisibilityNotifier.connect("screen_entered", self, "enter_screen")
		$VisibilityNotifier.connect("screen_exited", self, "exit_screen")
		
		$VisibilityNotifier.rect = Rect2(-radius, -radius, radius*2, radius*2)
	
	for child in get_children():
		if child is Area2D:
			child.connect("body_entered", self, "on_enter")
			trigger_areas.append(child)
		
	for nodepath in TRIGGERS:
		var trigger = get_node(nodepath)
		trigger.connect("body_entered", self, "on_enter")
		trigger_areas.append(trigger)
		
	if TRIGGERED:
		start_spawn()
		
func on_enter(body):
	if body is Player:
		start_spawn()

func start_spawn():
	if not TRIGGERED:
		TRIGGERED = true
		timer.connect("timeout", self, "on_spawn")
		on_spawn()
		
		for trigger in trigger_areas:
			trigger.disconnect("body_entered", self, "on_enter")
	
func on_spawn():
	if SPAWN_COUNT == 0: return
	timer.start(clamp(interval, SPAWN_MIN_INTERVAL, SPAWN_MAX_INTERVAL))
	
	if on_screen: return
	
	randomize()
	interval += SPAWN_INCREMENT
	
	var amount = clamp(ENEMY_AMOUNT, ENEMY_MIN_AMOUNT, ENEMY_MAX_AMOUNT)
	
	for i in amount:
		var EnemyType = null
		
		var chance = randi() % priority_total
		
		var current_chance = 0
	
		for enemy in spawn_priorities:
			current_chance += spawn_priorities[enemy]
			if chance <= current_chance:
				EnemyType = enemy
				break

		var enemy = EnemyType.instance()
		
		enemy.position = random_position()
		
		enemy.state = enemy.State.Default
		enemies_to_spawn.append(enemy)
		
	ENEMY_AMOUNT += ENEMY_INCREMENT
	SPAWN_COUNT -= 1


func random_position() -> Vector2:
	var angle = rand_range(0, 2 * PI)
	var _radius = rand_range(0, radius)
	
	return Vector2(cos(angle), sin(angle)) * _radius
	
func enter_screen():
	on_screen = true
	
func exit_screen():
	on_screen = false
	
# Lazy spawning
func _process(_delta):
	var count = SPAWNS_PER_FRAME
	
	for _i in range(count):
		var enemy = enemies_to_spawn.pop_back()
		if not enemy: return
	
		get_tree().root.add_child(enemy)
		enemy.global_position = global_position + enemy.position
		
	if len(enemies_to_spawn) == 0 and SPAWN_COUNT == 0:
		set_process(false)
		$SpawnArea.disabled = true
	
