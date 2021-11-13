extends Node2D
class_name Weapon

export var MAX_AMMO = 300

# Properties
var weapon_name: String
var active := false

# Fields
var ammo = MAX_AMMO

# Called every frame when active
func on_active():
	pass
