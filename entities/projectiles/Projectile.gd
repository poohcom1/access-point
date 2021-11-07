extends KinematicBody2D
class_name Projectile

export var damage: int = 1
export var angle: float = 0.0 
export var speed: float = 10
export var MAX_BOUNCES: int = 1

var bounce_count := 0

var pass_through := false

# Field
var _direction_vector := Vector2.ZERO




# Factory
"""
	Creates a bullet given a scene, and attaches it to the tree root
"""
static func create_bullet(BulletScn: PackedScene, parent: Node2D, start: Vector2, target: Vector2, override_speed=null) -> Projectile:
	var bullet = BulletScn.instance()
	
	bullet.angle = target.angle_to_point(start)
	bullet.position = start
	if override_speed != null:
		bullet.speed = override_speed
	
	parent.get_tree().root.add_child(bullet)
	
	return bullet

"""
	Creates a bullet at the parent location
"""
static func create_bullet_here(BulletScn: PackedScene, parent: Node2D, target: Vector2, override_speed=null) -> Projectile:
	var start = parent.global_position
	
	return create_bullet(BulletScn, parent, start, target, override_speed)

func _ready():
	_direction_vector = Vector2(cos(angle), sin(angle))
	set_collision_mask_bit(ProjectSettings.get_setting("global/TILEMAP_COL_BIT"), true)
	
	
func _physics_process(_delta):
	var collision := move_and_collide(_direction_vector * speed)
	
	if collision:
		_on_hit(collision)
		

func _on_hit(col: KinematicCollision2D):
	# On Wall hit
	if col.collider is TileMap:
		# Bounce using the collision normal
		_direction_vector = _direction_vector.bounce(col.normal)
		
		if bounce_count	>= MAX_BOUNCES:
			on_wall_hit()
			
		# Record bounce
		bounce_count += 1
	else:
		# On entity hit
		on_hit(col.collider, angle)

# Virtual function for implemented classes
func on_hit(_other: Node2D, _angle: float):
	pass
	
# Virtual function for implemented classes
func on_wall_hit():
	queue_free()

