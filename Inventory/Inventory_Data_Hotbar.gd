class_name InventoryDataHotbar extends InventoryData

func grab_slot_data(index: int) -> SlotData:
	var slot_data = slots[index]

	if slot_data:
		# Clear the slot if it contains data and emit the inventory update signal
		slots[index] = null
		inventory_updated.emit(self)
		return slot_data
	else:
		return null

# Function to handle dropping slot data when an item is grabbed and moved to a new slot.
func drop_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	# Check if the item data associated with the grabbed slot is an instance of ItemDataTool, ItemDataConsumable, or ItemDataWeapon.
	if not grabbed_slot_data.item_data is ItemDataConsumable:
		# If not, return the original grabbed_slot_data without making any changes.
		return grabbed_slot_data

	# If the item data is of type ItemDataEquip, call the drop_slot_data function of the superclass.
	return super.drop_slot_data(grabbed_slot_data, index)

# Function to handle dropping a single slot of data when an item is grabbed and moved.
func drop_single_slot_data(grabbed_slot_data: SlotData, index: int) -> SlotData:
	# Check if the item data associated with the grabbed slot is an instance of ItemDataTool, ItemDataConsumable, or ItemDataWeapon.
	if not grabbed_slot_data.item_data is ItemDataConsumable:
		# If not, return the original grabbed_slot_data without making any changes.
		return grabbed_slot_data

	# If the item data is of type ItemDataEquip, call the drop_single_slot_data function of the superclass.
	return super.drop_single_slot_data(grabbed_slot_data, index)

func _input(_event):
	pass

func use_slot_data(index: int) -> void:
	var slot_data = slots[index]

	if not slot_data:
		return

	# Check if the item data associated with the slot is an instance of ItemDataConsumable, ItemDataTool, or ItemDataWeapon.
	if slot_data.item_data is ItemDataConsumable:
		print(slot_data.item_data.name)
		print("You used the item " + slot_data.item_data.name)
		# If the item is consumable, decrease its quantity and remove it if necessary
		slot_data.quantity -= 1
		if slot_data.quantity < 1:
			slots[index] = null
		inventory_updated.emit(self)
		
		
		# Call the use_slot_data function on the PlayerManager with the slot data
		PlayerManager.use_slot_data(slot_data)

		# Emit the inventory update signal
		inventory_updated.emit(self)


func on_slot_clicked(index: int, button: int):
	# Emit the inventory interaction signal with the clicked slot's index and button
	inventory_interact.emit(self, index, button)

