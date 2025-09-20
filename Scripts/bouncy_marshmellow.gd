extends Area2D

@export var bounce_force := -900.0  # Higher than normal jump
@export var bounce_cooldown := 0.5  # Seconds between bounces

var can_bounce := true

func _ready():
	add_to_group("spring_marshmallow")

func _play_bounce_animation():
	# Simple scale animation for bounce effect
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Sprite2D, "scale:y", 0.6, 0.1)
	tween.tween_property($Sprite2D, "scale:x", 1.2, 0.1)
	tween.tween_callback(tween.finished)
	
	var tween2 = create_tween()
	tween2.tween_property($Sprite2D, "scale", Vector2(1, 1), 0.3)
