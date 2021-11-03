extends Node

onready var gm = $"/root/GameManager"

func parse_command(command):
	match command.split(" ")[0]:
		"ls", "list-files":
			_list_files(command)
			

func _list_files(command: String):
	var enemies: Array = get_tree().get_nodes_in_group(Enemy.group)
	
	print(len(enemies))


