extends Camera2D

# Drag your player node in the inspector
@export var player: Node2D

# Level horizontal boundaries
@export var level_left: int = 0
@export var level_right: int = 5000 # set to your level width

# Fixed vertical camera position
@export var fixed_y: int = 380 # half of 760, so vertical center

func _process(delta):
	if not player:
		return

	# Calculate camera X position (clamped to level boundaries)
	var cam_x = clamp(
		player.global_position.x,
		level_left + 1280/2,  # half screen width
		level_right - 1280/2
	)

	# Camera Y is fixed
	var cam_y = fixed_y

	# Set camera position
	global_position = Vector2(cam_x, cam_y)
