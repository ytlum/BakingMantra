extends Area2D

@export var damage := 1
@export var vegetable_type := "default"
@export var fall_speed := 400.0
@export var min_fall_speed := 350.0
@export var max_fall_speed := 500.0

var velocity := Vector2.ZERO

func _ready():
	# Connect signals
	connect("body_entered", _on_body_entered)
	add_to_group("falling_ingredient")
	
	# Randomize fall speed for variety
	fall_speed = randf_range(min_fall_speed, max_fall_speed)
	
	# Start falling immediately
	print(vegetable_type, " vegetable falling")

func _physics_process(delta):
	# Manual falling movement
	velocity.y = fall_speed
	position += velocity * delta
	
	# Optional: Remove if goes off-screen
	if global_position.y > 1000:  # Adjust based on your screen size
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		print("Hit by falling ", vegetable_type, "!")
	
	queue_free()  # Remove immediately on impact
