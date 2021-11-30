extends CanvasLayer
class_name UI

onready var hint = $UI/HintContainer/HintMargins/HintText
onready var hint_player := $UI/HintContainer/AnimationPlayer

onready var alert_section = $UI/PickupAlert
onready var alert_title = $UI/PickupAlert/MarginContainer/VBoxContainer/Title
onready var alert_description = $UI/PickupAlert/MarginContainer/VBoxContainer/Description

func _ready():
	LoadingScreen.connect("start_scene", $AnimationPlayer, "play", ["start"])
	GameManager.ui = self
	GameManager.dialogue = $UI/DialogueContainer

	hint_player.connect("animation_finished", self, "_pulse_hint")
	
func _input(event):
	if alert_section.visible and (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed() and not event.is_echo():
		hide_alert()
	
func show_alert(title, description):
	alert_section.visible = true
	alert_title.bbcode_text = title
	alert_description.bbcode_text = description
	
func hide_alert():
	alert_section.visible = false

func show_hint(hint_text):
	hint.bbcode_text = hint_text
	hint_player.play("show")
	
func _pulse_hint(anim):
	if anim == "show":
		hint_player.play("active")
	
func hide_hint():
	hint_player.play("hide")
