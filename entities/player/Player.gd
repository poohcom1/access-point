extends Entity
class_name Player

# Exports
export(float, 0.0, 1.0) var ACCEL_PERCENT := 0.5
export var MAX_HP := 10

# Fields
var hp := MAX_HP

var take_input := true

var weapons := []
var weapon_ind := 0

# Nodes and scenes
onready var gm := $"/root/GameManager"

const MachineGun = preload("res://weapons/MachineGun.tscn")
#const LaserPistol = preload("res://weapons/laser_pistol/LaserPistol.tscn")

func _ready():
	gm.player = self
	set_collision_layer_bit(ProjectSettings.get_setting("global/ENEMY_BULLET_COL_BIT"), true)

	_init_weapons()

func _init_weapons():
	var machine_gun = MachineGun.instance()
	add_child(machine_gun)
	#var laser_pistol = LaserPistol.instance()
	#add_child(laser_pistol)
	
	weapons = [machine_gun]
	pass
	
func switch_weapon(direction := 1):
	weapons[weapon_ind].active = false
	weapon_ind += direction
	
	if weapon_ind >= len(weapons):
		weapon_ind = 0
	if weapon_ind < 0:
		weapon_ind = len(weapons) - 1
		
	weapons[weapon_ind].active = true

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
	
	mv.x = lerp(mv.x, speed * hor_mov, ACCEL_PERCENT)
	mv.y = lerp(mv.y, speed * vert_mov, ACCEL_PERCENT)
	
	mv = move_and_slide(mv)
	
	weapons[weapon_ind].on_active()

# States
func on_hit(damage):
	hp -= damage
