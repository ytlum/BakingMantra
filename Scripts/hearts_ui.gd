extends Node2D

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

# 更新爱心UI
func update_hearts(health: int):
	print("update_hearts called with:", health)
	for i in range(hearts.size()):
		print("Checking heart:", i, "Node:", hearts[i])
		if i < health:
			hearts[i].play("Full")   # 有血
		else:
			hearts[i].play("Empty")  # 没血
			
