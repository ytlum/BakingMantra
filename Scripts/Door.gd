extends Area2D

func _ready():
	# Godot 4 写法
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Level Complete!")

		# 获取当前场景
		var current_scene = get_tree().current_scene

		# 实例化 LevelComplete UI
		var level_complete_ui = load("res://UI/LevelComplete.tscn").instantiate()

		# 添加到当前场景
		current_scene.add_child(level_complete_ui)

		# 暂停游戏逻辑，但 CanvasLayer UI 仍可操作
		#get_tree().paused = true
