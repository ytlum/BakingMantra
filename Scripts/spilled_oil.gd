extends Area2D

func _ready():
	# Connect signals
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
	# Add to group for identification (using existing "sticky" group)
	add_to_group("sticky")

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Visual feedback - make player slightly shiny/oily
		body.modulate = Color(1.0, 1.0, 0.8, 1.0)  # Light yellow tint
		print("Stepped in oil - movement slowed!")

func _on_body_exited(body):
	if body.is_in_group("player"):
		# Remove visual effect
		body.modulate = Color.WHITE
		print("Left oil - movement restored")
