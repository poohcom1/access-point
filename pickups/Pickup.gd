extends Area2D
class_name Pickup

export var PICKUP_SOUND: AudioStream
export var HOVER_HEIGHT := 5.0
export var HOVER_TIME := 1.0
export var PICKUP_TEXT: String = ""

const PickupText = preload("res://pickups/PickupText.tscn")

var anim_tween := Tween.new()

func _ready():
	connect("body_entered", self, "_on_enter")

# Private
func _on_enter(body):
	if body is Player:
		if PICKUP_SOUND:
			GameManager.add_to_scene(OneShotAudio.new(PICKUP_SOUND))
		if PICKUP_TEXT != "":
			var pickup_text = PickupText.instance()
			
			pickup_text.text = PICKUP_TEXT
			
			GameManager.add_to_scene(pickup_text, global_position)
			
		
		on_pickup(body)
		queue_free()

# Virtual
func on_pickup(_player):
	pass


# Methods
func animate_hover(sprite: Node2D):
	add_child(anim_tween)
	
	anim_tween.interpolate_property(sprite, "position", sprite.position,
		sprite.position + Vector2.UP * HOVER_HEIGHT, HOVER_TIME, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
	anim_tween.interpolate_property(sprite, "position", sprite.position + Vector2.UP * HOVER_HEIGHT,
		sprite.position, HOVER_TIME,
		Tween.TRANS_LINEAR, Tween.EASE_OUT, HOVER_TIME)
		
	anim_tween.repeat = true
	anim_tween.start()
