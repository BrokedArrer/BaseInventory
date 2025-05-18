extends PanelContainer

const Slot = preload("res://Inventory/Slot.tscn")



@onready var item_grid: GridContainer = $MarginContainer/ItemGrid


func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	
	# If this is equipment inventory, set up slot types
	if inventory_data is InventoryDataEquip:
		setup_equipment_slot_types(inventory_data as InventoryDataEquip)
	
	populate_item_grid(inventory_data)

func setup_equipment_slot_types(inventory_data: InventoryDataEquip) -> void:
	# Clear existing slot types
	inventory_data.slot_types.clear()
	
	# Set slot types based on pre-configured slots in the scene
	for i in item_grid.get_child_count():
		var slot = item_grid.get_child(i)
		if slot.has_method("get_slot_type"):
			inventory_data.set_slot_type(i, slot.get_slot_type())


func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)

func populate_item_grid(inventory_data: InventoryData) -> void:
	for child in item_grid.get_children():
		child.queue_free()

	for slot_data in inventory_data.slots:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
