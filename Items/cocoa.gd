extends Area2D

@export var item_name: String = "coin"   # type of item (set per collectible in Inspector)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.is_in_group("player"):   
		if body.has_method("collect_item"):
			body.collect_item(item_name)
		queue_free()   # remove collectible after pickup
