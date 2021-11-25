extends Node2D
class_name Weapon

export var MAX_AMMO = 500
export var CROSS_HAIR: Texture

# Properties
var weapon_name: String
var active := false

# Fields
var ammo = 0

var crosshair: Texture
var crosshair_offsets

func _ready():
	ammo = MAX_AMMO # Set from export
	
	crosshair = CROSS_HAIR
	crosshair_offsets = Vector2(crosshair.get_width()/2.0, crosshair.get_height()/2.0)
	
func use():
	on_active()
	
func switch():
	Input.set_custom_mouse_cursor(crosshair, 0, crosshair_offsets)
	on_switch()
	
func switch_out():
	on_switch_out()

# Called every frame when active
func on_active():
	pass
	
# Called on the single frame when the weapon is changed to this weapon
func on_switch():
	pass

# Called on the single frame when the weapon is changed from this weapon
func on_switch_out():
	pass
