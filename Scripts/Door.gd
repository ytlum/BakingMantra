extends Area2D

@onready var collision_shape = $CollisionShape2D

func _ready():
	# 确保 Area2D 可以检测
	monitoring = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Level 1 Complete!")
		get_tree().change_scene("res://Levels/Level2.tscn")
