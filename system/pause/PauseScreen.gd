extends Node2D


func _ready():
	$"Canvas/PlaceHolder".text = "GAME IS PAUSED \nPRESS ESCAPE TO RESUME"

var resume_cooldown = 10
const RESUME_COOLDOWN_MAX = 10

func _process(_delta):
	if resume_cooldown > 0:
		resume_cooldown -= 1
		 
	var esc := Input.is_action_just_pressed("ui_cancel")
	if esc && resume_cooldown <= 0:
		resume_cooldown = RESUME_COOLDOWN_MAX
		GameManager.resume_game()
