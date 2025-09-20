extends Control

@onready var option_button = $OptionButton
@onready var return_button = $ReturnButton
@onready var exit_button = $ExitButton
@onready var challenge_button = $ChallengeButton
@onready var panel_bg = $PanelBGI   # 新加的背景

func _ready():
	# 默认隐藏背景和按钮
	panel_bg.visible = false
	return_button.visible = false
	exit_button.visible = false
	challenge_button.visible = false
	
	# 信号连接
	option_button.pressed.connect(_on_option_pressed)
	return_button.pressed.connect(_on_return_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	challenge_button.pressed.connect(_on_challenge_pressed)

func _on_option_pressed():
	get_tree().paused = true
	
	# 显示背景和按钮
	panel_bg.visible = true
	return_button.visible = true
	exit_button.visible = true
	challenge_button.visible = true

func _on_return_pressed():
	get_tree().paused = false
	
	# 隐藏背景和按钮
	panel_bg.visible = false
	return_button.visible = false
	exit_button.visible = false
	challenge_button.visible = false

func _on_exit_pressed():
	# 切换到关卡选择场景
	get_tree().paused = false  # 确保解除暂停
	get_tree().change_scene_to_file("res://UI/levelSelector.tscn")


func _on_challenge_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
