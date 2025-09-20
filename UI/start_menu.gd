extends Control  # or Node if it's non-UI

@onready var return_button = $ReturnButton
@onready var challenge_button = $ChallengeButton
@onready var exit_button = $ExitButton

func _ready():
	return_button.pressed.connect(_on_return_pressed)
	challenge_button.pressed.connect(_on_challenge_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

# Resume game (hide menu)
func _on_return_pressed():
	visible = false  # or queue_free() if it was instanced dynamically
	get_tree().paused = false  # if game was paused

# Restart current scene
func _on_challenge_pressed():
	var current_scene = get_tree().current_scene
	if current_scene:
		get_tree().reload_current_scene()

# Go back to level selector
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://ui/levelSelector.tscn")
