extends CanvasLayer
class_name UI

onready var hint = $UI/HintContainer/HintMargins/HintText
onready var hint_player := $UI/HintContainer/AnimationPlayer

func _ready():
	LoadingScreen.connect("start_scene", $AnimationPlayer, "play", ["start"])
	GameManager.ui = self
	GameManager.dialogue = $UI/DialogueContainer

	hint_player.connect("animation_finished", self, "_pulse_hint")
	

func show_hint(hint_text):
	hint.bbcode_text = hint_text
	hint_player.play("show")
	
func _pulse_hint(anim):
	if anim == "show":
		hint_player.play("active")
	
func hide_hint():
	hint_player.play("hide")
