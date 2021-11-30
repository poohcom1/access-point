extends RichTextLabel
class_name Dialogue

export var TickSound: AudioStream

#Signals
signal on_trigger(key)

#Constants
const TICK_LENGTH = 0.025

#mutabl
var encoded_text: Array

#volatile variables
var delta_time_tracker = 0
var text_position = 0
var text_buffer = ""

onready var timer := $Timer

func encodeString(string):
	var result = []
	if string[0] == "\\":
		return [string]
	
	for i in range(len(string)):
		result.append(string[i])
	return result

func encodeDialogSimple(listOfStrings):
	var encoded = ["\\start"]
	encoded += encodeString(listOfStrings[0])
	for i in range(1, len(listOfStrings)):
		encoded.append("\\n")
		encoded += (encodeString(listOfStrings[i]))
	encoded.append("\\n")
	encoded += ["\\end"]
	#encoded += ["","","","","","","","","","","","","","","","","","","","","","","","","","",""]
	return encoded

func start(text_list):
	encoded_text = encodeDialogSimple(text_list)
	text_position = 0
	text_buffer = ""

func _process(delta):
	if not encoded_text or not timer.is_stopped(): return
	
	delta_time_tracker += delta
	if delta_time_tracker > TICK_LENGTH:
		if text_position < len(encoded_text):
			
			var current_char = encoded_text[text_position]
			if text_position < len(encoded_text):
				text_position += 1
				
			if current_char == "\\n":
				timer.start()
				text_buffer = ""
				return
				
			if len(current_char) > 0 and current_char[0] == '\\':
				emit_signal("on_trigger", current_char)
				return
			
			if current_char != " ":
				delta_time_tracker = 0
				
			text_buffer += current_char
			text = text_buffer
			
			add_child(OneShotAudio.new(TickSound, -15))
		#else:
		#	text_buffer = ""
		#	text = text_buffer
	
	

