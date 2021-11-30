extends Weapon

export var SHOOT_INTERVAL := 0.05
export var DAMAGE = 1
export var KNOCKBACK = 5

export var RAMP_UP_DAMAGE = 4
export var RAMP_UP_FRAMES = 30
export var AOE = false

export var GUN_CAM_SHAKE_POWER = 0.0022

onready var gun_se := $GunSE

# Fields
var wall_hit := false
var shooting = false

var hit_targets := {} # For damage rampup

# Nodes
const ShootArea = preload("res://weapons/objects/ShootArea.tscn")
const CrossHair = preload("res://ui/CrossHair.tscn")
var cross_hair_ref := WeakRef.new()

var shoot_collider: Area2D

onready var line_of_sight := $LineOfSight
onready var shoot_interval := Timer.new()

func _ready():
	## Timer
	
	# warning-ignore:return_value_discarded
	shoot_interval.connect("timeout", self, "_on_shoot")
	add_child(shoot_interval)
	
	## Hit-scan
	shoot_collider = ShootArea.instance()
	add_child(shoot_collider)
	
	## Name
	weapon_name = "Submachine-gun"
	
	yield(get_tree(), "idle_frame")
	line_of_sight.add_exception(GameManager.player)
	


func _on_shoot():	
	#GameManager.player.screen_shaker_module.start_shaker(GameManager.player.screen_shaker_module.Curve.FLAT, -1, 0.002, 0)	
	if not can_shoot(): return	
	var hit = false

	shoot_collider.shoot()
		
	ammo -= 1
	
	var enemies = shoot_collider.get_overlapping_bodies()
	var nearest = get_nearest_enemy(enemies)
	
	# Clear targets marked for rampup
	for target in hit_targets:
		hit_targets[target].hit = false
	
	if nearest != null and nearest.health > 0:
		hit = true
		damage_enemy(nearest, 2)
		var cross_hair = cross_hair_ref.get_ref()
		
		if not cross_hair:
			cross_hair = CrossHair.instance()
			cross_hair_ref = weakref(cross_hair)
			
		cross_hair.attach_to_parent(nearest)
		
			
				
	if AOE: 
		for body in enemies:
			if is_enemy(body) and body != nearest:
				damage_enemy(body)
				hit = true
	
	# Erase target not marked
	for target in hit_targets:
		if not hit_targets[target].hit:
			# warning-ignore:return_value_discarded
			hit_targets.erase(target)
			
			var cross_hair = cross_hair_ref.get_ref()
			
			if cross_hair:
				var current_target = cross_hair.parent_ref.get_ref()
				if current_target and current_target == target:
					cross_hair.detach()
		
	get_parent().flash()
	
	if hit:
		gun_se.pitch_scale = 0.9
	else:
		gun_se.pitch_scale = 1.0
	
				
func damage_enemy(enemy, rampup=1):
	if not enemy: return
	
	var damage = DAMAGE
	
	## Rampup system
	if not hit_targets.has(enemy):
		hit_targets[enemy] = {
			"frames": 1,
			"hit": true
		}
	else:
		hit_targets[enemy].frames += rampup
		hit_targets[enemy].hit = true
		
		damage = floor(lerp(
			DAMAGE, 
			RAMP_UP_DAMAGE, 
			min(hit_targets[enemy]["frames"], RAMP_UP_FRAMES)/float(RAMP_UP_FRAMES)
			))
	
	enemy.on_hit(damage, player)
	enemy.on_hit_knockback( 
		global_position.direction_to(enemy.global_position) * KNOCKBACK,
		0.02
		 )
		
func get_nearest_enemy(bodies):
	var nearest_enemy = null
	var nearest_distance = INF
	
	for body in bodies:
		if is_enemy(body):
			var distance = body.global_position.distance_to(get_global_mouse_position())
			if distance < nearest_distance:
				nearest_enemy = body
				nearest_distance = distance
			
	return nearest_enemy

func on_active():
	if Input.is_action_pressed("shoot") and ammo > 0:
		line_of_sight.cast_to = (get_global_mouse_position() - global_position)
	
		# Check for wall hits
		if line_of_sight.is_colliding():# and (line_of_sight.get_collider() is TileMap
			#or line_of_sight.get_collider() is DestructableStructure):
			var offset = Vector2.ZERO
			
			if line_of_sight.get_collision_normal().y < 0:
				offset += line_of_sight.get_collision_normal() * 8
			
			shoot_collider.global_position = line_of_sight.get_collision_point() + offset
		else:
			# No wall hit
			shoot_collider.global_position = get_global_mouse_position()
			
		if Input.is_action_just_pressed("shoot"):
			on_start_shoot_()
			
		shooting = true
			
		#shoot_collider.get_node("Particles").emitting = true
	else:
		if shooting:
			if cross_hair_ref.get_ref():
				cross_hair_ref.get_ref().detach()
			on_stop_shoot_()
			shooting = false

func on_switch():
	if Input.is_action_pressed("shoot"):
		on_start_shoot_()

func on_switch_out():
	on_stop_shoot_(false)
	
func on_start_shoot_():
	#GameManager.player.screen_shaker_module.start_shaker(GameManager.player.screen_shaker_module.Curve.FLAT, -1, 0.002, 0)
	.on_start_shoot_()
	shoot_interval.start(SHOOT_INTERVAL)
	_on_shoot()
		
	if not gun_se.playing:
		gun_se.play()
	shooting = true

func on_stop_shoot_(richochet=true):
	#GameManager.player.screen_shaker_module.stop_shaker(0)
	.on_stop_shoot_()
	gun_se.stop()
	if richochet:
		# Ricochet SFX
		if ammo > 0:
			# 10% chance to play
			match randi() % 10:
				1: $Ricochet1.play()
				2: $Ricochet2.play()
		
	hit_targets.clear()
	shoot_interval.stop()
	if cross_hair_ref.get_ref():
		cross_hair_ref.get_ref().detach()
