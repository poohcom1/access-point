tool
extends EnemyUnit

# Properties
export var HEAL_INTERVAL := 0.2
export var HEAL_AMOUNT := 2

export var REGEN_AMOUNT := 0.25

export var DISTANCE_TO_PLAYER := 100
export var HEAL_PAUSE := 0.3

const HEALER_GROUP = "healer"

# Nodes
onready var heal_timer := Timer.new()
onready var heal_area := $HealingArea

# States
enum HealerState { Heal }


# Signals
func _ready():
	add_to_group(HEALER_GROUP)
	
	## Healing timer
	add_child(heal_timer)
	heal_timer.start(HEAL_INTERVAL)
	# warning-ignore:return_value_discarded
	heal_timer.connect("timeout", self, "_on_heal")
	

func _physics_process(_delta):
	if Engine.editor_hint: return
	match state:
		State.Default:
			_set_animation()
			
			mv = navigate()

			mv = move_and_slide(mv * speed)
			
			if distance_sqr_to_player() < DISTANCE_TO_PLAYER*DISTANCE_TO_PLAYER:
				state = HealerState.Heal
				state_timer.start(HEAL_PAUSE)
		State.Knockback:
			mv = move_and_slide(mv)

func on_state_timeout():
	if state == HealerState.Heal:
		state = State.Default
	.on_state_timeout()
	
	
func _on_heal():
	health = min(health + REGEN_AMOUNT, MAX_HEALTH)
	
	for body in heal_area.get_overlapping_bodies():
		if body is Enemy and not body.is_in_group(HEALER_GROUP) and not body == self:
			if body.health < body.MAX_HEALTH:
				body.health += HEAL_AMOUNT
				body.health = min(body.health, body.MAX_HEALTH)
				
				if body.has_node("HealingFX"):
					body.get_node("HealingFX").emitting = true

	
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
