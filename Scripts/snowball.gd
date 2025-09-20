extends Area2D

@export var speed: float = 200.0
@export var damage: int = 1
var direction: Vector2 = Vector2.ZERO
var has_hit: bool = false

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("default")

# Set movement direction and flip sprite accordingly
func set_direction(new_direction: Vector2):
	direction = new_direction
	if direction.x > 0:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

func set_speed(new_speed: float):
	speed = new_speed

func set_damage(new_damage: int):
	damage = new_damage

func _physics_process(delta):
	if has_hit:
		return
	position.x += direction.x * speed * delta

# Handle collisions with physics bodies (player, walls, ground)
func _on_body_entered(body):
	if has_hit:
		return
	
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		destroy()
	elif body.is_in_group("wall") or body.is_in_group("ground"):
		destroy()

# Handle collisions with areas (player hurtbox)
func _on_area_entered(area):
	if has_hit:
		return
	
	if area.is_in_group("player_hurtbox"):
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(damage)
		destroy()

# Cleanup after hitting something
func destroy():
	has_hit = true
	queue_free()

# Cleanup when leaving screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
