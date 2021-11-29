class_name MathUtil

static func get_nearest_node(main: Node2D, nodes: Array, group: String="") -> Node2D:
	var nearest = null
	var nearest_dist = INF
	
	for node in nodes:
		if group != "" and not node.is_in_group(group): continue
			
		var distance = main.global_position.distance_squared_to(node.global_position)
		if distance < nearest_dist:
			nearest_dist = distance
			nearest = node
	
	return nearest


static func angle_diff_deg(angle1: float, angle2: float) -> float:
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))

static func arr_mean(array: Array) -> float:
	var sum := 0.0
	for num in array:
		sum += num
		
	return sum/array.size()
