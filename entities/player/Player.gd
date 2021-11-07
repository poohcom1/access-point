extends Entity
class_name Player

# Exports
export(float, 0.0, 1.0) var ACCEL_PERCENT := 0.5
export var MAX_HP := 10

# Fields
var hp := MAX_HP

var take_input := true

# Nodes and scenes
onready var gm := $"/root/GameManager"
onready var weapon

func _ready():
	gm.player = self
	set_collision_layer_bit(ProjectSettings.get_setting("global/ENEMY_BULLET_COL_BIT"), true)

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
	
	mv.x = lerp(mv.x, speed * hor_mov, ACCEL_PERCENT)
	mv.y = lerp(mv.y, speed * vert_mov, ACCEL_PERCENT)

# States
func on_hit(damage):
	hp -= damage
