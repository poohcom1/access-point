extends Node

#CONSTANTS
const PATHFIND_LIMIT_PER_FRAME = 10

## Collision
const COL_TILE = 0
const COL_PLAYER = 1
const COL_ENEMY = 2
const COL_PLAYER_BULLET = 3
const COL_ENEMY_BULLET = 4

# Singleton objects
var player: Player
var navigation: Navigation2D

# Optimization
var pathfind_offset := 0.0
var pathfind_calls = 0
var pathfind_lazy_list = []
var pathfind_lazy_list_done = []

var lazy_path_thread
var lazy_mutex


func _ready():
	lazy_mutex = Mutex.new()
	lazy_path_thread = Thread.new()
	lazy_path_thread.start(self, "lazy_path_function", "Wafflecopter")

func _process(_delta):
	pathfind_calls = 0
	reinsert_path_lazy()

func get_pathfind_offset():
	pathfind_offset += 1.0/60.0
	
	return pathfind_offset


func lazy_path_function(userdata):
	print(userdata)
	while (true):
		OS.delay_msec(10)
		eval_pathfind_lazy()

func eval_pathfind_lazy():
	lazy_mutex.lock()
	var pl_len = len (pathfind_lazy_list)
	lazy_mutex.unlock()
	var count = 0
	while count < PATHFIND_LIMIT_PER_FRAME && count < pl_len:
		count += 1
		
		lazy_mutex.lock()
		var bundle = pathfind_lazy_list[0]
		pathfind_lazy_list.remove(0)
		lazy_mutex.unlock()
		
		var obj = bundle[0]
		var path = navigation.get_simple_path(bundle[1], bundle[2], false)
		
		lazy_mutex.lock()
		pathfind_lazy_list_done.append([obj, path])
		lazy_mutex.unlock()
		
	
func reinsert_path_lazy():
	lazy_mutex.lock()
	var mlen = len(pathfind_lazy_list_done)
	for _z in range(mlen):
		var i = pathfind_lazy_list_done[0]
		if(is_instance_valid(i[0])):
			i[0].path = i[1]
		pathfind_lazy_list_done.remove(0)
	lazy_mutex.unlock()


func add_pathfind_lazy_list(obj):
	lazy_mutex.lock()
	pathfind_lazy_list.append(obj)
	lazy_mutex.unlock()
