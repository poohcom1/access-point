extends Node
class_name AnimControl

var anim: AnimatedSprite

var anim_finished := false

func _init(_anim: AnimatedSprite):
	anim = _anim
	
	# warning-ignore:return_value_discarded
	anim.connect("animation_finished", self, "_on_anim_finished")

func _physics_process(_delta):
	anim_finished = false
	
func _on_anim_finished():
	anim_finished = true
	
func is_anim_finished(animation = anim.animation):
	var ret = animation == anim.animation and anim_finished
	anim_finished = false
	return ret
