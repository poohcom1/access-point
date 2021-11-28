extends Weapon

# Properties
export var SHOOT_INTERVAL = 0.15
export var DAMAGE = 8
export var MIN_DAMAGE = 1
export var FALLOFF = 30

export var SPEED := 2

export var SFX: AudioStream

# Fields
var shooting := false

var just_switched_on := false

var queue_shoot := false

# Nodes
const Bullet = preload("res://weapons/objects/FlameParticle.tscn")

onready var shoot_timer := Timer.new()


var player_speed = Vector2.ZERO
var previous: Vector2

func _ready():
	add_child(shoot_timer)
	shoot_timer.one_shot = true
	shoot_timer.start(SHOOT_INTERVAL)
	# warning-ignore:return_value_discarded
	shoot_timer.connect("timeout", self, "on_shoot")

	previous = player.global_position

func _physics_process(_delta):
	player_speed = player.global_position - previous
	previous = player.global_position

func on_shoot():
	if (not queue_shoot and not shooting) or not can_shoot(): 
		return
		
	player.flash()
	
	queue_shoot = false
	
	ammo -= 1
	
	var bullet = Bullet.instance()
	
	var vector_to_point = get_global_mouse_position() - global_position
	
	bullet.angle = vector_to_point.angle()
	bullet.damage = DAMAGE
	bullet.min_damage = MIN_DAMAGE
	bullet.falloff_amount = FALLOFF
	bullet.global_position = global_position
	
	bullet.offset = player_speed.project(vector_to_point)
	
	get_tree().root.add_child(bullet)
	
	shoot_timer.start()

	
	add_child(OneShotAudio2D.new(SFX, 2.0))

	
func on_active():
	if Input.is_action_pressed("shoot") and ammo > 0:
		shooting = true
		if Input.is_action_just_pressed("shoot"):
			queue_shoot = true
			
			if just_switched_on or shoot_timer.time_left == 0:
				on_shoot()
				just_switched_on = false

	else:
		shooting = false

func on_switch():
	just_switched_on = true

func on_switch_out():
	on_stop_shoot()
	just_switched_on = false
	
func on_stop_shoot():
	shooting = false
