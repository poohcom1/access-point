extends KinematicBody2D
class_name Entity

export var BASE_SPEED := 200
export var MAX_HEALTH := 20
const floor_vector := Vector2.UP

# Fields
var speed := 0
var health

# Vector for current movement
var mv := Vector2.ZERO


const BURN_TIME = 5
var burn_timer = 0

# Virtuals ==============================
func _ready():
	speed = BASE_SPEED

func _physics_process(delta):
	if burn_timer > 0:
		on_hit(0.01)
		burn_timer -= delta

# Methods
func add_health(amount):
	health = min(health + amount, MAX_HEALTH)

func ignite(burn_time=BURN_TIME):
	burn_timer = burn_time

func is_burning() -> bool:
	return burn_timer > 0


# Overrides
func on_hit(dmg, _from=null, _type: String = ""):
	if is_burning():
		dmg *= 1.5
		
	health -= dmg
