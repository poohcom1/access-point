extends Structure
class_name FriendlyStructure

# Properties
export var MAX_BATTERY: float = 4
export var DESTROYED_SOUND: AudioStream = load("res://assets/SE/BuildingDestroy1.mp3")

export var battery: float
export var bugged := false
export var ACTIVATE_SOUND: AudioStream

# Fields
const EPSILON = 0.00001

# Nodes

# Fields
var activated = true

# Signals
signal on_activate()
# warning-ignore:unused_signal
signal on_deactivate() # Must be implemented by each structure

func _ready():
	add_to_group("friendly")
	set_collision_layer_bit(GameManager.COL_PLAYER, true)
	
	$ClickArea.connect("mouse_entered", self, "_on_mouse_enter")
	$ClickArea.connect("mouse_exited", self, "_on_mouse_exit")
	
	if battery < EPSILON:
		deactivate()
		activated = false

## Mouse Check
func activate():
	activated = true
	battery = MAX_BATTERY
	add_child(OneShotAudio2D.new(ACTIVATE_SOUND))
	
	modulate = Color.white
	
func deactivate():
	activated = false	
	modulate = Color(0.5, 0.5, 0.5)

func _on_mouse_enter():
	mouse_hover = true
	
func _on_mouse_exit():
	mouse_hover = false
	
func add_battery(val):
	set_battery(battery + val)
	
func _unhandled_input(_event):
	pass#if event.is_action_pressed("interact", false) and mouse_hover:
		#if GameManager.player.battery > 0 and battery < MAX_BATTERY:
		#	GameManager.player.battery -= 1
		#	add_battery(1)

func set_battery(val):
	if battery == 0:
		emit_signal("on_activate")
		
	battery = val
	
	if battery <= 0:
		emit_signal("on_deactivate")
		battery = 0
		

func _process(_delta):	
	## Editor hints
	if Engine.editor_hint:
		update_configuration_warning()

func _get_configuration_warning():
	if not has_node("ClickArea"):
		return "Requires an Area2D named 'ClickArea'."
		
	if not get_node("ClickArea") is Area2D:
		return "ClickArea must be an Area2D!"
	
	return ""
