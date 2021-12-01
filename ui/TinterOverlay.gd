extends CanvasLayer

const HEALTH_THRESHOLD_RED = 0.4

func _ready():
	$ColorRect.color = Color(0.5, 0, 0, 0)

func _process(_delta):
	var health_ratio = float(GameManager.player.health) / GameManager.player.MAX_HEALTH
	if health_ratio < HEALTH_THRESHOLD_RED:
		var alpha = HEALTH_THRESHOLD_RED - health_ratio
		$ColorRect.color = Color(0.6, 0.07, 0.07, alpha)
	else:
		$ColorRect.color = Color(0.5, 0, 0, 0)
