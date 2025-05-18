extends InventoryData
class_name InventoryDataEquip


var slot_types: Dictionary = {}

func set_slot_type(index: int, type: int) -> void:
	slot_types[index] = type

func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	# Only check for equipment items
	if grabbed_slot_data.item_data is ItemDataEquip and slot_types.has(index):
		var item_slot_type = grabbed_slot_data.item_data.slot_type
		var inventory_slot_type = slot_types[index]
		
		# If slot types don't match, return the item
		if item_slot_type != inventory_slot_type:
			return grabbed_slot_data
	
	# Proceed with normal drop logic if types match or not equipment
	return super.drop_slot_data(grabbed_slot_data, index)

func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	
	if not grabbed_slot_data.item_data is ItemDataEquip:
		return grabbed_slot_data
	
	return super.drop_single_slot_data(grabbed_slot_data, index)
