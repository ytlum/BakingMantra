extends CharacterBody2D

@export var health := 3
@export var move_speed := 60.0
@export var contact_damage := 1
@export var attack_damage := 1
@export var attack_range := 100.0
@export var attack_cooldown := 2.0

var player_ref = null
var is_active := true
var direction := 1  # Start moving RIGHT
var can_attack := true
var is_dead := false

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Add to groups
	add_to_group("snow_cone_slime")
	add_to_group("stompable")
	
	# Make sure sprite faces right by default
	animated_sprite.flip_h = false
	
	# Start walking immediately
	animated_sprite.play("walk")
	print("Slime spawned - Ready to attack!")

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
		print("Slime hit wall, changing direction")
	
	# DEBUG: Print attack info
	if Engine.get_frames_drawn() % 60 == 0: # Every second
		if player_ref:
			var distance = global_position.distance_to(player_ref.global_position)
			print("Distance to player: ", distance, " | Attack range: ", attack_range)
			print("Can attack: ", can_attack, " | Player ref: ", player_ref != null)
	
	# Attack player if in range
	if player_ref and can_attack and is_active:
		var distance_to_player = global_position.distance_to(player_ref.global_position)
		if distance_to_player < attack_range:
			_attack_player()

func _attack_player():
	if not can_attack or is_dead:
		return
		
	print("Starting attack sequence!")
	
	can_attack = false
	var previous_velocity = velocity.x
	velocity.x = 0  # Stop moving during attack
	
	# Play attack animation
	if animated_sprite.has_animation("attack"):
		print("Playing attack animation")
		animated_sprite.play("attack")
	else:
		print("No attack animation found, using walk instead")
		animated_sprite.play("walk")
	
	# Apply damage to player
	if player_ref and player_ref.has_method("take_damage"):
		print("Applying damage to player")
		player_ref.take_damage(attack_damage)
	
	# Wait for attack animation to finish
	if animated_sprite.has_animation("attack"):
		await animated_sprite.animation_finished
		print("Attack animation finished")
	
	# Cooldown before next attack
	await get_tree().create_timer(attack_cooldown).timeout
	print("Attack cooldown finished")
	
	can_attack = true
	velocity.x = previous_velocity
	animated_sprite.play("walk")
	print("Resuming movement")

func take_damage(amount: int):
	if is_dead:
		return
	
	health -= amount
	print("Slime took ", amount, " damage! Health: ", health)
	
	# Play hurt animation if available
	if animated_sprite.has_animation("hurt"):
		animated_sprite.play("hurt")
		await animated_sprite.animation_finished
	else:
		# Flash effect as fallback
		modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector2.ZERO
	print("Slime is dying!")
	
	# Play death animation
	if animated_sprite.has_animation("die"):
		animated_sprite.play("die")
		await animated_sprite.animation_finished
	else:
		await get_tree().create_timer(0.1).timeout
	
	# Disable collisions
	collision_layer = 0
	collision_mask = 0
	
	queue_free()

func _on_activation_area_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		print("Player detected! Slime can now attack")

func _on_activation_area_body_exited(body):
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
