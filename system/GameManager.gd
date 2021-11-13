extends Node

# Scenes

# Singleton objects
var player: Player
var navigation: Navigation2D

func _ready():
	pass

"""
	Returns a yield until all singletons (such as player) are registered
	You're probably better off just null checking idk
"""
func yield_singletons():
	return yield(get_tree(), "idle_frame")
