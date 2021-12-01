extends CanvasLayer

onready var anim_player := $AnimationPlayer
onready var screen := $Screen

onready var hint_section = $Screen/HintContainer
onready var hint_text := $Screen/HintContainer/VBoxContainer/Hint

signal start_scene()

var _scene
var _pause = false

var current_stage: String

func _ready():
	$Timer.connect("timeout", self, "_unpause_stage")

func transition(scene: String, pause=false, hint=""):
	anim_player.play("end_scene")
	_scene = scene
	_pause = pause
	
	
	if hint == "":
		hint_section.visible = false
	else:
		hint_section.visible = true
		hint_text.bbcode_text = hint
		
func save_and_transition(scene, __pause=false, _hint=""):
	GameManager.save_game()
	
	transition(scene, __pause, _hint)

func game_over():
	current_stage = GameManager.stage.filename
	
	transition("res://stages/menu/GameOver.tscn")

func switch_scene():
	screen.mouse_filter = Control.MOUSE_FILTER_STOP
	if not _pause:
		start_scene()
		
func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if _pause:
			start_scene()
			
func start_scene():
	$Timer.start()
	
	if _scene:
		get_tree().change_scene(_scene)
		
	
	get_tree().paused = true
	anim_player.play("start_scene")
	_pause = false
	
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _unpause_stage():
	get_tree().paused = false
	emit_signal("start_scene")
