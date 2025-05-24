extends PanelContainer

signal hot_bar_use(index: int)

const Slot = preload("res://Inventory/Slot.tscn")


@onready var item_grid = $MarginContainer/ItemGrid


var slots: Array = []
var inventory_data: InventoryData


#func _unhandled_key_input(event: InputEvent) -> void:
	#if not visible or not event.is_pressed():
		#return 
		#
	#if range(KEY_1, KEY_9).has(event.keycode):
		#var slot_index = event.keycode - KEY_1
		#hot_bar_use.emit(slot_index)


func set_inventory_data(new_inventory_data: InventoryData) -> void:
	if inventory_data:
		inventory_data.inventory_updated.disconnect(populate_hot_bar)
		
	inventory_data = new_inventory_data
	inventory_data.inventory_updated.connect(populate_hot_bar)
	populate_hot_bar(inventory_data)
	hot_bar_use.connect(func(index: int): inventory_data.use_slot_data(index))

func populate_hot_bar(inventory_data: InventoryData) -> void:
	# Clear existing slots
	for child in item_grid.get_children():
		child.queue_free()
	slots.clear()
	
	# Create new slots
	for slot_data in inventory_data.slots:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		slots.append(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)
