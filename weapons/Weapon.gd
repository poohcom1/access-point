extends Node2D
class_name Weapon

export var MAX_AMMO = 500
export var RELOAD_TIME := 1.5
export var CROSS_HAIR: Texture

export var ACTIVATE_SOUND: AudioStream 
export var OUT_OF_AMMO_SOUND: AudioStream = preload("res://assets/SE/Warning1.mp3")
export var RELOAD_SOUND: AudioStream = preload("res://assets/SE/Reload1.mp3")

export var RELOAD_ON_OUT := true

export var PASSIVE_RELOAD_DELAY := 0.5
export var FAST_PASSIVE_RELOAD := false

# Properties
export var weapon_name: String
var active := false

# Fields
var ammo = 0

var crosshair: Texture
var crosshair_offsets

# Node
var reload_timer := Timer.new()
var passive_reload_timer := Timer.new()

onready var player = get_parent()

func _ready():
	ammo = MAX_AMMO # Set from export
	
	reload_timer.one_shot = true
	reload_timer.autostart = false
	reload_timer.connect("timeout", self, "_reload")
	add_child(reload_timer)
	
	passive_reload_timer.one_shot = true
	passive_reload_timer.connect("timeout", self, "start_reload", [RELOAD_TIME - PASSIVE_RELOAD_DELAY, false])
	add_child(passive_reload_timer)
	
	crosshair = CROSS_HAIR
	crosshair_offsets = Vector2(crosshair.get_width()/2.0, crosshair.get_height()/2.0)
	
func use():
	if Input.is_action_just_pressed("reload") and reload_timer.time_left == 0 and ammo < MAX_AMMO:
		
		start_reload()
		
	if can_shoot():
		on_active()
	
func _process(_delta):
	if ammo <= 0 and active and reload_timer.time_left == 0:
		ammo = 0
		if OUT_OF_AMMO_SOUND:
			add_child(OneShotAudio2D.new(OUT_OF_AMMO_SOUND))
		if RELOAD_ON_OUT:
			start_reload()			
		else:
			on_stop_shoot_()

# Event methods	
func switch():
	Input.set_custom_mouse_cursor(crosshair, 0, crosshair_offsets)
	active = true
	passive_reload_timer.stop()
	on_switch()
	
func switch_out():
	active = false
	if ammo < MAX_AMMO and reload_timer.time_left == 0:
		passive_reload_timer.start(PASSIVE_RELOAD_DELAY)
	on_switch_out()

## Virtual methods to be override

# Called every frame when active
func on_active():
	pass
	
# Called on the single frame when the weapon is changed to this weapon
func on_switch():
	pass

# Called on the single frame when the weapon is changed from this weapon
func on_switch_out():
	pass
	
func on_start_shoot_():
	pass
	
func on_stop_shoot_():
	pass
	
func can_shoot() -> bool:
	return ammo > 0 and reload_timer.time_left == 0
	
func reloading() -> bool:
	return reload_timer.time_left != 0
	
func start_reload(reload_time=RELOAD_TIME, play_sound=true):
	if play_sound and RELOAD_SOUND:
		add_child(OneShotAudio2D.new(RELOAD_SOUND))
	reload_timer.start(reload_time)
	
func _reload():
	ammo = MAX_AMMO

static func is_enemy(body) -> bool:
	return body is Enemy or body is DestructableStructure
	
	
