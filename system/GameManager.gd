extends Node

# Singleton objects
var player: Player
var navigation: Navigation2D

# Optimization
var pathfind_offset := 0.0
var pathfind_calls = 0
# Optimization V2
var pathfind_lazy_list = []
var pathfind_lazy_list_done = []
var lazy_path_thread
var lazy_mutex
var lazy_semaphore
var exiter_mutex
var exit_thread = 0


func _exit_tree():
	exiter_mutex.lock()
	exit_thread = 1
	lazy_semaphore.post();lazy_semaphore.post();lazy_semaphore.post()
	exiter_mutex.unlock()
	lazy_path_thread.wait_to_finish()
	

func _ready():
	lazy_mutex = Mutex.new()
	exiter_mutex = Mutex.new()
	lazy_semaphore = Semaphore.new()
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
		lazy_semaphore.wait()
		
		exiter_mutex.lock()
		var exiter_local = exit_thread
		exiter_mutex.unlock()
		
		if(exiter_local == 1):
			break
		
		evalPathfindLazy()


func evalPathfindLazy():
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
	lazy_semaphore.post()
