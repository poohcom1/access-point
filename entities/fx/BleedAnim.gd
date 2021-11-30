extends AnimationPlayer

export var extents: Rect2

func bleed():
	if not is_playing():
		play("bleed")
	
func _bleed():
	var bleedfx = BloodFX.new(BloodFX.Blood1)
	get_parent().add_child(bleedfx)
	bleedfx.z_index = get_parent().z_index + 20
	bleedfx.position = Vector2(rand_range(extents.position.x, extents.position.x + extents.size.x), rand_range(extents.position.y, extents.position.y+extents.size.y))
	bleedfx.flip_h = bleedfx.position.x < 0
