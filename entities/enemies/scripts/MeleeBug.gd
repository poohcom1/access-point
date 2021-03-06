tool
extends EnemyUnit

# Properties
export var DAMAGE = 5
export var ATTACK_INTERVAL = 0.2

export(float, 0.0, 1.0) var ATTACK_HEALTH = 0.75
export(float, 0.0, 1.0) var RETREAT_HEALTH = 0.5
export var RETREAT_SPEED := 175

export var USE_AI := true

export(Array, AudioStream) var DEATH_SFX := []
export(AudioStream) var ATK_SFX

# Fields
var touching_target = false
var was_touching := false # If touching player on the previous frame
var blocker: DestructableStructure 

# Navigation
var retreating = false

var player_in_range := false

# Nodes
onready var attack_timer := $AttackTimer
onready var anim_eyes := $Eyes

onready var search_area := $SearchArea

func _ready():
	if Engine.editor_hint: return
	
	# Attack timer
	attack_timer.connect("timeout", self, "_on_attack")
	
	
	# Set death sound fx on random
	$DeathSFX.stream = DEATH_SFX[randi() % DEATH_SFX.size()]
	

func _physics_process(_delta):	
	if Engine.editor_hint: return
	
	$BurningParticles.emitting = is_burning()
	
	var healers: Array
	
	if USE_AI:
		healers = search_area.get_overlapping_bodies()
	
	match state:
		State.Default, State.Rallying:
			# AI
			if USE_AI:
				if not retreating and health <= MAX_HEALTH * RETREAT_HEALTH and healers.size() > 0:
					var target = MathUtil.get_nearest_node(self, healers, "healer")
					if target:
						speed = RETREAT_SPEED
						set_target(target)
						retreating = true
				elif retreating and not navigation_target.get_ref() or (health > MAX_HEALTH * ATTACK_HEALTH or healers.size() == 0):
						speed = BASE_SPEED				
						set_target(search_nearest_target())
						retreating = false

			## Pathfinding
			mv = navigate()
			
			if not touching_target:
				set_move_animation()
				set_move_animation(anim_eyes)
			elif navigation_target.get_ref():
				set_angle_animation(
					navigation_target.get_ref().global_position.angle_to_point(global_position)
				)
				
				set_angle_animation(
					navigation_target.get_ref().global_position.angle_to_point(global_position),
					"run",
					anim_eyes
				)
			
			for i in get_slide_count():
				var col := get_slide_collision(i)
				
				if col.collider is TileMap:
					mv += col.normal * 2
				
			var _slide = move_and_slide(mv * speed)
			
			## Attack
			var target = navigation_target.get_ref()
			
			if target and target.is_in_group("friendly"):
				var found_target = false

				
				for i in range(get_slide_count()):
					var collision = get_slide_collision(i)
					if collision.collider == target and target.health > 0:
						found_target = true
						touching_target = true
							
					if collision.collider.is_in_group("blocker"):
						found_target = true
						blocker = collision.collider
						
					
				if found_target:
					if attack_timer.is_stopped():
						
						_on_attack()
						attack_timer.start(ATTACK_INTERVAL)
				if not found_target:
					touching_target = false
		State.Knockback:
			set_angle_animation((-mv).angle())
			move_and_slide(mv)

func on_hit(dmg, from=null, type=""):
	.on_hit(dmg, from, type)
	
	if from == GameManager.player:
		set_target(from)
	
func _on_attack():
	var hit_something = false	
	if touching_target and navigation_target.get_ref():
		navigation_target.get_ref().on_hit(DAMAGE, self)
		add_child(OneShotAudio2D.new(ATK_SFX))
		hit_something = true
	
	if is_instance_valid(blocker):
		add_child(OneShotAudio2D.new(ATK_SFX))
		blocker.on_hit(DAMAGE, self)
		hit_something = true
		
	if not hit_something:
		attack_timer.stop()
	
func on_death():
	state = State.Dead
	var corpse := CORPSE.instance()
	
	get_parent().add_child(corpse)
	corpse.global_position = global_position
	corpse.z_index = 0
	
	var sprite = $AnimatedSprite
	var se = $DeathSFX
	
	se.pitch_scale = rand_range(0.9, 1.1)
	se.play()
	
	corpse.anim_sprite.frames = anim_sprite.frames
	remove_child(se)
	corpse.add_child(se)
	sprite.play("death")
	
	queue_free()
	

