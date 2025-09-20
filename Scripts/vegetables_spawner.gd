extends Node2D

@export var vegetable_scenes: Array[PackedScene] = []
@export var spawn_interval := 2.5
@export var spawn_area : Rect2 = Rect2(-80, 0, 160, 20)
@export var max_vegetables := 10  # Changed from 5 to 10
@export var spawn_enabled := true

var current_vegetables := 0
var spawn_timer: Timer

func _ready():
	# Start spawning after a short delay
	var start_timer = Timer.new()
	add_child(start_timer)
	start_timer.wait_time = 1.0
	start_timer.one_shot = true
	start_timer.timeout.connect(_start_spawning)
	start_timer.start()

func _start_spawning():
	if not spawn_enabled:
		return
		
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_vegetable)
	spawn_timer.start()

func _spawn_vegetable():
	if vegetable_scenes.is_empty() or current_vegetables >= max_vegetables or not spawn_enabled:
		return
	
	# Randomly select a vegetable type
	var random_index = randi() % vegetable_scenes.size()
	var vegetable_scene = vegetable_scenes[random_index]
	
	var vegetable = vegetable_scene.instantiate()
	
	# Random position within spawn area
	var spawn_pos = Vector2(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	)
	
	vegetable.position = global_position + spawn_pos
	vegetable.tree_exited.connect(_on_vegetable_removed)
	
	get_parent().add_child(vegetable)
	current_vegetables += 1
	print("Spawned vegetable. Total: ", current_vegetables)

func _on_vegetable_removed():
	current_vegetables -= 1
	print("Vegetable removed. Total: ", current_vegetables)

# Optional: Functions to control spawning
func set_spawning_enabled(enabled: bool):
	spawn_enabled = enabled
	if spawn_timer:
		if enabled and not spawn_timer.is_stopped():
			spawn_timer.start()
		elif not enabled:
			spawn_timer.stop()

func change_spawn_interval(new_interval: float):
	spawn_interval = new_interval
	if spawn_timer:
		spawn_timer.wait_time = new_interval
		spawn_timer.start()

func change_max_vegetables(new_max: int):
	max_vegetables = new_max

# Debug function to see spawn area in editor
func _draw():
	if Engine.is_editor_hint():
		draw_rect(spawn_area, Color(1, 0, 0, 0.3), true)
		draw_rect(spawn_area, Color(1, 0, 0, 0.8), false)
