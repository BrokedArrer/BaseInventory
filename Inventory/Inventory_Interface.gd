extends Control

signal drop_slot_data(slot_data: SlotData)

var grabbed_slot_data: SlotData
var external_inventory_owner 
var rng = RandomNumberGenerator.new()
signal force_close

@onready var player_inventory = $PlayerInventory
@onready var grabbed_slot = $GrabbedSlot
@onready var external_inventory = $ExternalInventory
@onready var equip_inventory = $EquipInventory
@onready var hotbar_inventory = $"../HotBarInventory"

func _physics_process(_delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5,5)
		
		
	###########Below is used to close external chests as an example.########
	if external_inventory_owner \
			and external_inventory_owner.global_position.distance_to(PlayerManager.get_global_position()) > 30:
		force_close.emit()
		
	
func set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)
	
func set_equip_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	equip_inventory.set_inventory_data(inventory_data)

func set_hotbar_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	hotbar_inventory.set_inventory_data(inventory_data)

func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)
	
	external_inventory.show()
	
func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		
		external_inventory.hide()
		external_inventory_owner = null
func on_inventory_interact(inventory_data: InventoryData,
		 index: int, button:int) -> void:
	
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	update_grabbed_slot()
	
func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()

func randomize_offset(base_position: Vector2) -> Vector2:
	# Calculate random offset (20-35 pixels)
	var offset_distance = rng.randf_range(20, 35)
	var offset_angle = rng.randf_range(0, TAU)
	var offset = Vector2.RIGHT.rotated(offset_angle) * offset_distance
	return base_position + offset


func drop_held_item(event: InputEventMouseButton) -> void:
	if not grabbed_slot_data:
		return
		
	if event.is_pressed():
		var drop_data: SlotData
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				# Drop entire stack
				drop_data = grabbed_slot_data
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				# Drop single item
				drop_data = grabbed_slot_data.create_single_slot_data()
				if grabbed_slot_data.quantity <= 0:
					grabbed_slot_data = null
		
		if drop_data:
			# Create collectable with random offset
			var collectable = preload("res://components/collectable/collectable.tscn").instantiate()
			collectable.slot_data = drop_data
			collectable.global_position = randomize_offset(PlayerManager.player.global_position)
			get_tree().current_scene.add_child(collectable)
			
			update_grabbed_slot()

func _on_gui_input(event):
	if event is InputEventMouseButton and grabbed_slot_data:
		drop_held_item(event)
	elif event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbed_slot_data: 
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbed_slot_data)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		update_grabbed_slot()


func _on_visibility_changed():
	if not visible and grabbed_slot_data:
		# Create a collectable with random offset from player position
		var collectable = preload('res://components/collectable/collectable.tscn').instantiate()
		collectable.slot_data = grabbed_slot_data
		collectable.global_position = randomize_offset(PlayerManager.player.global_position)
		get_tree().current_scene.add_child(collectable)
		
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()
