extends CharacterBody2D
class_name Player

const MAX_SPEED : float = 90.0
const ACCELERATION : float = 800.0
const DECELERATION : float = 800.0

signal toggle_inventory()
signal force_close()

#Player Inventory vars.
@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip
@export var hotbar_inventory_data: InventoryDataHotbar
@export var tilemap : TileMapLayer
@onready var interaction_finder: Node2D = $InteractionFinder
@onready var interaction_sprite = $InteractionFinder/InteractionFinderSprite
@onready var sprite: Sprite2D = $Sprite2D


var target : Node = null

func _ready() -> void:
	PlayerManager.player = self
	

func _unhandled_input(event: InputEvent) -> void:
	# Handle inventory toggle
	if Focus.event_is_action_pressed(event, "Inventory"):
		toggle_inventory.emit()
	
	# Handle interaction
	if Focus.event_is_action_pressed(event, "Interact") and target:
		if target.has_method("player_interact"):
			target.player_interact()
	
	# Handle tile changing
	if Focus.event_is_action_pressed(event, "tool_interact") and PlayerManager.current_tool == 0: 
		_change_tile()
	
	if Focus.event_is_action_pressed(event, "prev_slot"):
		scroll_hotbar(1)
		
	if Focus.event_is_action_pressed(event, "next_slot"):
		scroll_hotbar(-1)
	
	if Focus.event_is_action_pressed(event, "use_slot"):
		use_current_hotbar_slot()


#This function alone, changes tiles from one tile, to another when pressing enter or "ui_accept"
#We need to move this into a state, once made, and ensure were making sure the player
#has a tool_type HOE equipped in the tool slot, before allowing this function to be called.
func _change_tile():
	var _tillable = Vector2i(0, 0)
	var tilled = Vector2i(1, 0)
	var tilepos = tilemap.local_to_map(interaction_sprite.global_position)
	var tiledata = tilemap.get_cell_tile_data(tilepos)
	
	if tiledata:
		var tilename = tiledata.get_custom_data("tile_name")
		if "tillable" in tilename: tilemap.set_cell(tilepos, 0, tilled)
			

func _physics_process(delta : float) -> void:
	var input_vector : Vector2 = Focus.input_get_vector("left", "right", "up", "down").normalized()
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	_set_animation()
	move_and_slide()

func _process(_delta):
	hotbar_controls()

func _set_animation():
	if velocity.x < 0:
		sprite.flip_h = true
		interaction_finder.scale.x = -1
	elif velocity.x > 0:
		sprite.flip_h = false
		interaction_finder.scale.x = 1

func heal(_heal_value: int) -> void:
	pass

func hotbar_controls():
	for i in range(1, 10):
		if Input.is_action_just_pressed("hotbar_" + str(i)):
			hotbar_inventory_data.use_slot_data(i - 1)
			# Get reference to hotbar inventory and update selector
			var hotbar = get_tree().get_nodes_in_group("hotbar")
			if hotbar.size() > 0:
				hotbar[0].set_current_slot(i - 1)

func scroll_hotbar(direction: int) -> void:
	var hotbar = get_tree().get_nodes_in_group("hotbar")
	if hotbar.size() > 0:
		var inventory = hotbar[0]
		var new_slot = inventory.current_slot + direction
		
		# Wrap around if needed (0-8 for 9 slots)
		if new_slot < 0:
			new_slot = 8
		elif new_slot > 8:
			new_slot = 0
		
		# Update selection
		inventory.set_current_slot(new_slot)
		#hotbar_inventory_data.use_slot_data(new_slot)

func use_current_hotbar_slot():
	var hotbar = get_tree().get_nodes_in_group("hotbar")
	if hotbar.size() > 0:
		var current_slot = hotbar[0].current_slot
		if current_slot >= 0:  # Only use if a slot is selected
			hotbar_inventory_data.use_slot_data(current_slot)

func _on_body_entered(body) -> void:
	if body.has_method("player_interact"):
		target = body

func _on_body_exited(body) -> void:
	if target == body:
		force_close.emit()
		target = null

func save_data():
	if SaveSystem.data:
		SaveSystem.data.setup_from_player(self)

func load_data():
	if SaveSystem.data:
		SaveSystem.data.apply_to_player(self)
		inventory_data.inventory_updated.emit(inventory_data)
		equip_inventory_data.inventory_updated.emit(equip_inventory_data)
		hotbar_inventory_data.inventory_updated.emit(hotbar_inventory_data)
