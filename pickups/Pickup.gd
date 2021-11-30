extends Area2D
class_name Pickup

export var PICKUP_SOUND: AudioStream
export var HOVER_HEIGHT := 5.0
export var HOVER_TIME := 1.0

var anim_tween := Tween.new()

func _ready():
	connect("body_entered", self, "_on_enter")

# Private
func _on_enter(body):
	if body is Player:
		if PICKUP_SOUND:
			get_tree().root.add_child(OneShotAudio.new(PICKUP_SOUND))
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