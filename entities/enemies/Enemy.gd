extends Entity
class_name Enemy

export var health := 10

const group = "enemy"

signal on_damage(dmg)
signal on_death()

func _ready():
	add_to_group(group)
	set_collision_layer_bit(ProjectSettings.get("global/TILEMAP_COL_BIT"), false)
	set_collision_layer_bit(ProjectSettings.get("global/PLAYER_BULLET_COL_BIT"), true)

func on_hit(dmg: int, angle: float):
	health -= dmg
	
	emit_signal("on_damage", dmg)
	
	if health == 0:
		on_death()
		emit_signal("on_death")

	on_hit_knockback(angle)
	
func on_hit_knockback(angle):
	position += Vector2(cos(angle), sin(angle)) * 5
		
func on_death():
	pass
