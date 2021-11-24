extends Node

var main_thread: Thread

var navigation: Navigation2D
var _exit_main_thread := false

"""
This shit doesn't work when there like more than 20 enemies so its useless
"""

func _ready():
	yield(get_tree(), "idle_frame")
	
	main_thread = Thread.new()
	# warning-ignore:return_value_discarded
	main_thread.start(self, "_pathfind_loop")


func _pathfind_loop(_data):
	
	var previous_time = OS.get_ticks_msec()
	
	while true:
		if _exit_main_thread:
			break
			
		for enemy in get_tree().get_nodes_in_group("melee_bug"):
			while true:
				var current_time = OS.get_ticks_msec()
				if current_time - previous_time > 128:
					previous_time = current_time
					break
			
			enemy.call_deferred("generate_path")
			
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_exit_main_thread = true
		get_tree().quit() # default behavior
	
func _exit_tree():
	main_thread.wait_to_finish()
