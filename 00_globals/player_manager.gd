extends Node


# Signals
signal tool_changed(tool_type: int)
signal equipment_changed(slot_index: int, item_data: ItemData)

# Equipment Tracking
var current_tool: int = -1  # -1 means no tool equipped
var equipment_slots: Array[ItemData] = []  # Tracks items in slots 0-5
var player: Player = null



func _ready() -> void:
	# Initialize equipment slots array
	equipment_slots.resize(6)
	equipment_slots.fill(null)
	
	# Wait for player initialization
	await get_tree().process_frame
	if player:
		player.equip_inventory_data.inventory_updated.connect(update_equipment)
		update_equipment(player.equip_inventory_data)

# Public method to update equipment (including tool)
func update_equipment(inventory_data: InventoryData) -> void:
	if !player:
		return
	
	# Update tool in slot 6
	var tool_slot_index = 6
	var tool_slot_data = inventory_data.slots[tool_slot_index] if inventory_data.slots.size() > tool_slot_index else null
	var new_tool = -1
	if tool_slot_data and tool_slot_data.item_data is EquipDataTool:
		new_tool = tool_slot_data.item_data.tool_type
	
	if new_tool != current_tool:
		current_tool = new_tool
		tool_changed.emit(current_tool)
	
	# Update equipment slots 0-5
	for slot_index in range(0, 6):
		var slot_data = inventory_data.slots[slot_index] if inventory_data.slots.size() > slot_index else null
		var new_item = slot_data.item_data if slot_data else null
		
		if equipment_slots[slot_index] != new_item:
			equipment_slots[slot_index] = new_item
			equipment_changed.emit(slot_index, new_item)

# Item interaction
func use_slot_data(slot_data: SlotData) -> void:
	if slot_data and slot_data.item_data:
		slot_data.item_data.use(player)

# Player position access
func get_global_position() -> Vector2:
	return player.global_position if player else Vector2.ZERO

# Tool access
func get_current_tool() -> int:
	return current_tool

# Equipment access
func get_equipped_item(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= equipment_slots.size():
		return null
	return equipment_slots[slot_index]

func is_item_equipped(item_data: ItemData) -> bool:
	return equipment_slots.has(item_data)

func get_all_equipped_items() -> Array[ItemData]:
	return equipment_slots.duplicate()

func get_hotbar_inventory():
	# Implement this to return your hotbar inventory reference
	return null
