extends Node

# Scenes

# Singleton objects
var player: Player

func _ready():
	pass

"""
	Returns a yield until all singletons (such as player) are registered
"""
func yield_singletons():
	return yield(get_tree(), "idle_frame")
