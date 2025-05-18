extends Node

signal active_item_changed(item_data: ItemData)

@onready var player : Player


func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)


func get_global_position() -> Vector2:
	return player.global_position
