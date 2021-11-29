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
export(AudioStream) var ATK_SFX

# Fields
var touching_player = false
var was_touching := false # If touching player on the previous frame
var is_attacking := false # Attack flag set from timer

# Navigation
enum NavStates { Attack, Retreat }
var nav_state = NavStates.Attack

var player_in_range := false

# Nodes
onready var search_area := $SearchArea
onready var attack_timer := $AttackTimer

onready var anim_eyes := $Eyes

func _ready():
	if Engine.editor_hint: return
	
	# Attack timer
	attack_timer.connect("timeout", self, "_on_attack")
	
	# Set death sound fx on random
	$DeathSFX.stream = DEATH_SFX[randi() % DEATH_SFX.size()]

func _physics_process(_delta):	
	if Engine.editor_hint: return
	
	$BurningParticles.emitting = is_burning()
	
	match state:
		State.Default:
			# AI
			if USE_AI:
				var healers = search_area.get_overlapping_bodies()
				
				match nav_state:
					NavStates.Attack:
						speed = BASE_SPEED
						if health <= MAX_HEALTH * RETREAT_HEALTH:
							if healers.size() > 0:
								var target = MathUtil.get_nearest_node(self, healers, "healer")
								if target:
									set_target(target)
									nav_state = NavStates.Retreat	
					NavStates.Retreat:
						speed = RETREAT_SPEED
						if not navigation_target.get_ref() or (health > MAX_HEALTH * ATTACK_HEALTH or healers.size() == 0):
							set_target($"/root/GameManager".player)
							nav_state = NavStates.Attack

			## Pathfinding
			mv = navigate_with_sightline()
			
			if not touching_player:
				set_move_animation()
				set_move_animation(anim_eyes)
			else:
				set_angle_animation(
					GameManager.player.global_position.angle_to_point(global_position)
				)
				
				set_angle_animation(
					GameManager.player.global_position.angle_to_point(global_position),
					"run",
					anim_eyes
				)
			
			for i in get_slide_count():
				var col := get_slide_collision(i)
				
				if col.collider is TileMap:
					mv += col.normal * 2
				
			var _slide = move_and_slide(mv * speed)
			
			## Attack
			var found_player = false
			
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision.collider is Player:
					found_player = true
					if not touching_player and attack_timer.is_stopped():
						touching_player = true
						
						_on_attack()
						attack_timer.start(ATTACK_INTERVAL)
					break
			if not found_player:
				touching_player = false
		State.Knockback:
			set_angle_animation((-mv).angle())
			move_and_slide(mv)


func _on_attack():
	if touching_player:
		GameManager.player.on_hit(DAMAGE, self)
		add_child(OneShotAudio2D.new(ATK_SFX))
	else:
		attack_timer.stop()
	
func on_death():
	state = State.Dead
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
	

