extends Node2D
class_name Weapon

export var MAX_AMMO = 300

# Properties
var weapon_name: String
var active := false

# Fields
var ammo = 0

func _ready():
	ammo = MAX_AMMO # Set from export

# Called every frame when active
func on_active():
	pass
	
# Called on the single frame when the weapon is changed to this weapon
func on_switch():
	pass

# Called on the single frame when the weapon is changed from this weapon
func on_switch_out():
	pass
