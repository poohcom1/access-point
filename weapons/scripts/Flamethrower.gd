extends Weapon

# Properties
export var SHOOT_INTERVAL = 0.15
export var DAMAGE := 0.05
export var MIN_DAMAGE := 0.01
export var FALLOFF = 30
export var SPEED := 2


# Nodes
const Bullet = preload("res://weapons/objects/FlameParticle.tscn")

onready var shoot_timer := Timer.new()
onready var sfx_start := $SFXStart
onready var sfx_old := $SFXHold

var player_speed = Vector2.ZERO
var previous: Vector2

func _ready():
	add_child(shoot_timer)
	shoot_timer.start(SHOOT_INTERVAL)
	shoot_timer.connect("timeout", self, "on_shoot")

	previous = player.global_position

func _physics_process(_delta):
	player_speed = player.global_position - previous
	previous = player.global_position

func on_shoot():
	if (not active
		or not can_shoot()
		or player.state == player.State.Pause): 
		return
		
	player.flash()
	
	ammo -= 1
	
	var bullet = Bullet.instance()
	
	var vector_to_point = get_global_mouse_position() - global_position
	
	bullet.angle = vector_to_point.angle()
	bullet.speed = SPEED
	
	bullet.damage = DAMAGE
	
	bullet.min_damage = MIN_DAMAGE
	bullet.falloff_amount = FALLOFF
	bullet.global_position = global_position
	
	var offset = player_speed.project(vector_to_point)
	
	bullet.offset = offset
	
	GameManager.add_to_scene(bullet)
	
	shoot_timer.start()

	
func on_active():
	if Input.is_action_pressed("shoot") and ammo > 0:
		on_start_shoot_()
		
	else:
		on_stop_shoot_()
		sfx_start.stop()


func on_switch_out():
	on_stop_shoot_()
	
func on_start_shoot_():
	.on_start_shoot_()
	if not sfx_start.playing:
		sfx_start.play()
	
func on_stop_shoot_():
	.on_stop_shoot_()
	sfx_start.stop()
	player.flash_off()
	
