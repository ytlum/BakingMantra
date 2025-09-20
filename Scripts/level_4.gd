extends Sprite2D

# This function will be called when the button is clicked
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if get_rect().has_point(to_local(event.position)):
			get_tree().change_scene_to_file("res://Levels/level_4.tscn")
