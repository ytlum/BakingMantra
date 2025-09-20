extends Area2D

@export var stun_duration := 1.5
@export var roll_speed := 180.0
@export var start_direction := 1

var direction := start_direction
var is_rolling := true

@onready var sprite = $Sprite2D
@onready var left_ray = $LeftRayCast
@onready var right_ray = $RightRayCast

func _ready():
	add_to_group("rolling_lollipop")
	connect("body_entered", _on_body_entered)
	is_rolling = true
	sprite.flip_h = (direction == -1)

func _physics_process(delta):
	if not is_rolling:
		return
	
	# Move horizontally
	position.x += roll_speed * direction * delta
	
	# Add rolling rotation effect
	sprite.rotation_degrees += roll_speed * delta * 0.5
	
	# Update raycast positions
	_update_raycasts()
	
	# Check for wall collisions using raycasts
	_check_wall_collisions_advanced()

func _update_raycasts():
	# Position raycasts at the edges of the lollipop
	if left_ray:
		left_ray.position.x = -sprite.texture.get_width() / 2 * sprite.scale.x
	if right_ray:
		right_ray.position.x = sprite.texture.get_width() / 2 * sprite.scale.x

func _check_wall_collisions_advanced():
	# Use raycasts for precise wall detection
	if left_ray and left_ray.is_colliding() and direction == -1:
		var collider = left_ray.get_collider()
		if collider and (collider.is_in_group("environment")):
			direction = 1
			sprite.flip_h = false
			print("Left ray hit wall, changing to right")
	
	if right_ray and right_ray.is_colliding() and direction == 1:
		var collider = right_ray.get_collider()
		if collider and (collider.is_in_group("environment")):
			direction = -1
			sprite.flip_h = true
			print("Right ray hit wall, changing to left")

func _on_body_entered(body):
	# Skip wall collisions (handled by raycasts)
	if body.is_in_group("environment"):
		return
	
	# Handle player collision
	if body.is_in_group("player") and body.has_method("stun_player"):
		body.stun_player(stun_duration)
		print("Player stunned!")
