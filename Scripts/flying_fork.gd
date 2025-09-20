extends Area2D

@export var damage := 1
@export var move_speed := 200.0
@export var vertical_range := 50.0  # How much to move up/down
@export var vertical_speed := 1.5   # How fast to move up/down

var starting_y := 0.0
var time := 0.0

func _ready():
	# Connect signals
	connect("body_entered", _on_body_entered)
	add_to_group("flying_fork")
	
	# Store starting position for vertical movement
	starting_y = global_position.y

func _physics_process(delta):
	# Move horizontally to the LEFT (negative x direction)
	position.x -= move_speed * delta
	
	# Vertical floating movement (sine wave for smooth up/down)
	time += delta
	global_position.y = starting_y + sin(time * vertical_speed) * vertical_range
	
	# Remove if off-screen to the left
	if global_position.x < -100:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		print("Stabbed by flying fork!")
		_play_hit_effect()
	
	# Remove after hitting something
	queue_free()

# Optional: Visual hit effect
func _play_hit_effect():
	# Create spark particles or flash effect
	var particles = GPUParticles2D.new()
	add_child(particles)
	particles.one_shot = true
	particles.emitting = true
	particles.lifetime = 0.3
	particles.finished.connect(particles.queue_free)
