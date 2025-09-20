extends CanvasLayer

@onready var retry_button = $Panel/RetryButton
@onready var exit_button = $Panel/ExitButton

func _ready():
	# 连接按钮信号
	retry_button.pressed.connect(_on_retry_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_retry_pressed():
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://UI/levelSelector.tscn")
