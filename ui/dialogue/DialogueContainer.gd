extends ScrollContainer
class_name DialogueController

onready var vbox := $VBoxContainer

onready var speaker_text := $VBoxContainer/Speaker
onready var dialogue_text := $VBoxContainer/MarginContainer/Dialogue

onready var pause_timer := $Pause

signal dialogue_ended(text)

var text

var text_ind = 0
var skip_pause = false

func _input(_e):
	if Input.is_action_just_pressed("dismiss"):
		next()

func _ready():
	dialogue_text.connect("on_trigger", self, "change")
	pause_timer.connect("timeout", self, "next")
	speaker_text.text = ""
	dialogue_text.text = ""

func start(text_json):
	text = text_json
	text_ind = 0
	next()
	
func on_end():
	emit_signal("dialogue_ended", text)

func change(key):
	match key:
		"\\start":
			pass
		"\\skip":
			skip_pause = true
		"\\end":
			if not skip_pause:
				skip_pause = true
				clear()
				pause_timer.start()
			else:
				next()

func clear():		
	speaker_text.text = ""
	dialogue_text.text = ""

func next():
	if not text:
		return
	if text_ind >= text.size(): 
		speaker_text.text = ""
		dialogue_text.text = ""
		$VBoxContainer/Skip.visible = false		
		on_end()
		return
		
	if text_ind > 1:
		$VBoxContainer/Skip.visible = true
			
	dialogue_text.text = ""
	dialogue_text.start(text[text_ind].t)

	var speaker = text[text_ind].s
	speaker_text.text = ""
	
	if speaker == "MARS":
		speaker_text.push_color(Color.red)
	
	speaker_text.add_text(" " + speaker)

	text_ind += 1
