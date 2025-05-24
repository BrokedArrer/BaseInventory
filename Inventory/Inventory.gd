extends PanelContainer

const Slot = preload("res://Inventory/Slot.tscn")

@onready var item_grid: GridContainer = $MarginContainer/ItemGrid
@onready var current_slot: int = 0  # -1 means no slot selected by default
var slot_instances: Array = []
var is_hotbar: bool = false  # Track if this is a hotbar inventory

func _ready() -> void:
	# Check if this inventory is in the hotbar group
	is_hotbar = is_in_group("hotbar")

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
	# Clear existing slots
	for child in item_grid.get_children():
		child.queue_free()
	slot_instances.clear()

	# Create new slots
	for i in inventory_data.slots.size():
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		slot_instances.append(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if inventory_data.slots[i]:
			slot.set_slot_data(inventory_data.slots[i])
		
		# Only update highlight if this is a hotbar
		if is_hotbar:
			update_slot_highlight(i)

func update_slot_highlight(slot_index: int) -> void:
	# Only proceed if this is a hotbar
	if not is_hotbar:
		return
		
	if slot_index >= 0 && slot_index < slot_instances.size():
		var slot = slot_instances[slot_index]
		if slot.has_method("set_highlight"):
			if slot_index == current_slot:
				slot.set_highlight(true)
			else:
				slot.set_highlight(false)

func set_current_slot(slot_index: int) -> void:
	# Only proceed if this is a hotbar
	if not is_hotbar:
		return
		
	# Store previous slot to clear its highlight
	var prev_slot = current_slot
	current_slot = slot_index
	
	# Update highlights
	if prev_slot != -1:
		update_slot_highlight(prev_slot)
	if current_slot != -1:
		update_slot_highlight(current_slot)
