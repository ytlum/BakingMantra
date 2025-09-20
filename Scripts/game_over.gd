extends Control

@onready var retry_button = $RetryButton
@onready var exit_button = $ExitButton

func _ready():
	print("This script is on:", name, " | path:", get_path())
	for child in get_children():
		print("Child:", child.name)


func _on_retry_pressed():
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://levelSelector.tscn")
