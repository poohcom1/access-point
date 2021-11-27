tool
extends EnemyUnit

# Properties
export var DAMAGE = 5
export var ATTACK_INTERVAL = 0.2

export(float, 0.0, 1.0) var ATTACK_HEALTH = 0.75
export(float, 0.0, 1.0) var RETREAT_HEALTH = 0.5
export var RETREAT_SPEED := 150

export var RETREAT_TIMER := 10.0
var retreat_timer := 0.0

export var USE_AI := true

export(Array, AudioStream) var DEATH_SFX := []

# Fields
var was_touching := false # If touching player on the previous frame
var is_attacking := false # Attack flag set from timer

# Navigation
enum NavStates { Attack, Retreat }
var nav_state = NavStates.Attack

var player_in_range := false

# Nodes
var attack_timer := Timer.new()

# Signals
func _ready():

	# Attack timer
	add_child(attack_timer)
	attack_timer.start(ATTACK_INTERVAL)
	attack_timer.connect("timeout", self, "_on_attack")
	
	# Set death sound fx on random
	$DeathSFX.stream = DEATH_SFX[randi() % DEATH_SFX.size()]

func _physics_process(_delta):	
	if Engine.editor_hint: return
	match state:
		State.Default:
			# AI
			if USE_AI:
				var healers = get_tree().get_nodes_in_group("healer")
				
				match nav_state:
					NavStates.Attack:
						speed = BASE_SPEED
						if health <= MAX_HEALTH * RETREAT_HEALTH:
							if healers.size() > 0:
								set_target(MathUtil.get_nearest_node(self, healers))
								nav_state = NavStates.Retreat	
					NavStates.Retreat:
						speed = RETREAT_SPEED
						if not navigation_target.get_ref() or (health > MAX_HEALTH * ATTACK_HEALTH or healers.size() == 0):
							set_target($"/root/GameManager".player)
							nav_state = NavStates.Attack

			## Pathfinding
			mv = navigate()
			
			_set_animation()
			
			for i in get_slide_count():
				var col := get_slide_collision(i)
				
				if col.collider is TileMap:
					mv += col.normal * 2
				
			var _slide = move_and_slide(mv * speed)
			
			## Attack
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision.collider is Player:
					if not was_touching or is_attacking:
						collision.collider.on_hit(DAMAGE)
						is_attacking = false
						was_touching = true
					
						attack_timer.start()
					break
		State.Knockback:
			# warning-ignore:return_value_discarded
			move_and_slide(mv)


func _on_attack():
	is_attacking = true
	
func on_death():
	state = State.Dead
	#mutex.lock()
	var corpse := Node2D.new()
	
	
	get_parent().add_child(corpse)
	corpse.global_position = global_position
	corpse.z_index = 0
	
	var sprite = $AnimatedSprite
	var se = $DeathSFX
	
	se.pitch_scale = rand_range(0.9, 1.1)
	se.play()
	
	remove_child(sprite)
	corpse.add_child(sprite)
	remove_child(se)
	corpse.add_child(se)
	sprite.play("death")
	
	queue_free()
	

