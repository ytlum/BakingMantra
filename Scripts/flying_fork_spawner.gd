extends Node2D

@export var flying_fork_scene: PackedScene
@export var spawn_interval := 3.0
@export var spawn_heights: Array[float] = [100, 150, 200, 250]  # Different Y positions
@export var max_forks := 4

var current_forks := 0

func _ready():
	# Start spawning after a short delay
	var start_timer = Timer.new()
	add_child(start_timer)
	start_timer.wait_time = 1.0
	start_timer.one_shot = true
	start_timer.timeout.connect(_start_spawning)
	start_timer.start()

func _start_spawning():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_fork)
	timer.start()

func _spawn_fork():
	if not flying_fork_scene or current_forks >= max_forks:
		return
	
	var fork = flying_fork_scene.instantiate()
	
	# Random height from available options
	var random_height = spawn_heights[randi() % spawn_heights.size()]
	
	# Spawn on the RIGHT side of screen, moving LEFT
	# Adjust 1200 based on your screen width
	fork.position = Vector2(1200, random_height)
	
	fork.tree_exited.connect(_on_fork_removed)
	get_parent().add_child(fork)
	current_forks += 1
	print("Spawned flying fork at height: ", random_height)

func _on_fork_removed():
	current_forks -= 1
