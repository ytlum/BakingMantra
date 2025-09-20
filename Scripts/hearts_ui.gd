extends Control

@export var heart_full: Texture
@export var heart_empty: Texture
var hearts := []

func _ready():
	hearts = [$Heart1, $Heart2, $Heart3]

func update_hearts(current_health: int):
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].texture = heart_full
		else:
			hearts[i].texture = heart_empty
	print("UI updated to: ", current_health)  # debug
