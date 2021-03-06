extends Weapon

# Properties
export var SHOOT_INTERVAL = 0.15
export var PIERCE_COUNT = 1
export var DAMAGE = 8
export var MIN_DAMAGE = 1
export var KNOCKBACK = 25
export var FALLOFF = 50

export var SFX: AudioStream

# Fields
var shooting := false

var just_switched_on := false

var queue_shoot := false

# Nodes
const Bullet = preload("res://weapons/objects/RailgunProjectile.tscn")

onready var shoot_timer := Timer.new()

# Signals

func _ready():
	add_child(shoot_timer)
	shoot_timer.one_shot = true
	shoot_timer.start(SHOOT_INTERVAL)
	# warning-ignore:return_value_discarded
	shoot_timer.connect("timeout", self, "on_shoot")
	
	weapon_name = "Mini-Railgun"

func on_shoot():
	if (not queue_shoot and not shooting) or not can_shoot(): 
		return
	GameManager.player.screen_shaker_module.start_shaker(GameManager.player.screen_shaker_module.Curve.QUADRATIC_UP_DOWN, 40, 0.006, 2)
	
		
	get_parent().flash()
	
	queue_shoot = false
	
	ammo -= 1
	
	var bullet = ProjectileUtil.create_bullet_here(Bullet, 
		self, 
		get_global_mouse_position())
	
		
	bullet.pierce_count = PIERCE_COUNT + 1 # Add one so 0 is the baseline for no pierce
	bullet.damage = DAMAGE
	bullet.min_damage = MIN_DAMAGE
	bullet.falloff = FALLOFF
	bullet.knockback = KNOCKBACK
	
	shoot_timer.start()
	
	add_child(OneShotAudio2D.new(SFX, 2.0))



func on_active():
	if Input.is_action_pressed("shoot") and ammo > 0:
		shooting = true
		if Input.is_action_just_pressed("shoot"):
			queue_shoot = false
			
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
