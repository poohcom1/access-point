extends Entity
class_name Player

# Exports
export(float, 0.0, 1.0) var ACCEL_PERCENT := 0.5
export var MAX_HP := 100

# Fields
var hp := MAX_HP
var battery := 400

var take_input := true

var weapons := []
var weapon_ind := 0

var state: int = State.Default # Using the State enum

# Directions
var legs_dir: int = Dir.Bottom
var body_dir: int = Dir.Bottom

# Enums
enum State { Default, Dead }
enum HDir { Left=1, None=0, Right=2 }
enum VDir { Top=1, None=0, Bottom=2 }

# HDir + VDir * 10
enum Dir {
	None		= 00,
	Left		= 01,
	Right		= 02,
	Top			= 10,
	Bottom		= 20,
	TopLeft		= 11,
	TopRight	= 12,
	BottomLeft	= 21,
	BottomRight	= 22,
}

# Convert -1, 0, 1 to 1, 0, 2
const DirDict = { -1: 1, 0: 0, 1: 2 }

const DirAnim = {
	Dir.Left: "side",
	Dir.Right: "side",
	Dir.Top: "back",
	Dir.Bottom: "front",
	Dir.TopLeft: "sideback",
	Dir.TopRight: "sideback",
	Dir.BottomLeft: "sidefront",
	Dir.BottomRight: "sidefront",
}

const AngleDir = {
	0: Dir.Right,
	45: Dir.BottomRight,
	90: Dir.Bottom,
	135: Dir.BottomLeft,
	180: Dir.Left,
	-180: Dir.Left,
	-135: Dir.TopLeft,
	-90: Dir.Top,
	-45: Dir.TopRight,
	360: Dir.Right,
}


const dir_range = PI/8 # plus-minus each side

# Nodes and scenes
onready var gm := $"/root/GameManager"

onready var body_anim = $Body
onready var legs_anim = $Legs

const MachineGun = preload("res://weapons/MachineGun.tscn")
const Railgun = preload("res://weapons/MiniRailgun.tscn")


func _ready():
	gm.player = self
	set_collision_layer_bit(ProjectSettings.get_setting("global/ENEMY_BULLET_COL_BIT"), true)

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
	
func _movement_animation(v_input, h_input):
	var move_string = "idle"
	
	var aim_angle = int(
		stepify(int(rad2deg(get_global_mouse_position().angle_to_point(global_position))), 45)
	)
	
	var move_angle = int(stepify(rad2deg(Vector2(h_input, v_input).angle()), 45))
	
	body_dir = AngleDir[aim_angle]
	
	if v_input != 0 or h_input != 0:
		legs_dir = AngleDir[move_angle]
		
		move_string = "walk"
		
	var reverse_anim = false

	if abs(MathHelper.angle_difference(move_angle, aim_angle)) > 90:
		move_angle = wrapi(aim_angle, -180, 180)
		legs_dir = AngleDir[move_angle]
		reverse_anim = true
		
		
	legs_anim.flip_h = abs(move_angle) > 90
	body_anim.flip_h = abs(aim_angle) > 90
		
	legs_anim.play("%s_%s" % [move_string, DirAnim[legs_dir]], reverse_anim)
	body_anim.play("%s_%s" % [move_string, DirAnim[body_dir]])
				

func _physics_process(_delta):
	var vert_mov := 0
	var hor_mov := 0
	
	if take_input:
		var up := Input.is_action_pressed("ui_up")
		var down := Input.is_action_pressed("ui_down")
		var left := Input.is_action_pressed("ui_left")
		var right := Input.is_action_pressed("ui_right")
	
		vert_mov = int(down) - int(up)
		hor_mov = int(right) - int(left)
		
		switch_weapon(int(Input.is_action_just_pressed("next_weapon"))
					- int(Input.is_action_just_pressed("previous_weapon")))
					
	_movement_animation(vert_mov, hor_mov)
	
	mv.x = lerp(mv.x, speed * hor_mov, ACCEL_PERCENT)
	mv.y = lerp(mv.y, speed * vert_mov, ACCEL_PERCENT)
	
	mv = move_and_slide(mv)
	
	weapons[weapon_ind].on_active()

# States
func on_hit(damage):
	hp -= damage
	
