extends Projectile

func on_hit(other: Node2D):
	if other is Player:
		other.on_hit(damage)
		
		if not pass_through:
			queue_free()
