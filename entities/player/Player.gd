extends Entity
class_name Player

# Exports
export(float, 0.0, 1.0) var ACCEL_PERCENT := 0.5
export var MAX_HP := 100

export var radar_range := 10

# Fields
var hp: float = MAX_HP
var battery := 400
var module_power := 100

var take_input := true

var armor := 1.0

var state: int = State.Default # Using the State enum

# Directions
var legs_dir: int = AnimUtil.Dir.Bottom
var body_dir: int = AnimUtil.Dir.Bottom

# Enums
enum State { Default, Pause, Dead }

# Nodes and scenes
onready var gm = GameManager

onready var body_anim = $Body
onready var legs_anim = $Legs

# Weapons and modules
const MachineGun = preload("res://weapons/MachineGun.tscn")
const Railgun = preload("res://weapons/MiniRailgun.tscn")

var weapons := []
var weapon_ind := 0

const Shield = preload("res://weapons/ShieldModule.tscn")
const Dash = preload("res://weapons/DashModule.tscn")
const Charge = preload("res://weapons/ChargeModule.tscn")

var module: Module

func _ready():
	gm.player = self
	set_collision_layer_bit(GameManager.COL_TILE, false)
	set_collision_layer_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_ENEMY_BULLET, true)

	_init_weapons()
	# Cursor
	Input.set_custom_mouse_cursor(load("res://assets/crosshair.png"), 0, Vector2(24, 24))

func _init_weapons():
	var machine_gun = MachineGun.instance()
	add_child(machine_gun)
	var railgun = Railgun.instance()
	add_child(railgun)
	
	weapons = [machine_gun, railgun]
	weapons[weapon_ind].on_switch()
	
	# Modules
	module = Charge.instance()
	
	add_child(module)
	
func switch_weapon(direction := 1):
	if direction == 0: return
	
	weapons[weapon_ind].active = false
	weapons[weapon_ind].on_switch_out()
	weapon_ind += direction
	
	if weapon_ind >= len(weapons):
		weapon_ind = 0
	if weapon_ind < 0:
		weapon_ind = len(weapons) - 1
		
	weapons[weapon_ind].active = true
	weapons[weapon_ind].on_switch()
	
var move_angle = 0	
		
func _movement_animation(v_input, h_input):
	var move_string = "idle"
	
	
	var aim_angle = AnimUtil.stepify_angle(get_global_mouse_position().angle_to_point(global_position))
	
	body_dir = AnimUtil.Angle2Dir[aim_angle]
	
	if v_input != 0 or h_input != 0:
		move_angle = AnimUtil.stepify_angle(Vector2(h_input, v_input).angle())
		
		legs_dir = AnimUtil.Angle2Dir[move_angle]
		
		move_string = "walk"
		
	var reverse_anim = false

	if abs(MathUtil.angle_diff_deg(move_angle, aim_angle)) > 90:
		move_angle = aim_angle
		legs_dir = AnimUtil.Angle2Dir[move_angle]
		reverse_anim = true
		
		
	legs_anim.flip_h = abs(move_angle) > 90
	body_anim.flip_h = abs(aim_angle) > 90
		
	legs_anim.play("%s_%s" % [move_string, AnimUtil.Dir2Anim[legs_dir]], reverse_anim)
	body_anim.play("%s_%s" % [move_string, AnimUtil.Dir2Anim[body_dir]])
				

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
			
			mv.x = lerp(mv.x, speed * hor_mov, ACCEL_PERCENT)
			mv.y = lerp(mv.y, speed * vert_mov, ACCEL_PERCENT)
			
	mv = move_and_slide(mv)
	
	switch_weapon(int(Input.is_action_just_pressed("next_weapon"))
			- int(Input.is_action_just_pressed("previous_weapon")))
							
	weapons[weapon_ind].on_active()

# States
func on_hit(damage: float):
	hp -= damage * armor
	
