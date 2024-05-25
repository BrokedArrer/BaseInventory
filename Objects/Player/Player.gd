extends CharacterBody2D
class_name Player

signal toggle_inventory()
#Player Inventory vars.
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip
@export var hotbar_inventory_data: InventoryDataHotbar




func _ready() -> void:
	PlayerManager.player = self


func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("Inventory"):
		toggle_inventory.emit()



func _process(_delta):
	hotbar_controls()


func heal(_heal_value: int) -> void:
	pass

func hotbar_controls():
	for i in range(10):
		if Input.is_action_just_released("hotbar_" + str(i)):
			hotbar_inventory_data.use_slot_data(i)

