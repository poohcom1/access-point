extends AudioStreamPlayer2D
class_name OneShotAudio2D

func _init(audio: Resource, volume := 1.0, distance=500):
	stream = audio
	volume_db = volume
	max_distance = distance

func _ready():
	play()
	
	bus = "SFX"
	
	# warning-ignore:return_value_discarded
	connect("finished", self, "on_finished")

func on_finished():
	queue_free()
