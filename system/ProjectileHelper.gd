extends KinematicBody2D
class_name ProjectileUtil


# Factory
"""
	Creates a bullet given a scene, and attaches it to the tree root
"""
static func create_bullet(BulletScn: PackedScene, parent: Node2D, start: Vector2, target: Vector2, override_speed=null) -> Bullet:
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
static func create_bullet_here(BulletScn: PackedScene, parent: Node2D, target: Vector2, override_speed=null) -> Bullet:
	var start = parent.global_position
	
	return create_bullet(BulletScn, parent, start, target, override_speed)

class Bullet extends Node2D:
	var angle: float
	var speed: float
	var damage: float

