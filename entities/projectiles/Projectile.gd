tool
extends Area2D
class_name Projectile

export var damage: int = 1
var angle: float = 0.0
var speed: float = 500

var pass_through := false

onready var sprites := $AnimatedSprite

# Factory
static func create_bullet(BulletScn: PackedScene, parent: Node2D, start: Vector2, target: Vector2, _speed=500) -> Projectile:
	var bullet = BulletScn.instance()
	
	bullet.angle = target.angle_to_point(start)
	bullet.position = start
	bullet.speed = _speed
	
	parent.get_tree().root.add_child(bullet)
	
	return bullet

static func create_bullet_here(BulletScn: PackedScene, parent: Node2D, target: Vector2, _speed=500) -> Projectile:
	var bullet = BulletScn.instance()
	var start = parent.get_parent().to_global(parent.position)
	
	bullet.angle = target.angle_to_point(start)
	bullet.position = start
	bullet.speed = _speed
	
	parent.get_tree().root.add_child(bullet)
	
	return bullet

func _ready():
	# warning-ignore: return_value_discarded
	connect("body_entered", self, "on_hit")
	
	sprites.rotation = angle
	
func _physics_process(delta):
	position += Vector2(cos(angle), sin(angle)) * speed * delta

func on_hit(_other: Node2D):
	pass

