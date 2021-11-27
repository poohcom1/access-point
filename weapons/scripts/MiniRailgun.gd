extends Weapon

# Properties
export var SHOOT_INTERVAL = 0.15
export var PIERCE_COUNT = 1
export var DAMAGE = 8
export var MIN_DAMAGE = 1
export var MIN_DISTANCE = 100
export var MAX_DISTANCE = 200
export var KNOCKBACK = 25

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
	shoot_timer.start(SHOOT_INTERVAL)
	# warning-ignore:return_value_discarded
	shoot_timer.connect("timeout", self, "on_shoot")
	
	weapon_name = "Mini-Railgun"

func on_shoot():
	if (not queue_shoot or not shooting) or not can_shoot(): return
	
	ammo -= 1
	
	var bullet = ProjectileUtil.create_bullet_here(Bullet, 
		self, 
		get_global_mouse_position())
	
		
	bullet.pierce_count = PIERCE_COUNT + 1 # Add one so 0 is the baseline for no pierce
	bullet.damage = DAMAGE
	#bullet.min_damage = MIN_DAMAGE
	bullet.knockback = KNOCKBACK
	
	shoot_timer.start()
	
func calculate_damage(distance: float):
	var percent = inverse_lerp(MIN_DISTANCE, MAX_DISTANCE, distance)
	
	return lerp(DAMAGE, MIN_DAMAGE, clamp(percent, 0.0, 1.0))

func on_active():
	if Input.is_action_pressed("shoot") and ammo > 0:
		shooting = true
		if Input.is_action_just_pressed("shoot"):
			queue_shoot = true
			
			if just_switched_on:
				on_shoot()
				just_switched_on = false

	else:
		shooting = false

func on_switch():
	just_switched_on = true

func on_switch_out():
	shooting = false
	just_switched_on = false
