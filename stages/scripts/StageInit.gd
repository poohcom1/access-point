extends Navigation2D

onready var tilemap := $Background

func _ready():
	GameManager.navigation = self
	_init_nav_tiles()

# Remove tiles directly above walls
func _init_nav_tiles():
	var tileset: TileSet = tilemap.tile_set
	
	var empty_tile = tileset.find_tile_by_name("NO_NAV_SAND")
	
	for cell in tilemap.get_used_cells():
		
		var id = tilemap.get_cell(cell.x, cell.y)
		
		var id_below = tilemap.get_cell(cell.x+1, cell.y+1)
		
		var id_below_left = tilemap.get_cell(cell.x+1, cell.y+2)
		var id_below_right = tilemap.get_cell(cell.x+2, cell.y+1)		
	
		
		if id_below == -1 or "wall" in tileset.tile_get_name(id): continue
		
		if ("wall" in tileset.tile_get_name(id_below) ):
			tilemap.set_cell(cell.x, cell.y, empty_tile)
		
		if id_below_left == -1 or id_below_right == -1: continue
		

		if ("wall" in tileset.tile_get_name(id_below_left) 
				and "wall" in tileset.tile_get_name(id_below_right) ):
			tilemap.set_cell(cell.x, cell.y, empty_tile)
			
