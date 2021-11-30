extends AnimatedSprite
class_name BloodFX

const sprites: SpriteFrames = preload("res://entities/fx/Blood.tres")

const Blood1 = "blood1"

var anim

func _init(_anim, _flip=false):
	anim = _anim
	
	flip_h = _flip

func _ready():
	connect("animation_finished", self, "queue_free")
	frames = sprites
	play(anim)
