extends TileMap

func _ready():
	for cell in get_used_cells():
		var id = get_cell(cell.x, cell.y)
		if "wall" in tile_set.tile_get_name(id):
			var left = get_cell(cell.x - 1, cell.y)
			if left != -1:
				tile_set.tile_set_navigation_polygon(left, null)
			var right = get_cell(cell.x, cell.y - 1)
			if right != -1:
				tile_set.tile_set_navigation_polygon(right, null)
