extends Node
class_name ScreenShaker

enum Curve {FLAT, LINEAR_DOWN, QUADRATIC_UP_DOWN, EXP_DOWN}

func _ready():
	pass # Replace with function body.

var camera_tracker = 0
var rseed = 0
var CAMERA_SHAKE_RATE = 0.01
var camera_delta_cumulative = 0
var camera_shake_power = 0.002
var shaking = false

func _process(delta):
	process_shaker()
	if shaking:
		camera_delta_cumulative += delta
		if(camera_delta_cumulative > CAMERA_SHAKE_RATE):
			camera_delta_cumulative = 0
			rseed = ((rseed + 3) & 7)
			GameManager.player.camera_module.offset_h = camera_tracker * camera_shake_power * (rseed - 4)
			rseed = ((rseed + 2) & 7)
			GameManager.player.camera_module.offset_v = camera_tracker * camera_shake_power * (rseed - 4)
			camera_tracker = (camera_tracker + 1) % 2
	else:
		GameManager.player.camera_module.offset_h = 0
		GameManager.player.camera_module.offset_v = 0

var curve = Curve.FLAT
var duration = -1
var max_power = 0.01
var now_frame = 0
var current_priority = -1

func start_shaker(_curve, _duration, _max_power, _priority):

	if _priority >= current_priority:
		current_priority = _priority
		shaking = true
		self.curve = _curve
		self.duration = _duration
		self.max_power = _max_power
		self.now_frame = 0
	
func process_shaker():
	if duration != -1 and now_frame > duration:
		stop_shaker(current_priority)
		return
		
	var now_ratio = float(now_frame)/duration
	if curve == Curve.LINEAR_DOWN:
		camera_shake_power = ((-1 * now_ratio) + 1) * max_power
	elif curve == Curve.QUADRATIC_UP_DOWN:
		camera_shake_power = (-1.2*now_ratio*now_ratio + 0.6*now_ratio + 0.7) * max_power
	elif curve == Curve.EXP_DOWN:
		camera_shake_power = (exp(-4*now_ratio)) * max_power
	elif curve == Curve.FLAT:
		camera_shake_power = max_power
	now_frame += 1

func stop_shaker(priority):
	if priority >= current_priority:
		current_priority = -1
		now_frame = 0
		shaking = false
	
