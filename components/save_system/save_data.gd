extends Resource
class_name SaveData

# Player's position in the world
@export var player_position : Vector2

# Arrays containing serialized inventory data:
@export var inventory_slots : Array   # Main inventory
@export var equip_slots : Array       # Equipment slots  
@export var hotbar_slots : Array      # Hotbar slots

# Dictionary mapping chest instance IDs to their saved data
# Format: {instance_id: {inventory: [...], position: Vector2}}
@export var chest_data : Dictionary

# Populates save data from a Player instance
func setup_from_player(player: Player) -> void:
	player_position = player.global_position
	setup_from_inventory(player.inventory_data, inventory_slots)
	setup_from_inventory(player.equip_inventory_data, equip_slots)
	setup_from_inventory(player.hotbar_inventory_data, hotbar_slots)

# Serializes an inventory into the target array
func setup_from_inventory(inv_data: InventoryData, target_array: Array) -> void:
	target_array.clear()
	for slot in inv_data.slots:
		if slot and slot.item_data:
			var saved_slot = {
				"item_path": slot.item_data.resource_path if slot.item_data.resource_path else "",
				"item_data": slot.item_data,
				"quantity": slot.quantity
			}
			target_array.append(saved_slot)
		else:
			target_array.append(null)

# Applies saved data back to a Player instance
func apply_to_player(player: Player) -> void:
	player.global_position = player_position
	apply_to_inventory(player.inventory_data, inventory_slots)
	apply_to_inventory(player.equip_inventory_data, equip_slots)
	apply_to_inventory(player.hotbar_inventory_data, hotbar_slots)

# Loads inventory data from the source array into an InventoryData
func apply_to_inventory(inv_data: InventoryData, source_array: Array) -> void:
	if source_array.is_empty():
		return
		
	# Ensure inventory has enough slots
	while inv_data.slots.size() < source_array.size():
		inv_data.slots.append(null)
	
	# Restore each slot
	for i in range(source_array.size()):
		if source_array[i]:
			var slot_data = SlotData.new()
			
			# Try loading from path first
			if source_array[i].get("item_path", ""):
				var loaded_item = load(source_array[i]["item_path"])
				if loaded_item:
					slot_data.item_data = loaded_item
			
			# Fallback to direct reference
			if not slot_data.item_data and source_array[i].get("item_data"):
				slot_data.item_data = source_array[i]["item_data"]
			
			slot_data.quantity = source_array[i]["quantity"]
			inv_data.slots[i] = slot_data
		else:
			inv_data.slots[i] = null
	
	# Update any connected UI
	inv_data.inventory_updated.emit(inv_data)
