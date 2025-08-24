extends CharacterBody2D

@export var speed: int = 75
@export var damage: int = 1
@export var ice_shard_damage: int = 1
@export var attack_cooldown: float = 3.5
@export var max_health: int = 3
@export var knockback_force: float = 200.0
@export var detection_range: float = 150.0
@export var hit_recovery_time: float = 0.5
@export var snowball_speed: float = 200.0
@export var snowball_damage: int = 1
@export var snowball_scene: PackedScene
@export var snowball_spawn_offset: Vector2 = Vector2(20, -10)

var direction: int = -1
var can_attack: bool = true
var player_in_range: bool = false
var is_squished: bool = false
var is_attacking: bool = false
var is_getting_hit: bool = false
var gravity: int = 980
var health: int
var player_ref = null
var is_turning: bool = false

@onready var sprite = $AnimatedSprite2D

func _ready():
	health = max_health
	$RayCast2D.target_position = Vector2(30 * direction, 30)
	$RayCast2D.enabled = true
	print("Enemy spawned with health: ", health, "/", max_health)

func _physics_process(delta):
	if is_squished or is_getting_hit:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return
	
	if is_on_floor() and not player_in_range:
		velocity.x = speed * direction
	else:
		velocity.x = 0
	
	move_and_slide()
	
	if is_on_floor() and not player_in_range and not is_turning:
		if is_on_wall() or !$RayCast2D.is_colliding():
			turn_around()
	
	handle_animations()
	
	if player_in_range and not is_attacking and can_attack and not is_getting_hit:
		attack_player()

# Handle animation states based on current slime state
func handle_animations():
	if is_squished:
		return
	elif is_getting_hit:
		sprite.play("get_hit")
	elif is_attacking:
		sprite.play("attack")
	elif not is_on_floor():
		sprite.play("walk")
	elif player_in_range and not is_attacking:
		if sprite.animation == "walk":
			sprite.stop()
	elif abs(velocity.x) > 0:
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation == "walk":
			sprite.stop()

# Turn around when hitting wall or edge
func turn_around():
	if is_turning:
		return
	
	is_turning = true
	direction *= -1
	sprite.scale.x *= -1
	$RayCast2D.target_position.x *= -1
	
	await get_tree().create_timer(0.5).timeout
	is_turning = false

# Attack sequence: face player, play animation, throw snowball
func attack_player():
	if not can_attack or is_squished or is_getting_hit:
		return
	
	can_attack = false
	is_attacking = true
	velocity.x = 0
	
	if player_ref and player_ref.global_position.x > global_position.x:
		direction = 1
		sprite.scale.x = abs(sprite.scale.x)
	else:
		direction = -1
		sprite.scale.x = -abs(sprite.scale.x)
	
	sprite.play("attack")
	
	await get_tree().create_timer(0.4).timeout
	throw_snowball()
	
	await get_tree().create_timer(0.4).timeout
	is_attacking = false
	
	$AttackTimer.start()

# Create and throw snowball projectile toward player
func throw_snowball():
	if is_squished or not snowball_scene:
		return
	
	var target_direction = Vector2.RIGHT
	
	if is_instance_valid(player_ref):
		if player_ref.global_position.x > global_position.x:
			target_direction = Vector2.RIGHT
		else:
			target_direction = Vector2.LEFT
	else:
		target_direction = Vector2.RIGHT if direction > 0 else Vector2.LEFT
	
	var snowball = snowball_scene.instantiate()
	get_tree().current_scene.add_child(snowball)
	
	snowball.global_position = $SnowballSpawnPoint.global_position
	snowball.set_direction(target_direction)
	snowball.set_speed(snowball_speed)
	snowball.set_damage(snowball_damage)

# Handle damage taken from player attacks
func take_damage(amount: int = 1, attack_direction: Vector2 = Vector2.ZERO):
	if is_squished or is_attacking or is_getting_hit:
		return
	
	if is_attacking:
		is_attacking = false
	
	health -= amount
	is_getting_hit = true
	
	print("Enemy health: ", health, "/", max_health)
	
	if attack_direction != Vector2.ZERO:
		velocity = attack_direction * knockback_force
		velocity.y = -knockback_force * 0.5
	
	sprite.play("get_hit")
	
	if health <= 0:
		die()
		return
	
	await get_tree().create_timer(hit_recovery_time).timeout
	is_getting_hit = false
	
	handle_animations()
	
	if player_in_range and can_attack:
		attack_player()

# Death sequence from health depletion
func die():
	is_squished = true
	velocity.x = 0
	sprite.play("death")
	
	print("Enemy died!")
	
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Hitbox/CollisionShape2D.call_deferred("set_disabled", true)
	$DetectionZone/CollisionShape2D.call_deferred("set_disabled", true)
	$StompDetector/CollisionShape2D.call_deferred("set_disabled", true)
	
	await get_tree().create_timer(0.8).timeout
	queue_free()

# Death sequence from player stomp
func squish():
	if is_squished:
		return
	
	is_squished = true
	velocity.x = 0
	sprite.play("death")
	
	print("Enemy squished!")
	
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Hitbox/CollisionShape2D.call_deferred("set_disabled", true)
	$DetectionZone/CollisionShape2D.call_deferred("set_disabled", true)
	$StompDetector/CollisionShape2D.call_deferred("set_disabled", true)
	
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _on_attack_timer_timeout():
	can_attack = true
	
	if player_in_range and not is_attacking and not is_getting_hit:
		attack_player()

func _on_detection_zone_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		
		if not is_attacking and can_attack and not is_getting_hit:
			attack_player()

func _on_detection_zone_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and not is_squished and not is_attacking and not is_getting_hit:
		if body.has_method("take_damage"):
			body.take_damage(damage)

func _on_stomp_detector_body_entered(body):
	if body.is_in_group("player") and body.velocity.y > 0 and not is_squished:
		squish()
		body.velocity.y = -300

func _on_attack_hitbox_area_entered(area):
	if area.is_in_group("player_attack") and not is_squished:
		var random_direction = Vector2(randf_range(-1, 1), randf_range(-0.5, -1)).normalized()
		take_damage(1, random_direction)
