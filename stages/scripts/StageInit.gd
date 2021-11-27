extends Navigation2D

onready var tilemap := $Background

func _ready():
	GameManager.navigation = self
	_init_nav_tiles()

# Remove tiles directly above walls
func _init_nav_tiles():
	var tileset: TileSet = tilemap.tile_set
	
	var empty_tile = tileset.find_tile_by_name("NO_NAV_SAND")
	
	var cell_count = 0
	

	
	
	for cell in tilemap.get_used_cells():
		cell_count += 1
		
		var id = tilemap.get_cell(cell.x, cell.y)
		
		if id == 8:
			tilemap.set_cell(cell.x, cell.y, -1)
			continue
		
		var id_below = tilemap.get_cell(cell.x+1, cell.y+1)
		
		var id_below_left = tilemap.get_cell(cell.x+1, cell.y+2)
		var id_below_right = tilemap.get_cell(cell.x+2, cell.y+1)		
	
	
		
		if id_below == -1 or "wall" in tileset.tile_get_name(id): 
			cell_count += 1
			continue
		
		if ("wall" in tileset.tile_get_name(id_below) ):
			tilemap.set_cell(cell.x, cell.y, empty_tile)
		
		if (id_below_left == -1 or id_below_right == -1
			or not id_below_left in tileset.get_tiles_ids()
			or not id_below_right in tileset.get_tiles_ids()): continue
		

		if ("wall" in tileset.tile_get_name(id_below_left) 
				and "wall" in tileset.tile_get_name(id_below_right) ):
			tilemap.set_cell(cell.x, cell.y, empty_tile)
			
	print("Tilecount: %d" % cell_count)
