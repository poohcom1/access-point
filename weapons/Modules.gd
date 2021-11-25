extends Node2D
class_name Module

onready var player: KinematicBody2D = get_parent()

export var module_name: String

var active = false

func _physics_process(_delta):
	if not active:
		player.energy = min(player.energy + player.MODULE_CHARGE_SPEED, player.MAX_ENERGY)

