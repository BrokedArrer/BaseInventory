extends PanelContainer

signal slot_clicked(index: int, button:int)
@onready var texture_rect = $MarginContainer/TextureRect
@onready var quantity_label = $QuantityLabel

@export_enum("NONE:0", "HEAD:1", "CHEST:2", "LEGS:3", "MAIN:4", "SECONDARY:5", "TOOL:6", "ACCESSORY:7") 
var slot_type: int = 0


func set_slot_data(slot_data: SlotData) -> void:
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
		
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()

func get_slot_type() -> int:
	return slot_type


func _on_gui_input(event):
	if event is InputEventMouseButton \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT) \
			and event.is_pressed():
		slot_clicked.emit(get_index(), event.button_index)
