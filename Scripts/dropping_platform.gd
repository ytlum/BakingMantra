extends StaticBody2D

@export var collapse_time := 1.0
@export var drop_speed := 200.0
@export var respawn_time := 3.0
@export var max_drop_distance := 700.0

var is_collapsing := false
var is_dropping := false
var is_dropped := false
var player_on_platform := false
var original_position := Vector2.ZERO
var drop_distance := 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea

func _ready():
	original_position = position
	add_to_group("jelly_platform")
	animated_sprite.play("idle")
	
	# Connect signals if not already connected
	if detection_area:
		if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
			detection_area.body_entered.connect(_on_detection_area_body_entered)
		if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
			detection_area.body_exited.connect(_on_detection_area_body_exited)

func _on_detection_area_body_entered(body):
	if "Player" in body.name and not is_collapsing and not is_dropping and not is_dropped:
		player_on_platform = true
		print("Player stepped on platform")
		_start_collapse_timer()

func _on_detection_area_body_exited(body):
	if "Player" in body.name:
		player_on_platform = false
		if is_collapsing and not is_dropping:
			is_collapsing = false

func _start_collapse_timer():
	if is_collapsing or is_dropping or is_dropped:
		return
	
	is_collapsing = true
	
	await get_tree().create_timer(collapse_time).timeout
	
	if player_on_platform:
		_start_dropping()
	else:
		is_collapsing = false

func _start_dropping():
	is_collapsing = false
	is_dropping = true
	print("Platform dropping!")

func _physics_process(delta):
	if is_dropping:
		# Move downward
		position.y += drop_speed * delta
		drop_distance += drop_speed * delta
		
		# Check if reached max drop distance
		if drop_distance >= max_drop_distance:
			_stop_dropping()

func _stop_dropping():
	is_dropping = false
	is_dropped = true
	
	# Disable collisions
	collision_layer = 0
	collision_mask = 0
	
	# Start respawn timer
	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _respawn():
	# Reset platform
	position = original_position
	drop_distance = 0.0
	collision_layer = 1
	collision_mask = 1
	is_dropped = false
