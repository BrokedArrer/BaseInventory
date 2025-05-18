extends StaticBody2D
class_name Chest

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData

func _ready():
	# Ensures this chest is added to the external_inventory group for saving
	if not is_in_group("external_inventory"):
		add_to_group("external_inventory")

func player_interact() -> void:
	toggle_inventory.emit(self)

# Serializes the chest's inventory data into a dictionary format for saving
# Returns: Dictionary containing:
#   - inventory: Array of slot data (item paths, quantities)
#   - position: Current global position of the chest
func save_data() -> Dictionary:
	var saved_slots = []
	if inventory_data:  # Safety check for null inventory
		for slot in inventory_data.slots:
			if slot and slot.item_data:
				saved_slots.append({
					"item_path": slot.item_data.resource_path if slot.item_data.resource_path else "",
					"item_data": slot.item_data,
					"quantity": slot.quantity
				})
			else:
				saved_slots.append(null)
	return {
		"inventory": saved_slots,
		"position": global_position  # Save position for movable chests
	}

# Loads saved inventory data back into the chest
# data: Dictionary containing saved inventory data (from save_data())
func load_data(data: Dictionary) -> void:
	if not inventory_data or data.is_empty() or not data.has("inventory"):
		return
		
	var saved_slots = data["inventory"]
	
	# Ensure inventory has enough slots to hold loaded data
	while inventory_data.slots.size() < saved_slots.size():
		inventory_data.slots.append(null)
	
	# Restore each slot's data
	for i in range(saved_slots.size()):
		if saved_slots[i]:
			var slot_data = SlotData.new()
			
			# Try loading item from resource path first (more reliable)
			if saved_slots[i].get("item_path", ""):
				var loaded_item = load(saved_slots[i]["item_path"])
				if loaded_item:
					slot_data.item_data = loaded_item
			
			# Fallback to direct item_data reference if path loading failed
			if not slot_data.item_data and saved_slots[i].get("item_data"):
				slot_data.item_data = saved_slots[i]["item_data"]
			
			slot_data.quantity = saved_slots[i]["quantity"]
			inventory_data.slots[i] = slot_data
		else:
			inventory_data.slots[i] = null
	
	# Restore chest position if it was saved
	if data.has("position"):
		global_position = data["position"]
	
	# Notify UI to update if inventory is open
	inventory_data.inventory_updated.emit(inventory_data)
