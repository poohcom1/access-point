class_name MathHelper

static func get_nearest_node(main: Node2D, nodes: Array) -> Node2D:
	var nearest = null
	var nearest_dist = INF
	
	for node in nodes:
		var distance = main.position.distance_squared_to(node.position)
		if distance < nearest_dist:
			nearest_dist = distance
			nearest = node
	
	return nearest
