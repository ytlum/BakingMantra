extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_label: Label = $CenterContainer/Panel/AmountLabel

func _ready():
	# Debug: Check if nodes exist
	print("Item visual exists: ", item_visual != null)
	print("Amount label exists: ", amount_label != null)
	if amount_label:
		print("Amount label name: ", amount_label.name)
		print("Amount label visible: ", amount_label.visible)
		print("Amount label text: '", amount_label.text, "'")

func update(slot: InvSlot):
	print("Updating slot - Item: ", slot.item.name if slot.item else "None", ", Amount: ", slot.amount)
	
	if !slot.item:
		item_visual.visible = false
		if amount_label:
			amount_label.visible = false
			print("Hiding item and amount label")
	else:
		item_visual.visible = true
		item_visual.texture = slot.item.texture
		print("Showing item: ", slot.item.name)
		
		if amount_label:
			if slot.amount >= 1:
				amount_label.visible = true
				amount_label.text = str(slot.amount)
				print("Showing amount: ", slot.amount)
			else:
				amount_label.visible = false
				print("Hiding amount label")
		else:
			print("Amount label is null!")
