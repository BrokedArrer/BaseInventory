extends Node2D


@onready var player = $Player


@onready var inventory_interface: Control = $InventoryUI/InventoryInterface
@onready var hotbar_inventory = $InventoryUI/HotBarInventory

func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	inventory_interface.set_hotbar_inventory_data(player.hotbar_inventory_data)
	#inventory_interface.force_close.connect(toggle_inventory_interface)
	inventory_interface.set_equip_inventory_data(player.equip_inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)



func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()




