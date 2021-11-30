extends Structure
class_name DestructableStructure

func _ready():
	add_to_group("map")
	set_collision_layer_bit(GameManager.COL_ENEMY, true)

func on_hit_knockback(_vector=null, _time=null):
	pass
