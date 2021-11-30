extends Area2D
class_name Hint

export(String, MULTILINE) var hint
var has_shown = false

func _ready():
	connect("body_entered", self, "_show_hint")
		
	connect("body_exited", self, "_hide_hint")
	
func _show_hint(body):
	if body is Player: # and not has_shown
		GameManager.ui.show_hint(hint)


func _hide_hint(body):
	if not has_shown and body is Player:
		hide_hint()

func hide_hint():
	GameManager.ui.hide_hint()
	#$CollisionShape2D.set_deferred("disabled", true)
