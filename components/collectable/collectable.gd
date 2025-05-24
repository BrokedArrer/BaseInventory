extends Area2D
class_name Collectable

signal picked_up

@export var slot_data: SlotData
@onready var sprite_2d = $Sprite2D



func _ready() -> void:
	if slot_data and slot_data.item_data:
		sprite_2d.texture = slot_data.item_data.texture
	slot_data = slot_data


func _try_collect(body : Player) -> void:
	if body.is_in_group("player") and PlayerManager.player:
		var success = PlayerManager.player.inventory_data.pick_up_slot_data(slot_data)
		if success:
			queue_free()
			picked_up.emit()


func _on_body_entered(body: Node2D) -> void:
	_try_collect(body)
