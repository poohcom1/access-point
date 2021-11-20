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

static func angle_difference(angle1: float, angle2: float) -> float:
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))
