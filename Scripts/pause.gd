extends Sprite2D

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if get_rect().has_point(to_local(event.position)):
			get_tree().change_scene_to_file("res://UI/start_menu.tscn")
