extends CharacterBody2D

@export var health := 3
@export var move_speed := 60.0
@export var contact_damage := 1
@export var attack_damage := 1
@export var attack_range := 100.0
@export var attack_cooldown := 2.0

var player_ref = null
var is_active := true
var direction := 1
var can_attack := true
var is_dead := false

@onready var animated_sprite = $AnimatedSprite2D
@onready var activation_area = $ActivationArea  # Reference to the Area2D

func _ready():
	# Add to groups
	add_to_group("snow_cone_slime")
	add_to_group("stompable")
	
	# Make sure sprite faces right by default
	animated_sprite.flip_h = false
	
	# Connect signals manually if not connected in editor
	if activation_area:
		if not activation_area.body_entered.is_connected(_on_activation_area_body_entered):
			activation_area.body_entered.connect(_on_activation_area_body_entered)
		if not activation_area.body_exited.is_connected(_on_activation_area_body_exited):
			activation_area.body_exited.connect(_on_activation_area_body_exited)
		
		print("ActivationArea found and signals connected")
	else:
		print("ERROR: ActivationArea node not found!")
	
	# Start walking immediately
	animated_sprite.play("walk")
	print("Slime spawned - Looking for player...")

func _physics_process(delta):
	if is_dead:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += 980 * delta
	else:
		velocity.y = 0
	
	# Apply movement
	velocity.x = move_speed * direction
	
	# Flip sprite based on direction
	animated_sprite.flip_h = direction < 0
	
	# Move and handle collisions
	move_and_slide()
	
	# Change direction if hitting wall
	if is_on_wall():
		direction *= -1
	
	# DEBUG: Print player detection info
	if Engine.get_frames_drawn() % 120 == 0: # Every 2 seconds
		print("Slime status - Player ref: ", player_ref != null)
		if activation_area:
			var bodies = activation_area.get_overlapping_bodies()
			print("Bodies in ActivationArea: ", bodies.size())
			for body in bodies:
				print("Body in area: ", body.name, " | Is player: ", body.is_in_group("player"))
	
	# Attack player if in range
	if player_ref and can_attack:
		var distance_to_player = global_position.distance_to(player_ref.global_position)
		if distance_to_player < attack_range:
			_attack_player()

func _on_activation_area_body_entered(body):
	print("ActivationArea detected body: ", body.name)
	if body.is_in_group("player"):
		player_ref = body
		print("SUCCESS: Player detected! Slime can now attack")
	else:
		print("Body is not player - group check: ", body.is_in_group("player"))

func _on_activation_area_body_exited(body):
	print("Body left ActivationArea: ", body.name)
	if body.is_in_group("player"):
		player_ref = null
		print("Player left detection area")

func _on_hurtbox_area_entered(area):
	if area.is_in_group("player_attack"):
		take_damage(1)
		print("Slime hurt by player attack!")

func _on_contact_damage_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)
		print("Player touched slime!")
