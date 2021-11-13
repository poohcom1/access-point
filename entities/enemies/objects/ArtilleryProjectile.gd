extends Node2D

# Properties
var target: Vector2
var damage: float
var friendly_damage: float
var speed = 10
var shot_from

# Fields
var has_exploded = false
var has_hit_player = false

var enemies_hit = []

# Nodes

func _ready():
	# warning-ignore:return_value_discarded
	$AnimatedSprite.connect("animation_finished", self, "_on_anim_finished")



func _physics_process(_delta):
	if not has_exploded:
		if global_position.distance_to(target) <= speed:
			has_exploded = true
			on_explode()
		else:
			global_position += global_position.direction_to(target) * speed
	else:
		if not has_hit_player:
			for body in $ExplosionArea.get_overlapping_bodies():
				if body is Player:
					_on_player_hit()
				elif body is Enemy and body != shot_from and not body in enemies_hit:
					body.on_hit(friendly_damage)
					enemies_hit.append(body)

			
func on_explode():
	$AnimatedSprite.play("explosion")
	
func _on_player_hit():
	has_hit_player = true
	$"/root/GameManager".player.on_hit(damage)
	
func _on_anim_finished():
	if has_exploded:
		queue_free()
