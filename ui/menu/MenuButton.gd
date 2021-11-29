extends Button
class_name CustomMenuButton

export var HoverSound: AudioStream
export var SelectSound: AudioStream

func _ready():
	connect("mouse_entered", self, "play_hover_sound")
	
	connect("button_up", self, "_on_click")

func play_hover_sound():
	get_tree().root.add_child(OneShotAudio.new(HoverSound, -5))

func _on_click():
	get_tree().root.add_child(OneShotAudio.new(SelectSound, 2))
	on_click()

func on_click():
	pass
