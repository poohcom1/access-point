extends Entity
class_name Enemy

const DAMAGE_NUMBERS = false

# Properties
export var value := 0
export var enemy_class := ""

export var revealed := false

const groups := ["enemy", "map"]
const OFF_SCREEN = 250


# Fields
var is_dead = false

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


# Virtual function for receiving damage
func on_hit(dmg: float, _from=null, _type: String = ""):
	if health <= 0:
		if not is_dead:
			on_death()
		return
	
	if DAMAGE_NUMBERS:
		if is_instance_valid(dmg_num):
			dmg_num.queue_free()
		
		dmg_num = DmgNum.instance()
		dmg_num.num = ceil(dmg)
		dmg_num.global_position = global_position
		GameManager.add_to_scene(dmg_num)

	emit_signal("on_damage", dmg)
	
	.on_hit(dmg)
	
	if health <= 0:
		is_dead = true
		emit_signal("on_death")
		on_death()

# Virtual function to call on death
func on_death():
	pass
	
