extends Node

#CONSTANTS
const PATHFIND_LIMIT_PER_FRAME = 4

# Singleton objects
var player: Player
var navigation: Navigation2D

# Optimization
var pathfind_offset := 0.0
var pathfind_calls = 0
var pathfind_lazy_list = []

func _ready():
	pass

func _process(_delta):
	pathfind_calls = 0
	evalPathfindLazy()

func get_pathfind_offset():
	pathfind_offset += 1.0/60.0
	
	return pathfind_offset


func evalPathfindLazy():
	var pl_len = len (pathfind_lazy_list)
	var count = 0
	while count < PATHFIND_LIMIT_PER_FRAME && count < pl_len:
		count += 1
		var bundle = pathfind_lazy_list[0]
		var obj = bundle[0]
		if(is_instance_valid(obj)):
			obj.path = navigation.get_simple_path(bundle[1], bundle[2], false)
		pathfind_lazy_list.remove(0)
	
