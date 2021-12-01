extends Control

var tilemap: TileMap
var scale: float
var offset: Vector2 # Offset to center the map. Set in _tilemap_init()

# Colors
export var UPDATE_FRAMES_INTERVAL = 2

export var PLAYER_COLOR: Color
export var STRUCTURE_COLOR: Color
export var RADAR_COLOR: Color
export var RADAR_PATH_COLOR: Color
export var ENEMY_COLOR: Color
export var DESTRUCTABLE_STRUCTURES_COLOR: Color
export var TILECOLOR: Color


# Fields
const EPSILON = 0.00001

var radars := []

var radar_count = 0 # For caching purposes
var in_range_tiles = [] # For caching

var tiles_cache = []

var sparse_array = []

func _ready():
	GameManager.minimap = self
	
	# Wait for all nodes to be ready
	yield(get_tree(), "idle_frame")
	
	tilemap = get_tree().get_nodes_in_group("tilemap")[0]
	_tilemap_init()
	
	# Init radar tilemap positions
	radars = get_tree().get_nodes_in_group("radar")
	radar_count = len(radars)
	
	for radar in radars:
		radar.tilemap_position = world_to_tilemap(radar.global_position)
	
	init_vision()
	get_vision(0,1)
	update()
	
	buffer_width = get_size().x
	buffer_height = get_size().y
	buffer_textureFlags = 0
	buffer_img = Image.new()
	buffer_imgTexture = ImageTexture.new()
	
	buffer_img.create(buffer_width, buffer_height, false, Image.FORMAT_RGBA8)
	buffer_imgTexture.create_from_image(buffer_img, buffer_textureFlags)
	
func add_radar(radar):
	radar.tilemap_position = world_to_tilemap(radar.global_position)
	radars.append(radar)
	
func _tilemap_init():
	# Get size of tilemap
	var bounds: Rect2 = tilemap.get_used_rect()
	var sides: float = cos(PI/4) * bounds.size.x + cos(PI/4) * bounds.size.y
	bounds.size = Vector2.ONE * sides

	
	# Get scale and offset
	if bounds.size.x > bounds.size.y:
		scale = get_size().x / (bounds.size.x)
		offset = -get_size()/2 + Vector2(0, (get_size().y-bounds.size.y*scale) / 2)
	else:
		scale = get_size().y / (bounds.size.y)
		offset = -get_size()/2 + Vector2((get_size().x-bounds.size.x*scale) / 2, 0)
		
	# Alter offset if there are tiles coordinates in the negatives
	# to shift all tiles into the positive plane
	var min_neg_x = 0
	var min_neg_y = 0
	for cell in tilemap.get_used_cells():
		cell = cell.rotated(PI/4)
		min_neg_x = min(cell.x, min_neg_x)
		min_neg_y = min(cell.y, min_neg_y)
		
	offset += Vector2(-min_neg_x, -min_neg_y) * scale
	
	
	#create a zeroed array the size of tilemap
	var tilemapsize = tilemap.get_used_rect().size
	for xx in range(int(tilemapsize.x)+10):
		sparse_array.append([])
		for _yy in range(int(tilemapsize.y)+10):
			sparse_array[xx].append(0)
	#init raster vision
	init_vision()
	get_vision(0,1)

func _draw():
	if tilemap == null: return
	
	_draw_tilemap()
	_draw_objects()
	

"""
	Check if an object's tilemap position is in range of a radar
"""

var rseed = 0

func init_vision():
	rasterized_vision = rasterized_vision_buffer
	rasterized_vision_buffer = sparse_array.duplicate(true)

#rasterize the vision of the map into a 2d sparse array
func get_vision(start_ratio, end_ratio):
	var vision_objects = radars + [$"/root/GameManager".player]
	
	var total = vision_objects.size()
	var start = start_ratio * total
	var end = end_ratio * total
	var cccount = 0
	
	for obj in vision_objects:
		if cccount >= start and cccount < end:
			var tile_pos = (obj.tilemap_position if "tilemap_position" in obj else 
				world_to_tilemap(obj.global_position))
			if(obj.battery > EPSILON and obj.health > EPSILON):
				var radius = obj.radar_range
				var x = tile_pos.x
				var y = tile_pos.y
				for ix in range(x - radius, x + radius, 2):
					for iy in range(y - radius, y + radius, 2):
						var dx = ix - x
						var dy = iy - y
						var dist2 = dx*dx + dy*dy
						if(dist2 < radius*radius):
							rseed = ((rseed + 7) & 7) - 4
							rasterized_vision_buffer[ix + rseed][iy + rseed] = 1
							rasterized_vision_buffer[ix+1 + rseed][iy + rseed] = 1
							rasterized_vision_buffer[ix + rseed][iy+1 + rseed] = 1
							rasterized_vision_buffer[ix+1 + rseed][iy+1 + rseed] = 1
		cccount += 1
		

func in_range(pos: Vector2) -> bool:
	var vision_objects = radars + [$"/root/GameManager".player]
	
	for obj in vision_objects:
		var tile_pos = (obj.tilemap_position if "tilemap_position" in obj else 
			world_to_tilemap(obj.global_position))
		# Squaring is faster than squareroot... so I assume this is more optimized
		if ( pos.distance_squared_to(tile_pos) 
				< obj.radar_range*obj.radar_range ) and obj.battery > EPSILON:
			return true
		
	return false

func _draw_objects():
	var objects = get_tree().get_nodes_in_group("map")
	
	for object in objects:
		var tilemap_pos = world_to_tilemap(object.global_position)
		var pos = tilemap_to_minimap(tilemap_pos.rotated(PI/4))
		if object is Player:
			draw_rect(Rect2(pos, Vector2.ONE * 3), PLAYER_COLOR)
		elif in_range(tilemap_pos) or object.revealed:
			if object is FriendlyStructure:
				if object in radars:
					draw_rect(Rect2(pos, Vector2.ONE * 3), RADAR_COLOR)
					# Get waypoints
					if object.battery > EPSILON:
						if not object.next_radars: 
							continue
						
						for next in object.next_radar_nodes:
							var next_radar = next.get_ref()
							if not next_radar: continue
							
							var next_pos = tilemap_to_minimap(world_to_tilemap(next_radar.global_position).rotated(PI/4))
							draw_line(pos + Vector2.ONE * 1.5, next_pos + Vector2.ONE * scale * 1.5, RADAR_PATH_COLOR, 1)
							draw_square_outline(next_pos, 15)
				else:
					draw_rect(Rect2(pos, Vector2.ONE * 2), STRUCTURE_COLOR)
			elif object is Enemy or object is EnemyStructure:
				draw_rect(Rect2(pos, Vector2.ONE * 2), ENEMY_COLOR)
			elif object is DestructableStructure and object.health > 0:
				draw_rect(Rect2(pos, Vector2.ONE * 3), DESTRUCTABLE_STRUCTURES_COLOR)
				

var tilemap_draw_cache = []
var tilemap_draw_buffer = []
var cell_selection_cache = []
var draw_tilemap_count = 0
var rasterized_vision
var rasterized_vision_buffer
const GRAN = 20 # MAKE SURE IT'S AT LEAST 6

var buffer_width
var buffer_height
var buffer_textureFlags
var buffer_img
var buffer_imgTexture

func _draw_tilemap():
	draw_set_transform(rect_size / 2, 0, Vector2.ONE)
	draw_texture_rect(buffer_imgTexture, Rect2(-get_size()/2, get_size()), false)
	
var cumulative_delta = 0
const MIN_DELTA_DELAY = 0.01

func process_tilemap(delta):
	cumulative_delta += delta
	if(cumulative_delta > MIN_DELTA_DELAY):
		cumulative_delta = 0
		do_process_tilemap()

func do_process_tilemap():
	if (draw_tilemap_count > 0 and draw_tilemap_count < GRAN - 2):
		var total = GRAN - 3
		var ratio_start = float(draw_tilemap_count - 1) / total
		var ratio_end = float(draw_tilemap_count) / total
		draw_backbuffer(ratio_start, ratio_end)
		get_vision(ratio_start, ratio_end)
	elif draw_tilemap_count == 0:
		init_vision()
		buffer_img.fill(Color(0,0,0,0))
	elif draw_tilemap_count == GRAN - 2:
		buffer_imgTexture.set_data(buffer_img)
		
	
	if(draw_tilemap_count == 0):
		#print(Engine.get_frames_per_second())
		get_tilemap_cells()
	else:
		var granularity = GRAN - 1
		var block_index = draw_tilemap_count - 1
		var block_size = cell_selection_cache.size() / granularity
		for i in range(block_index*block_size , (block_index+1) * block_size):
			var bcell = cell_selection_cache[i]
			if rasterized_vision[int(bcell.x)][int(bcell.y)] == 1:
				bcell = bcell.rotated(PI/4)
				tilemap_draw_buffer.append(bcell)
				
	if draw_tilemap_count == GRAN - 1:
		tilemap_draw_cache = tilemap_draw_buffer
		tilemap_draw_buffer = []
	#elif draw_tilemap_count == GRAN - 2:
	#	get_vision()
	
	draw_tilemap_count = (draw_tilemap_count + 1) % GRAN


func get_tilemap_cells():
	cell_selection_cache.clear()
	# Find all tiles that has collision
	for tile in tilemap.tile_set.get_tiles_ids():
		# This assumes that tiles have a single collision shape
		if tilemap.tile_set.tile_get_shape(tile, 0) != null:
			var cells = tilemap.get_used_cells_by_id(tile)
			cell_selection_cache.append_array(cells)
					

func draw_backbuffer(ratio_start, ratio_end):
	var total_size = tilemap_draw_cache.size()
	var start = total_size * ratio_start
	var end = total_size * ratio_end
	
	buffer_img.lock()
	var xoffset = get_size()/2
	var xrseed = 0
	var count = 0
	for cell in tilemap_draw_cache:
		count += 1
		xrseed = (xrseed + 1) % 10
		if xrseed < 8 and count >= start and count < end:
			#draw_rect(Rect2(tilemap_to_minimap(cell), Vector2.ONE * scale * 1.414), TILECOLOR)
			var cellx = tilemap_to_minimap(cell) + xoffset
			buffer_img.set_pixel(cellx.x, cellx.y, TILECOLOR)
	buffer_img.unlock()
	
		
func _process(delta):
	update()
	process_tilemap(delta)
	
	
func world_to_tilemap(position: Vector2) -> Vector2:
	return tilemap.world_to_map(tilemap.to_local(position))

func tilemap_to_minimap(position: Vector2) -> Vector2:
	return position * scale + offset
	
func draw_square_outline(center: Vector2, size: float, width=2):
	var p1 = (center + Vector2(-size/2, -size/2))
	var p2 = (center + Vector2(size/2, -size/2))
	var p3 = (center + Vector2(size/2, size/2))
	var p4 = (center + Vector2(-size/2, size/2))
	draw_polyline([p1, p2, p3, p4, p1], RADAR_COLOR, width)
	
	
	
