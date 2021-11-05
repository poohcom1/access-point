extends Projectile

func _ready():
	set_collision_mask_bit(ProjectSettings.get_setting("global/PLAYER_BULLET_COL_BIT"), true)

func on_hit(other: Node2D):
	if other is Enemy:
		other.on_hit(damage)
		
		if not pass_through:
			queue_free()
