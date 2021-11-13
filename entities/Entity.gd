extends KinematicBody2D
class_name Entity

export var BASE_SPEED := 200

var speed := 0

var floor_vector := Vector2.UP

## Fields
# Vector for current movement
var mv := Vector2.ZERO

func _ready():
	speed = BASE_SPEED

func _physics_process(delta):
	pass
