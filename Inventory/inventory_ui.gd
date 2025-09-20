extends Control

@onready var inv: Inv = preload("res://Inventory/playerinv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
var is_open = false

func _ready():
	# Connect to inventory updates
	if inv:
		if inv.has_signal("inventory_updated"):
			inv.inventory_updated.connect(update_slots)
	update_slots()
	close()
	
func update_slots():
	if not inv or not slots:
		return
		
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])
		
func _process(delta):
	if Input.is_action_just_pressed("i"):
		if is_open:
			close()
		else:
			open()
			update_slots()  # Refresh when opening

func open():
	visible = true
	is_open = true
	
func close():
	visible = false
	is_open = false

func refresh_inventory():
	update_slots()
