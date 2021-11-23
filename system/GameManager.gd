extends Node

# Scenes

# Singleton objects
var player: Player
var navigation: Navigation2D

# Optimization
var pathfind_offset := 0.0

var pathfind_calls = 0

func _ready():
	pass

func _process(_delta):
	pathfind_calls = 0

func get_pathfind_offset():
	pathfind_offset += 1.0/60.0
	
	return pathfind_offset
