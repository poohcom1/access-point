extends Entity
class_name Player, "res://assets/player/walk_front_body.png"

# Exports
export(float, 0.0, 1.0) var ACCEL_PERCENT := 0.5

export var MAX_ENERGY := 1000

export var MODULE_CHARGE_SPEED := 2

export var radar_range := 30

export var DEFENSE_MODULE: PackedScene
export var ATTACK_MODULE: PackedScene
export var DASH_MODULE: PackedScene

export var REGEN_DELAY := 5.0
export var REGEN_PER_FRAME = 0.05

export var USE_NATURAL_DIAGONAL_MOVESPEED = true
export var BOBBING_STAND = 0.3
export var BOBBING_MOVE = 0.9


# Fields
var battery := 400
var energy := 100

var take_input := true

var state: int = State.Default # Using the State enum

# Directions
var legs_dir: int = AnimUtil.Dir.Bottom
var body_dir: int = AnimUtil.Dir.Bottom

# Enums
enum State { Default, Pause, Dead }

# Nodes and scenes
onready var body_anim = $Body
onready var legs_anim = $Legs
onready var footstep_sfx = $Footsteps

onready var footstep_part = $FootstepParts

onready var flash_anim = $Flash
onready var regen_timer := $RegenTimer

var screen_shaker_module
var camera_module
var knockback_module

# Signals
signal on_damage(damage)

# Weapons and modules
export(Array, PackedScene) var WEAPONS

var weapon: Weapon setget _set_weapon, _get_weapon
var weapons := []
var weapon_ind := 0

var attack_module: Module
var dash_module: Module
var defense_module: Module

var default_body_position

func _ready():
	screen_shaker_module = $ScreenShaker
	camera_module = $Camera2D
	knockback_module = $Knockback
	health = MAX_HEALTH
	energy = MAX_ENERGY
	GameManager.player = self
	set_collision_layer_bit(GameManager.COL_TILE, false)
	set_collision_layer_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_ENEMY_BULLET, true)

	LoadingScreen.connect("start_scene", self, "_init_weapons")

	default_body_position = body_anim.position

func _init_weapons():
	for Wep in WEAPONS:
		var wep = Wep.instance()
		weapons.append(wep)
		add_child(wep)
	
	
	weapons[weapon_ind].switch()
	
	# Modules
	if ATTACK_MODULE:
		attack_module = ATTACK_MODULE.instance()
		attack_module.input = "attack_module"
		add_child(attack_module)
		
	
	if DEFENSE_MODULE:
		defense_module = DEFENSE_MODULE.instance()
		defense_module.input = "defense_module"
		add_child(defense_module)
		
		
	if DASH_MODULE:	
		dash_module = DASH_MODULE.instance()
		dash_module.input = "dash_module"
		add_child(dash_module)
	
	
func switch_weapon(direction := 1):
	if direction == 0: return
	
	weapons[weapon_ind].active = false
	weapons[weapon_ind].switch_out()
	weapon_ind += direction
	
	if weapon_ind >= len(weapons):
		weapon_ind = 0
	if weapon_ind < 0:
		weapon_ind = len(weapons) - 1
		
	weapons[weapon_ind].active = true
	weapons[weapon_ind].switch()
	
var move_angle = 0	
var sfx_position: float = 0
		
func _movement_animation(v_input, h_input):
	var move_string = "idle"
	
	
	var aim_angle = AnimUtil.stepify_angle(get_global_mouse_position().angle_to_point(global_position))
	
	body_dir = AnimUtil.Angle2Dir[aim_angle]
	
	if v_input != 0 or h_input != 0:
		move_angle = AnimUtil.stepify_angle(Vector2(h_input, v_input).angle())
		
		legs_dir = AnimUtil.Angle2Dir[move_angle]
		
		move_string = "walk"
		
		if not footstep_sfx.playing:
			footstep_sfx.play(sfx_position)
			footstep_part.emitting = true
	else:
		if footstep_sfx.playing:
			sfx_position = footstep_sfx.get_playback_position()
			footstep_part.emitting = false			
			footstep_sfx.stop()
		
	var reverse_anim = false

	if abs(MathUtil.angle_diff_deg(move_angle, aim_angle)) > 90:
		move_angle = aim_angle
		legs_dir = AnimUtil.Angle2Dir[move_angle]
		reverse_anim = true
		
		
	legs_anim.flip_h = abs(move_angle) > 90
	body_anim.flip_h = abs(aim_angle) > 90
	flash_anim.flip_h = body_anim.flip_h
		
	legs_anim.play("%s_%s" % [move_string, AnimUtil.Dir2Anim[legs_dir]], reverse_anim)
	body_anim.play("%s_%s" % [move_string, AnimUtil.Dir2Anim[body_dir]])
	flash_anim.play(AnimUtil.Dir2Anim[body_dir])
	
	if do_flash > 0:
		do_flash -= 1
		if do_flash == 0:
			flash_anim.visible = false
	
	if v_input != 0 or h_input != 0:
		if count > 20 and (not state_shifted):
			state_shifted = true
			count = 0
			body_anim.position.y = body_anim.position.y + BOBBING_MOVE
		elif count > 10 and state_shifted:
			state_shifted = false
			count += 1
			body_anim.position = default_body_position
		else:
			count += 1
	else:
		if count > 40 and (not state_shifted):
			state_shifted = true
			count = 0
			body_anim.position.y = body_anim.position.y + BOBBING_STAND
		elif count > 20 and state_shifted:
			state_shifted = false
			count += 1
			body_anim.position = default_body_position
		else:
			count += 1
	flash_anim.position.y = body_anim.position.y
	

var count = 0			
var state_shifted = false

func _input(event):
	if event.is_pressed() and event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			switch_weapon(1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			switch_weapon(-1)
		
	# Weapons
	switch_weapon(int(Input.is_action_just_pressed("next_weapon"))
			- int(Input.is_action_just_pressed("previous_weapon")))
	
	if take_input and weapons.size() > 0 and weapons[weapon_ind]:
		weapons[weapon_ind].use()


func _physics_process(_delta):
	match state:
		State.Default:
			var vert_mov := 0
			var hor_mov := 0
			
			if take_input:
				var up := Input.is_action_pressed("ui_up")
				var down := Input.is_action_pressed("ui_down")
				var left := Input.is_action_pressed("ui_left")
				var right := Input.is_action_pressed("ui_right")
			
				vert_mov = int(down) - int(up)
				hor_mov = int(right) - int(left)
				
			_movement_animation(vert_mov, hor_mov)
			
			var local_speed = speed
			if(hor_mov != 0 and vert_mov != 0 and USE_NATURAL_DIAGONAL_MOVESPEED):
				local_speed *= 0.707106781
			
			mv.x = lerp(mv.x, local_speed * hor_mov, ACCEL_PERCENT)
			mv.y = lerp(mv.y, local_speed * vert_mov, ACCEL_PERCENT)
			#print(sqrt(mv.x*mv.x + mv.y*mv.y))
		State.Dead:
			legs_anim.play("death")
			
		
	# Move
	mv = move_and_slide(mv)
	
	# Regen
	if regen_timer.time_left == 0 and health < MAX_HEALTH:
		health += REGEN_PER_FRAME
		
var do_flash = 0
		
func flash():
	flash_anim.visible = true
	do_flash = 2
	
func flash_on():
	flash_anim.visible = true

func flash_off():
	flash_anim.visible = false

# States
func on_hit(damage: float, from=null, _type: String = ""):
	if health <= 0:
		return
	regen_timer.start(REGEN_DELAY)
	damage = defense_module.on_damage(damage, from)
	emit_signal("on_damage", damage)
	
	screen_shaker_module.start_shaker(screen_shaker_module.Curve.QUADRATIC_UP_DOWN, 70, 0.006, 2)
	
	.on_hit(damage)
	
	if health <= 0 and state != State.Dead:
		health = 0
		state = State.Dead
		on_death()

func _set_weapon(val):
	weapon_ind = weapons.find(val)
	
func _get_weapon():
	if weapons.size() > 0:
		return weapons[weapon_ind]
	return null

func on_death():
	mv = Vector2.ZERO
	body_anim.visible = false
	flash_anim.visible = false
	take_input = false
	legs_anim.play("death")

	LoadingScreen.game_over()
