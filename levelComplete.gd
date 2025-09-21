extends CanvasLayer

@onready var exit_button = $Panel/LevelSelectorButton

func _ready():
	# 连接按钮信号
	exit_button.pressed.connect(_on_exit_pressed)


func _on_exit_pressed():
	get_tree().change_scene_to_file("res://UI/levelSelector.tscn")
