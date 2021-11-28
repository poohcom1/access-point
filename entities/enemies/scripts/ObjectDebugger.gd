extends Area2D

export(Array, String) var watch

var pressed = false

func _ready():
	connect("mouse_entered", self, "on_mouse_entered")
	connect("mouse_exited", self, "on_mouse_exited")
	

func _process(_event):
	if Input.is_action_just_pressed("debug"):
		if Geometry.is_point_in_circle(get_global_mouse_position(), 
			global_position, 32):
			print("%s ========================" % str(get_parent()))
		
			for field in watch:
				print("%s: %s" % [field, str(get_parent().get(field))])
				
			print("Target: %s" % str(get_parent().navigation_target.get_ref()))
