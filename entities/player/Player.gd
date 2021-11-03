extends Entity
class_name Player

# Exports
export var ACCEL_PERCENT := 0.5

# Fields
var take_input := true

# Nodes and scenes
const Bullet = preload("res://entities/projectiles/Bullet.tscn")

onready var gm := $"/root/GameManager"

func _ready():
	gm.player = self

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
	
	_attack()
	
func _attack():
	if Input.is_action_just_pressed("shoot"):
		var bullet = Bullet.instance()
		var angle = get_global_mouse_position().angle_to_point(get_parent().to_global(position))
		var bullet_position = get_parent().to_global(position)
		
		bullet.init(angle, bullet_position)
		
		get_tree().root.add_child(bullet)
