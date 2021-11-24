extends Node2D

var text1 = "WOW THIS IS ANIMATED TEXT WHAT THE ACTUAL FUCK?????"
var text2 = "Second message!!!!!"
var text3 = "FINAL PAGE"

#Signals
signal on_trigger(key)

#Constants
const TICK_LENGTH = 0.05

#mutable
var encoded_text

#volatile variables
var delta_time_tracker = 0
var text_position = 0
var text_buffer = ""

func encodeString(string):
	var result = []
	for i in range(len(string)):
		result.append(string[i])
	return result

func encodeDialogSimple(listOfStrings):
	var encoded = ["\\start"]
	encoded += encodeString(listOfStrings[0])
	for i in range(1,len(listOfStrings)):
		encoded.append("\\n")
		encoded += (encodeString(listOfStrings[i]))
	encoded += ["\\end"]
	encoded += ["","","","","","","","","","","","","","","","","","","","","","","","","","",""]
	return encoded

func _ready():
	#var encoded = encodeDialogSimple([text1, text2, text3])
	encoded_text = [] #encoded
	#print(encoded_text)
	pass

func _process(delta):
	delta_time_tracker += delta
	if(delta_time_tracker > TICK_LENGTH):
		if(text_position < len(encoded_text)):
			var current_char = encoded_text[text_position]
			if(text_position < len(encoded_text)):
				text_position += 1
				
			if (current_char == "\\n"):
				text_buffer = ""
				return
				
			if (len(current_char) > 0 and current_char[0] == '\\'):
				emit_signal("on_trigger", current_char)
				return
			
			if(current_char != " "):
				delta_time_tracker = 0
			text_buffer += (current_char)
			$TextField.text = text_buffer
		else:
			text_buffer = ""
			$TextField.text = text_buffer


