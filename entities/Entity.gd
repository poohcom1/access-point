extends KinematicBody2D
class_name Entity

export var BASE_SPEED := 200

var speed := BASE_SPEED

var floor_vector := Vector2.UP

## Fields
# Vector for current movement
var mv := Vector2.ZERO

func _physics_process(delta):
	on_update(delta)

func on_update(_delta):
	mv = move_and_slide(mv, floor_vector)
