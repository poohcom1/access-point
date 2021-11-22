extends Node
class_name AnimUtil

enum Dir {
	None,
	Left,
	Right,
	Top,
	Bottom,
	TopLeft,
	TopRight,
	BottomLeft,
	BottomRight,
}

const Dir2Anim = {
	Dir.Left: "side",
	Dir.Right: "side",
	Dir.Top: "back",
	Dir.Bottom: "front",
	Dir.TopLeft: "sideback",
	Dir.TopRight: "sideback",
	Dir.BottomLeft: "sidefront",
	Dir.BottomRight: "sidefront",
}


const Dir2Angle = {
	Dir.Right: 0,
	Dir.BottomRight: 45,
	Dir.Bottom: 90,
	Dir.BottomLeft: 135,
	Dir.Left: 180,
	Dir.Left: -180,
	Dir.TopLeft: -135,
	Dir.Top: -90,
	Dir.TopRight: -45,
}

const Angle2Dir = {
	0: Dir.Right,
	45: Dir.BottomRight,
	90: Dir.Bottom,
	135: Dir.BottomLeft,
	180: Dir.Left,
	-180: Dir.Left,
	-135: Dir.TopLeft,
	-90: Dir.Top,
	-45: Dir.TopRight,
}

"""
	Stepifies an angle in radians into degrees with the given step.
	Angles are wrapped between -180 and 180 to match the animation enums
"""
static func stepify_angle(angle: float, step := 45) -> int:
	return wrapi(int(stepify(rad2deg(angle), step)), -180, 180)

static func get_dir(angle: float) -> int: 
	return Angle2Dir[stepify_angle(angle)]
