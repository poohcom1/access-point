extends Node
class_name Knockback

enum Curve {FLAT, EXP_DOWN}

func _ready():
	pass # Replace with function body.


var knockback_vector : Vector2
var knockback_power : float
var knockback_max_power
var knockback_frame_index
var knockback_max_duration
var decay_curve

var knocking = false

func _process(delta):
	if knocking:
		process_knockback()
		GameManager.player.position += (knockback_vector * knockback_power)


func start_knockback(max_power, duration, m_decay_curve):
	decay_curve = m_decay_curve
	knockback_max_duration = duration
	knockback_power = float(max_power)
	knockback_max_power = float(max_power)
	var mouse := GameManager.player.get_global_mouse_position()
	var player_position := GameManager.player.global_position
	knockback_vector = (player_position - mouse).normalized()
	knockback_frame_index = 0
	knocking = true
	
func process_knockback():
	if knockback_frame_index < knockback_max_duration:
		var ratio = float(knockback_frame_index) / knockback_max_duration
		if decay_curve == Curve.EXP_DOWN:
			knockback_power = float(knockback_max_power) * exp(-4*ratio)
		elif decay_curve == Curve.FLAT:
			knockback_power = knockback_max_power
		knockback_frame_index += 1
	else:
		knocking = false
