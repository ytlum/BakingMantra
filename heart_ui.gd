extends Control

@onready var heart_1 = $Heart1
@onready var heart_2 = $Heart2
@onready var heart_3 = $Heart3

func update_hearts(current_health: int):
	var hearts = [heart_1, heart_2, heart_3]

	for i in range(hearts.size()):
		hearts[i].visible = i < current_health
