extends CharacterBody2D

@export var health := 3
@export var slide_speed: float = 80.0
@export var contact_damage := 1

var direction: int = -1

@onready var animated_sprite = $AnimatedSprite2D
@onready var stomp_detection = $StompDetection
@onready var contact_damage_area = $ContactDamage

func _ready():
	animated_sprite.play("walk")
	
	if stomp_detection:
		stomp_detection.body_entered.connect(_on_stomp_detection_body_entered)
	
	if contact_damage_area:
		contact_damage_area.body_entered.connect(_on_contact_damage_body_entered)
	
func _physics_process(delta):
	if health <= 0:
		return
		
	velocity.x = slide_speed * direction
	move_and_slide()
	
	if is_on_wall():
		direction *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h

func take_damage(amount: int):
	if health <= 0:
		return
	
	health -= amount
	
	if health <= 0:
		die()

func die():
	animated_sprite.play("die")
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true
	if has_node("ContactDamage/CollisionShape2D"):
		$ContactDamage/CollisionShape2D.disabled = true
	if has_node("StompDetection/CollisionShape2D"):
		$StompDetection/CollisionShape2D.disabled = true
	
	await animated_sprite.animation_finished
	queue_free()

func _on_contact_damage_body_entered(body):
	if "Player" in body.name and body.has_method("take_damage") and health > 0:
		body.take_damage(contact_damage)
		print("Player touched slime!")

func _on_stomp_detection_body_entered(body):
	if "Player" in body.name and body.has_method("bounce_player") and health > 0:
		print("Slime died!")
		die()
		body.bounce_player()
