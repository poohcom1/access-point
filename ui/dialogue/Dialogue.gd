extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var text1 = "WOW THIS IS ANIMATED TEXT WHAT THE ACTUAL FUCK?????"
var text2 = "Second message!!!!!"
var text3 = "FINAL PAGE"




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
	var encoded = encodeDialogSimple([text1, text2, text3])
	encoded_text = encoded
	print(encoded_text)

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
				if(current_char == "\\start"):
					onTextStart()
				elif(current_char == "\\end"):
					onTextEnd() 
				return
			
			if(current_char != " "):
				delta_time_tracker = 0
			text_buffer += (current_char)
			$TextField.text = text_buffer
		else:
			text_buffer = ""
			$TextField.text = text_buffer

func onTextStart():
	print("Text started")
	
func onTextEnd():
	print("Text ended")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
