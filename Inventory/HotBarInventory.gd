extends PanelContainer

signal hot_bar_use(index: int)
signal item_selected(item_data: ItemData)

const Slot = preload("res://Inventory/Slot.tscn")

@onready var h_box_container = $MarginContainer/HBoxContainer

var current_index := 0:
	set(value):
		current_index = wrapi(value, 0, get_child_count())
		_update_selection()

var current_item: ItemData:
	get:
		if get_child_count() > 0 and get_child(current_index).has_method("get_item_data"):
			return get_child(current_index).get_item_data()
		return null

func _ready():
	_update_selection()

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				current_index -= 1
			MOUSE_BUTTON_WHEEL_DOWN:
				current_index += 1

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_pressed():
		return 
		
	if range(KEY_1, KEY_9).has(event.keycode):
		hot_bar_use.emit(event.keycode - KEY_1)

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_hot_bar)
	populate_hot_bar(inventory_data)
	hot_bar_use.connect(inventory_data.use_slot_data)

func populate_hot_bar(inventory_data: InventoryData) -> void:
	for child in h_box_container.get_children():
		child.queue_free()

	for slot_data in inventory_data.slots.slice(0, 6):
		var slot = Slot.instantiate()
		h_box_container.add_child(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)


func _update_selection():
	# Highlight the selected slot and emit signal
	for i in get_child_count():
		var slot = get_child(i)
		if slot is Control:
			slot.modulate = Color.WHITE if i == current_index else Color(0.7, 0.7, 0.7)
	
	if current_item:
		item_selected.emit(current_item)

func get_current_item() -> ItemData:
	return current_item
