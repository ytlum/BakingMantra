extends Area2D

@export var item_resource: InvItem
var player = null

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node):
	if body.is_in_group("player"):   
		if body.has_method("collect_item") and item_resource:
			body.collect_item(item_resource)
		queue_free()
