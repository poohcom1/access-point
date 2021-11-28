extends Entity
class_name Enemy

const DAMAGE_NUMBERS = true

# Properties
export var MAX_HEALTH := 20.0
export var value := 0
export var enemy_class := ""

export var revealed := false

const groups := ["enemy", "map"]
const OFF_SCREEN = 250


# Fields
var health := 0.0 # Set in ready from max_health

# Signals
signal on_damage(dmg)
signal on_death()

# Scenes
const DmgNum = preload("res://ui/DamageNumbers.tscn")
var dmg_num

# Setup
func _ready():
	if Engine.editor_hint: return
	
	health = MAX_HEALTH
	
	for group in groups:
		add_to_group(group)
	set_collision_layer_bit(GameManager.COL_TILE, false)
	set_collision_mask_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_ENEMY, true)
	set_collision_layer_bit(GameManager.COL_PLAYER_BULLET, true)


func on_hit(dmg: int):
	if health <= 0:
		return
	
	if DAMAGE_NUMBERS:
		if is_instance_valid(dmg_num):
			dmg_num.queue_free()
		
		dmg_num = DmgNum.instance()
		dmg_num.num = dmg
		dmg_num.global_position = global_position
		get_tree().root.add_child(dmg_num)

	
	health -= dmg
	health = min(health, MAX_HEALTH)
	
	emit_signal("on_damage", dmg)
	
	if health <= 0:
		emit_signal("on_death")
		on_death()


func on_death():
	pass
	
