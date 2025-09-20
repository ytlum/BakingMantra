extends Area2D

@export var damage := 999  # Instant death

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	connect("body_entered", _on_body_entered)
	add_to_group("chocolate_lava")
	animated_sprite.play("flow")  # Your lava animation

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		print("Player fell into chocolate lava! Instant death!")
		body.take_damage(damage)
