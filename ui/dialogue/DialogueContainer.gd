extends ScrollContainer
class_name DialogueController

onready var vbox := $VBoxContainer

onready var speaker_text := $VBoxContainer/Speaker
onready var dialogue_text := $VBoxContainer/MarginContainer/Dialogue

onready var pause_timer := $Pause

var text

var text_ind = 0

func _ready():
	dialogue_text.connect("on_trigger", self, "change")
	pause_timer.connect("timeout", self, "next")
	speaker_text.text = ""
	dialogue_text.text = ""

func start(text_json):
	text = text_json
	
	next()

func change(key):
	match key:
		"\\start":
			pass
		"\\end":
			pause_timer.start()
				

func next():
	if text_ind >= text.size(): 
		speaker_text.text = ""
		dialogue_text.text = ""
		
		return
	
	var speaker = text[text_ind].s
	speaker_text.text = ""
	
	if speaker == "MARS":
		speaker_text.push_color(Color.red)
	
	speaker_text.add_text(" " + speaker)

	
	dialogue_text.start(text[text_ind].t)
	text_ind += 1
