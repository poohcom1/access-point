extends Area2D

var damage: int = 1
var angle: float = 0.0
var speed: float = 10

var pass_through := false

onready var sprites := $AnimatedSprite

func init(_angle, _position):
	angle = _angle
	position = _position

func _ready():
	# warning-ignore
	connect("body_entered", self, "on_damage")
	
	sprites.rotation = angle
	

func _physics_process(delta):
	position += Vector2(cos(angle), sin(angle)) * speed

func on_damage(other: Node2D):
	if other is Enemy:
		other.on_hit(damage)
		
		if not pass_through:
			queue_free()
