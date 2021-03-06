extends AudioStreamPlayer
class_name OneShotAudio

func _init(audio: Resource, volume := 1.0):
	stream = audio
	volume_db = volume

func _ready():
	play()
	
	# warning-ignore:return_value_discarded
	connect("finished", self, "on_finished")

func on_finished():
	queue_free()
