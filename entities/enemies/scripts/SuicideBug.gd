tool
extends EnemyUnit

# Propertie
export var DAMAGE = 30
export(Array, AudioStream) var DEATH_SFX := []

export var EXPLODE_RANGE := 150

# Fields
enum CustomStates { Explode }
var exploded = false

# Nodes
var animControl: AnimControl

# Signals
func _ready():
	if Engine.editor_hint: return
	
	animControl = AnimControl.new($AnimatedSprite)
	add_child(animControl)

	# Set death sound fx on random
	$DeathSFX.stream = DEATH_SFX[randi() % DEATH_SFX.size()]

func _physics_process(_delta):	
	if Engine.editor_hint: return
	match state:
		State.Default:
			mv = navigate()
			
			set_move_animation()
			
			move_and_slide(mv * speed)
			
			## Attack
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision.collider == navigation_target.get_ref():
					_explode()
		State.Knockback:
			# warning-ignore:return_value_discarded
			move_and_slide(mv)
		CustomStates.Explode:
			pass
			
func _explode():
	if not exploded:
		$AnimatedSprite.play("explode")
		$AnimatedSprite.connect("animation_finished", self, "queue_free")
		
		for node in get_tree().get_nodes_in_group("friendly"):
			if global_position.distance_to(node.global_position) < EXPLODE_RANGE:
				node.on_hit(DAMAGE)
			
		exploded = true
		pause_state = true
		state = CustomStates.Explode



func on_death():
	state = State.Dead
	#mutex.lock()
	var corpse := CORPSE.instance()
	
	
	get_parent().add_child(corpse)
	corpse.global_position = global_position
	corpse.z_index = 0
	
	var sprite = $AnimatedSprite
	var se = $DeathSFX
	
	se.pitch_scale = rand_range(0.9, 1.1)
	se.play()
	
	corpse.anim_sprite.frames = anim_sprite.frames
	corpse.anim_sprite.modulate = anim_sprite.modulate
	remove_child(se)
	corpse.add_child(se)
	sprite.play("death")
	
	queue_free()
	

