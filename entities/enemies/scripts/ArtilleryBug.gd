extends Enemy

# Properties
export var DAMAGE := 20
export var FRIENDLY_DAMAGE := 15
export var PROJECTILE_SPEED = 10

export var SHOOT_INTERVAL := 2.0
export var CHARGE_COUNT = 3

export var RANGE := 175
export var EXPLOSION_FRAMES := 1
export var EXPLODE_ON_WALL := false


# Fields
var _range = 0

# Nodes
const Projectile = preload("res://entities/enemies/objects/ArtilleryProjectile.tscn")

onready var shoot_timer := Timer.new()
onready var aim_beam = $AimBeam

# State
enum State { Start, Idle, Attack, Charge, Death }
var state = State.Start

func _ready():
	_range = RANGE * RANGE
	
	add_child(shoot_timer)
	shoot_timer.start(SHOOT_INTERVAL)
	
	# warning-ignore:return_value_discarded
	shoot_timer.connect("timeout", self, "_flash_or_attack")
	
	_init_animation()

func _physics_process(_delta):
	_anim_process()


func on_shoot():
	var projectile = Projectile.instance()
	
	projectile.position = $Body/Head.global_position - Vector2(0, 16)
	
	projectile.speed = PROJECTILE_SPEED
	projectile.damage = DAMAGE
	projectile.friendly_damage = FRIENDLY_DAMAGE
	projectile.target = $"/root/GameManager".player.position
	projectile.shot_from = self
	projectile.explosion_frames = EXPLOSION_FRAMES
	projectile.explode_on_wall = EXPLODE_ON_WALL
	
	get_tree().root.add_child(projectile)
			
		
func on_hit_knockback(_vector, _time=0.1):
	pass


#===================================================================
#								ANIMATION
#===================================================================

export var SEGMENTS := 6

export var IDLE_LOOP_TIME := 1.2

export var MAX_ATLTITUDE := 7.0
export var SWING_ALTITUDE := 5.0

export var FLASH_TIME := 0.11

export var SHOOT_ANIM_TIME := 0.2
export var SHOOT_RECOVER_TIME := 0.9

onready var sprite_body := $Body
onready var prototype_segment := $Body/Segment
onready var head := $Body/Head

onready var anim_tween := $Body/AnimTween

var segment_flash_ind = 0
var flash_count = 0
var flash_time

var segments := []

# Anim Properties
var altitude := 0.0
var side_swing := 0.0

var to_shoot

func _init_animation():
	# warning-ignore:return_value_discarded
	anim_tween.connect("tween_all_completed", self, "_anim_finished")
	
	segments.append(prototype_segment)
	
	for _i in range(SEGMENTS):
		var segment = prototype_segment.duplicate()
		sprite_body.add_child(segment)

		segment.get_node("Sprite").flip_h = bool(randi() % 2)
		segments.append(segment)
	segments.append(head)
	
	# warning-ignore:return_value_discarded
	$Body/Head/ChargeAnim.connect("animation_finished", self, "_charge_anim_finished")
	# warning-ignore:return_value_discarded
	$Body/Head/Sprite.connect("animation_finished", self, "_head_anim_finished")
		
	_unburrow_anim()

func _anim_process():
	match state:
		State.Death:
			for i in range(segments.size()):
				var segment: Node2D = segments[i]
				
				segment.position.y = -altitude * i
				segment.position.x = sin(i) * side_swing
		
		_:
			for i in range(segments.size()):
				var segment: Node2D = segments[i]
				
				segment.position.y = -altitude * i
				segment.position.x = lerp(0, side_swing, (float(i)/segments.size()) * (float(i)/segments.size()) )
		
func _anim_finished():
	match state:
		State.Start:
			state = State.Idle
			_idle_anim()
		State.Idle:
			_idle_anim()
		State.Charge:
			_idle_anim()
		State.Attack:
			state = State.Idle
			_idle_anim()
			shoot_timer.start(SHOOT_INTERVAL)
			$Body/Head/Sprite.play("default")
		State.Death:
			_create_corpse()
			

# State
func _unburrow_anim():
	anim_tween.interpolate_property(self, "altitude", 0, MAX_ATLTITUDE, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	anim_tween.start()

func _idle_anim():
	# Side
	anim_tween.interpolate_property(self, "side_swing", 0, 5, IDLE_LOOP_TIME,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	anim_tween.interpolate_property(self, "side_swing", 5, 0, IDLE_LOOP_TIME,
		Tween.TRANS_QUAD, Tween.EASE_IN, IDLE_LOOP_TIME)
	anim_tween.interpolate_property(self, "side_swing", 0, -5, IDLE_LOOP_TIME,
		Tween.TRANS_QUAD, Tween.EASE_OUT, IDLE_LOOP_TIME * 2)
	anim_tween.interpolate_property(self, "side_swing", -5, 0, IDLE_LOOP_TIME,
		Tween.TRANS_QUAD, Tween.EASE_IN, IDLE_LOOP_TIME * 3)
	
	# Alt
	anim_tween.interpolate_property(self, "altitude", MAX_ATLTITUDE, SWING_ALTITUDE, IDLE_LOOP_TIME,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	anim_tween.interpolate_property(self, "altitude", SWING_ALTITUDE, MAX_ATLTITUDE, IDLE_LOOP_TIME,
		Tween.TRANS_LINEAR, Tween.EASE_IN, IDLE_LOOP_TIME)
	
	anim_tween.interpolate_property(self, "altitude", MAX_ATLTITUDE, SWING_ALTITUDE, IDLE_LOOP_TIME,
		Tween.TRANS_LINEAR, Tween.EASE_IN, IDLE_LOOP_TIME * 2)
	anim_tween.interpolate_property(self, "altitude", SWING_ALTITUDE, MAX_ATLTITUDE, IDLE_LOOP_TIME,
		Tween.TRANS_LINEAR, Tween.EASE_IN, IDLE_LOOP_TIME * 3)
	
	anim_tween.start()

func shoot_anim():
	anim_tween.remove_all()
	
	anim_tween.interpolate_property(self, "altitude", altitude + 2, 2, SHOOT_ANIM_TIME, 
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	anim_tween.interpolate_property(self, "side_swing", side_swing, 0, SHOOT_ANIM_TIME, 
		Tween.TRANS_LINEAR)
		
	anim_tween.interpolate_property(self, "altitude", 2, MAX_ATLTITUDE, SHOOT_RECOVER_TIME,
		Tween.TRANS_CUBIC, Tween.EASE_IN, SHOOT_ANIM_TIME)
		
	anim_tween.start()
	
func charge_anim():
	_play_charge_anim(segments[segment_flash_ind], flash_count==CHARGE_COUNT-1)
			
	head.get_node("Sprite").speed_scale = 2.0
	
	segment_flash_ind += 1
	if segment_flash_ind >= segments.size():
		flash_time -= 0.03
		
		segment_flash_ind = 0
		flash_count += 1
		
		if flash_count >= CHARGE_COUNT:
			flash_count = 0
			
			$Body/Head/Sprite.play("shoot")
			state = State.Attack
			
			on_shoot()	
			shoot_anim()
			to_shoot = true
			return
			
	shoot_timer.start(flash_time)
	
func on_death():
	z_index = 0
	$Body/FlashTimer.stop()
	shoot_timer.stop()
	
	$CollisionShape2D.set_deferred("disabled", true)
	$ValueBar.queue_free()
	
	state = State.Death
	$Death.play()
	
	anim_tween.remove_all()
	anim_tween.interpolate_property(self, "altitude", altitude, MAX_ATLTITUDE + 1, 0.3,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	anim_tween.interpolate_property(self, "altitude", MAX_ATLTITUDE, 1, 1.7,
		Tween.TRANS_CIRC, Tween.EASE_OUT_IN, 0.3)
	anim_tween.start()
	
	anim_tween.interpolate_property(self, "side_swing", 0, 4, 1.8,
		Tween.TRANS_CIRC, Tween.EASE_OUT)
	
	for segment in segments:
		segment.z_index = 0	
		segment.get_node("ChargeAnim").play("death")
		segment.get_node("Sprite").play("death")
		
		if segment.has_node("Particles"):
			var grad = Gradient.new()
			
			grad.set_color(0, Color.webmaroon)
			grad.set_color(1, Color.crimson)
			
			segment.get_node("Particles").color = Color.crimson
			segment.get_node("Particles").color_ramp = grad
			segment.get_node("Particles").emitting = true

# Helpers

func _flash_or_attack():
	match state:
		State.Idle:
			var player = $"/root/GameManager".player
			if player:
				if global_position.distance_squared_to(player.global_position) < _range:
					state = State.Charge
					flash_time = FLASH_TIME
					segment_flash_ind = 0
					shoot_timer.start(flash_time)
		State.Charge:
			charge_anim()
			
			
func _charge_anim_finished(_data):
	if to_shoot and state != State.Death:
		head.get_node("Sprite").speed_scale = 1.0
		to_shoot = false
		state = State.Attack
		
		flash_count = 0

func _head_anim_finished():
	if $Body/Head/Sprite.animation == "shoot":
		$Body/Head/Sprite.play("default")
		
func _create_corpse():
	var corpse = Node2D.new()
	corpse.global_position = global_position
	get_tree().root.add_child(corpse)

	for segment in segments:
		var sprite = segment.get_node("Sprite")
		var pos = sprite.global_position
		segment.remove_child(sprite)
		
		corpse.add_child(sprite)
		sprite.global_position = pos
	
	queue_free()

func _play_charge_anim(segment, final = false):
	if not final:
		segment.get_node("ChargeAnim").play("charge")
	else:
		segment.get_node("ChargeAnim").play("charge_final")
		
		if segment.has_node("Particles"):
			segment.get_node("Particles").emitting = true
