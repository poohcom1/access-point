extends Navigation2D

onready var tilemap := $Background

export var STAGE_NUM: int

func _ready():
	GameManager.save_game(filename, STAGE_NUM)
	
	GameManager.current_stage_file = filename
	
	GameManager.stage = self
	if not LoadingScreen.anim_player.is_playing():
		LoadingScreen.start_scene()
		
	GameManager.navigation = self
	_init_nav_tiles()

	LoadingScreen.connect("start_scene", self, "start")

func start():
	pass

# Remove tiles directly above walls
func _init_nav_tiles():
	var tileset: TileSet = tilemap.tile_set
	
	var empty_tile = tileset.find_tile_by_name("NO_NAV_SAND")
	
	var obstacles := get_tree().get_nodes_in_group("obstacle")
	var nav_poly = null
	
	var cell_count = 0
	
	for cell in tilemap.get_used_cells():
		cell_count += 1
		
		var id = tilemap.get_cell(cell.x, cell.y)
		
		if id == 8:
			continue
		
		if not "wall" in tileset.tile_get_name(id):
			# Check corners
			var id_below = tilemap.get_cell(cell.x+1, cell.y+1)
			
			var id_below_left = tilemap.get_cell(cell.x+1, cell.y+2)
			var id_below_right = tilemap.get_cell(cell.x+2, cell.y+1)		
		
			if id_below == -1: 
				cell_count += 1
				continue
			
			if ("wall" in tileset.tile_get_name(id_below) ):
				
				tilemap.set_cell(cell.x, cell.y, empty_tile)
				continue
			
			if (id_below_left == -1 or id_below_right == -1
				or not id_below_left in tileset.get_tiles_ids()
				or not id_below_right in tileset.get_tiles_ids()): 
					continue
			

			if ("wall" in tileset.tile_get_name(id_below_left) 
					and "wall" in tileset.tile_get_name(id_below_right) ):
						
				tilemap.set_cell(cell.x, cell.y, empty_tile)
				continue
				
				
			# Check obstacles ==================================================
			if not nav_poly:
				nav_poly = tileset.autotile_get_navigation_polygon(id, Vector2.ZERO)

			var points = Transform2D(0, tilemap.to_global(tilemap.map_to_world(cell))).xform(nav_poly.get_vertices())
			
			var found = false
			
			# todo: this sucks
			for obstacle in obstacles:
				if obstacle is StaticBody2D: 
					if obstacle.has_node("Polygon2D"):
						var polygon_node =  obstacle.get_node("Polygon2D")
						var polygon: PoolVector2Array = polygon_node.polygon
						polygon = Transform2D(0, polygon_node.global_position + Vector2(8, 4)).xform(polygon)
					
						if Geometry.intersect_polygons_2d(points, polygon).size() > 0:
							found = true
							break
					elif obstacle.has_node("CollisionShape2D"):
						pass
					
			if found:
				tilemap.set_cell(cell.x, cell.y, empty_tile)
				continue
			
	print("Tilecount: %d" % cell_count)
