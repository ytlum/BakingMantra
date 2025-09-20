extends Control

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

# 更新爱心UI
func update_hearts(health: int):
	for i in range(hearts.size()):
		if i < health:
			hearts[i].play("Full")   # 有血，播放满心动画
		else:
			hearts[i].play("Empty")  # 没血，播放空心动画
