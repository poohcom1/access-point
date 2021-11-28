tool
extends EnemyUnit

const Bullet = preload("res://entities/enemies/objects/DirectProjectile.tscn")

# Properties
export var SHOOT_INTERVAL := 1.5
export var DAMAGE := 5

export var RANGE := 100
export var SHOOT_PAUSE := 0.3

export var BULLET_SPEED = 3


const RANGE_GROUP = "range"

# Nodes
onready var shoot_timer := Timer.new()

# States
enum RangeState { Shoot }


# Signals
func _ready():
	if Engine.editor_hint: return
	add_to_group(RANGE_GROUP)
	
	## Healing timer
	add_child(shoot_timer)
	
	
	# warning-ignore:return_value_discarded
	shoot_timer.connect("timeout", self, "shoot")
	
func _physics_process(_delta):
	if Engine.editor_hint: return
	match state:
		State.Default:
			set_move_animation()
			
			mv = navigate_with_sightline()

			mv = move_and_slide(mv * speed)
			
			if distance_sqr_to_player() < RANGE*RANGE:
				change_state_with_timer(RangeState.Shoot, SHOOT_PAUSE)
				if shoot_timer.time_left == 0:
					shoot()
				shoot_timer.start(SHOOT_INTERVAL)
		State.Knockback:
			mv = move_and_slide(mv)

func on_state_timeout():
	if state == RangeState.Shoot:
		if distance_sqr_to_player() > RANGE*RANGE:
			state = State.Default
			shoot_timer.stop()
		else:
			state_timer.start(SHOOT_PAUSE)
	.on_state_timeout()
	
	
	
	
func shoot():
	if state == RangeState.Shoot:
		var bullet = ProjectileUtil.create_bullet_here(Bullet, self, GameManager.player.global_position, BULLET_SPEED)
		bullet.damage = DAMAGE
		on_state_timeout()

func on_death():
	var corpse := Node2D.new()
	
	get_parent().add_child(corpse)
	corpse.global_position = global_position
	corpse.z_index = 0
	var sprite = $AnimatedSprite
	
	remove_child(sprite)
	corpse.add_child(sprite)
	sprite.play("death")
	
	queue_free()

