extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var footbox = $Footbox
@onready var attackhitbox = $AttackHitbox/AttackboxShape

@onready var invuln_timer = $InvulnTimer
@onready var freeze_timer = $FreezeTimer
@onready var slow_timer = $SlowTimer
@onready var attack_timer = $AttackTimer

@export var walk_speed = 150.0
@export var run_speed = 350.0
@export var crouch_speed = 80.0 
@export var icy_acceleration = 0.2        # used on icy floor
@export var stomp_bounce_force = -450.0     # bounce after stomping a slime
@export var attack_cooldown = 0.25          # seconds (reuse AttackTimer if you like)
@export var invuln_time = 0.7               # after hurt, can’t be hit again
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
@export var jump_force = -600.0
@export_range(0, 1) var decelerate_on_jump_release = 0.3
@export var hurt_stun_time := 0.4  # seconds player is stunned after hit

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var inventory = {}
var is_hurt: bool = false

# --- Health System ---
@export var max_health = 3
var health = 3
var is_alive = true

# Status flags
var is_frozen = false
var is_slowed = false
var is_stunned = false
var is_slippery = false
var can_jump = true
var invulnerable = false
var attacking = false

# ========================
# Movement Functions
# ========================
func _physics_process(delta):
	 
	if not is_alive:
		return # no movement if dead
		
	if is_hurt:
		# Player flinches: can still fall, but no input
		if not is_on_floor():
			velocity.y += gravity * delta
			move_and_slide()
		return
		
	if animated_sprite.animation in ["Hurt", "Die"]:
		return
		
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# Prevent movement if frozen or stunned
	if is_frozen or is_stunned:
		velocity.x = 0
		return
		
	# Jump
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or is_on_wall()) and can_jump:
		velocity.y = jump_force
		animated_sprite.play("Jump")
	
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release

	var speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed;
		
	if Input.is_action_pressed("ui_down"):  
		speed = crouch_speed
	
	if is_slowed:
		speed *= 0.5
	
	#Apply direction
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Handle movement
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
	
	# Handle attack input
	if Input.is_action_just_pressed("attack") and not attacking:
		_start_attack()
		
	#Handle animations
	if attacking:
		pass # let _start_attack() handle animation, don't override here
	elif not is_on_floor() and velocity.y < 0 and Input.is_action_pressed("ui_accept"):
		animated_sprite.play("Jump")
	elif not is_on_floor() and velocity.y > 0:
		animated_sprite.play("Fall") 
	elif Input.is_action_pressed("ui_down"):
		if abs(velocity.x) > 0.1:
			animated_sprite.play("CrouchWalk")  # moving while crouching
			animated_sprite.flip_h = direction < 0
		else:
			animated_sprite.play("CrouchIdle")  # crouching still
	elif abs(velocity.x) > 0.1:
		animated_sprite.play("Walk")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("Idle")

	# Move the character
	move_and_slide()

func collect_item(item_name):
	# Add item to inventory or increase count
	if inventory.has(item_name):
		inventory[item_name] += 1
	else:
		inventory[item_name] = 1
	
	print("Collected: ", item_name, " - Total: ", inventory[item_name])
	
# ========================
# Attack Function
# ========================
func _start_attack():
	attacking = true
	attackhitbox.disabled = false
	animated_sprite.play("Attack")
	attack_timer.start(attack_cooldown)
	
# ========================
# Health Functions
# ========================
func _ready():
	health = max_health
	set_physics_process(true) # ensure physics is active
	print("Player ready")
	
func take_damage(amount: int = 1):
	if invulnerable or not is_alive:
		return

	health -= amount
	print("Player health:", health)

	if health > 0:
		# Enter hurt state
		is_hurt = true
		invulnerable = true
		invuln_timer.start(invuln_time)

		velocity.x = 0  # stop moving instantly
		animated_sprite.play("Hurt")

		# Release stun after short delay
		await get_tree().create_timer(hurt_stun_time).timeout
		is_hurt = false

		# Only reset if still alive
		if is_alive:
			animated_sprite.play("Idle")
	else:
		die()


func die():
	is_alive = false
	animated_sprite.play("Die")
	set_physics_process(false)
	print("Player died")

# ========================
# Status Effects Functions
# ========================
func slow_player(duration: float = 3.0):
	is_slowed = true
	slow_timer.start(duration)

func stun_player(duration: float = 2.0):
	is_stunned = true
	animated_sprite.play("Stunned")
	await get_tree().create_timer(duration).timeout
	is_stunned = false

func freeze_player(duration: float = 2.0):
	is_frozen = true
	animated_sprite.play("Frozen")
	freeze_timer.start(duration)

func disable_jump(duration: float = 2.0):
	can_jump = false
	await get_tree().create_timer(duration).timeout
	can_jump = true

func bounce_player(force: float = -900.0):
	velocity.y = force
	animated_sprite.play("Jump")

func enable_slippery():
	is_slippery = true
	animated_sprite.play("Dashing")
	print("Player on icy floor!")
	
# ========================
# Area/Enemy Interactions
# ========================
func _on_hurtbox_area_entered(area: Area2D) -> void:
	#---Level 1---
	# Sticky Patches (slows movement and jump cooldown)
	if area.is_in_group("sticky"):
		slow_player(3.0)
		disable_jump(2.0)
		print("Player slowed by sticky patch!")

	# Falling Ingredients (lose 1 health if hit)
	elif area.is_in_group("falling_ingredient"):
		take_damage(1)
		print("Hit by falling ingredient!")
	
	#---Level 2---
	# Flying Forks (lose 1 health if stabbed)
	elif area.is_in_group("flying_fork"):
		take_damage(1)
		print("Stabbed by flying fork!")
		
	#---Level 3---
	# Snow Cone Slimes (touch = hurt, stomp kills them)
	elif area.is_in_group("snow_cone_slime"):
		take_damage(1)
		print("Hit by snow cone slime!")

	# Candy Icicles (crash down & freeze player)
	elif area.is_in_group("candy_icicle"):
		freeze_player(2.0)
		print("Player frozen by candy icicle!")
	
	#---Level 4---
	# Rolling Lollipop (stun player for 2 seconds)
	elif area.is_in_group("rolling_lollipop"):
		stun_player(2.0)
		print("Player stunned by rolling lollipop!")

	# Honeybees (touch = hurt, can stomp to kill)
	elif area.is_in_group("honeybee"):
		take_damage(1)
		print("Touched honeybee!")

#---Exit Hurbox-----
func _on_hurtbox_area_exited(area: Area2D) -> void:
	#---Level 1---
	# Leaving sticky patches removes slow
	if area.is_in_group("sticky"):
		is_slowed = false

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("honeybee"):
		if area.has_method("take_damage"):
			area.take_damage(1)
		print("Killed the honeybee!")

func _on_footbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("stompable"):
		if area.has_method("die"):
			area.die()
		bounce_player() # bounce upward after stomping
		print("Stomped enemy!")
	if area.is_in_group("chocolate_lava"):
		die()  # Immediate death
		print("Fell into chocolate lava!")
		
	# Chocolate Lava (instant death)
	elif area.is_in_group("chocolate_lava"):
		#play_splash_effect()
		die() # immediate death
		print("Fell into chocolate lava!")
	
	# Jelly Platform (start collapse when standing)
	elif area.is_in_group("jelly_platform"):
		area.call("start_collapse")
		print("Standing on jelly platform!")
	
	elif area.is_in_group("spring_marshmallow"):
		bounce_player(-900.0) # higher than normal jump
		print("Bounced on marshmallow!")

	elif area.is_in_group("icy_floor"):
		enable_slippery()
		print("Wooh~")
	
func _on_invuln_timer_timeout() -> void:
	invulnerable = false
	print("Invulnerability ended")


func _on_freeze_timer_timeout() -> void:
	is_frozen = false
	print("Freeze ended")

func _on_slow_timer_timeout() -> void:
	is_slowed = false
	print("Slow ended")

func _on_attack_timer_timeout() -> void:
	attackhitbox.disabled = true
	attacking = false
	print("Attack ended")
	
