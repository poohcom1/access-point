extends Entity
class_name Enemy

export var health := 10

signal on_damage(dmg)
signal on_death()

func on_hit(dmg):
	health -= dmg
	
	emit_signal("on_damage", dmg)
	
	if health == 0:
		on_death()
		emit_signal("on_death")
		
func on_death():
	pass
