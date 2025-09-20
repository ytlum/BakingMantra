extends CharacterBody2D

@export var health := 1
@export var move_speed := 80.0
@export var contact_damage := 1
@export var fly_range_x := 100.0  # Horizontal movement range
@export var fly_range_y := 50.0   # Vertical movement range

var start_position := Vector2.ZERO
var time := 0.0
var is_dead := false
var initial_direction := -1  # Start moving left first

@onready var animated_sprite = $AnimatedSprite2D
@onready var stomp_detection = $StompDetection 
@onready var contact_damage_area = $ContactDamage 

func _ready():
	start_position = global_position
	animated_sprite.play("fly")
	add_to_group("honeybee")
	add_to_group("stompable") 
	
	animated_sprite.flip_h = false
	
	# Connect all signals
	if stomp_detection:
		if not stomp_detection.body_entered.is_connected(_on_stomp_detection_body_entered):
			stomp_detection.body_entered.connect(_on_stomp_detection_body_entered)
	
	if contact_damage_area:
		if not contact_damage_area.body_entered.is_connected(_on_contact_damage_body_entered):
			contact_damage_area.body_entered.connect(_on_contact_damage_body_entered)

func _physics_process(delta):
	if is_dead:
		return
	
	# Gentle floating movement (sine wave pattern)
	time += delta
	
	# Calculate target position with initial leftward movement
	var target_x = start_position.x + initial_direction * sin(time * 0.8) * fly_range_x
	var target_y = start_position.y + cos(time * 0.5) * fly_range_y
	
	# Smooth movement toward target position
	global_position = global_position.lerp(Vector2(target_x, target_y), 0.1)
	
	# Don't flip sprite based on movement direction (keep facing left)
	# The sprite will always face the initial direction

func take_damage(amount: int):
	if is_dead:
		return
	
	health -= amount
	
	# Flash effect when hurt
	modulate = Color.YELLOW
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	
	# Disable all collision areas
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true
	if has_node("ContactDamage/CollisionShape2D"):
		$ContactDamage/CollisionShape2D.disabled = true
	if has_node("StompDetection/CollisionShape2D"):
		$StompDetection/CollisionShape2D.disabled = true
	
	# Wait for death animation then remove
	await animated_sprite.animation_finished
	queue_free()

func _on_contact_damage_body_entered(body):
	if "Player" in body.name and body.has_method("take_damage") and not is_dead:
		body.take_damage(contact_damage)
		print("Player touched bee!")

func _on_stomp_detection_body_entered(body):
	# Check if player is stomping from above
	if "Player" in body.name and body.has_method("bounce_player") and not is_dead:
		# Check if player is above the bee (stomping)
		var player_bottom = body.global_position.y + body.get_node("CollisionShape2D").shape.get_rect().size.y / 2
		var bee_top = global_position.y - $CollisionShape2D.shape.get_rect().size.y / 2
		
		if player_bottom < bee_top and body.velocity.y > 0:
			print("Player stomped on bee!")
			take_damage(1)
			# Make player bounce
			body.bounce_player()
