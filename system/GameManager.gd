extends Node

## Collision
const COL_TILE = 0
const COL_PLAYER = 1
const COL_ENEMY = 2
const COL_PLAYER_BULLET = 3
const COL_ENEMY_BULLET = 4

# Signals
# warning-ignore:unused_signal
signal aggro_alert(position, target)

# Singleton objects
var player: Player
var navigation: Navigation2D
var stage
var minimap
var ui: UI
var dialogue: DialogueController

# Optimization V2
var pathfind_lazy_list = []
var pathfind_lazy_list_done = []
var lazy_path_thread
var lazy_mutex
var lazy_semaphore
var exiter_mutex
var exit_thread = 0

# Debug
var static_counter = 0

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
	lazy_path_thread.start(self, "lazy_path_function")

### SPAWNERS
var spawn_queue := []
var spawn_skip

func add_to_scene(node: Object):
	stage.add_child(node)

func _process(_delta):
	reinsert_path_lazy()

	# Spawners
	if spawn_queue.size() > 0:
		get_tree().root.call_deferred("add_child", spawn_queue.pop_back())

func lazy_path_function(_userdata):
	while (true):
		lazy_semaphore.wait()
		
		exiter_mutex.lock()
		var exiter_local = exit_thread
		exiter_mutex.unlock()
		
		if(exiter_local == 1):
			break
		
		eval_pathfind_lazy()
		

func eval_pathfind_lazy():
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
	
	#pathfind_lazy_list.append(obj)
	var found = false
	for i in range(pathfind_lazy_list.size()):
		if pathfind_lazy_list[i][0] == obj[0]:
			pathfind_lazy_list[i][1] = obj[1]
			pathfind_lazy_list[i][2] = obj[2]
			found = true
			break
	if not found:
		pathfind_lazy_list.append(obj)
		lazy_semaphore.post()
		
	lazy_mutex.unlock()
	#lazy_semaphore.post()



