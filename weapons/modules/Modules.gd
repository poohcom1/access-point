extends Node2D
class_name Module

const TYPE_ATTACK = 0
const TYPE_DEFENSE = 1
const TYPE_DASH = 2

onready var player: KinematicBody2D = get_parent()

export var ENERGY_COST := 1
export var module_name: String
export({Attack=TYPE_ATTACK, Defense=TYPE_DEFENSE, Dash=TYPE_DASH}) var TYPE: int

var input: String
var active = false

func _physics_process(_delta):
	if not active:
		player.energy = min(player.energy + player.MODULE_CHARGE_SPEED, player.MAX_ENERGY)

# Intercepts player damage
func on_damage(dmg, _attacker) -> int:
	return dmg
