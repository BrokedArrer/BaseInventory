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
@onready var interactable_area: Area2D = $InteractableArea

var target : Node = null

func _ready() -> void:
	PlayerManager.player = self
	#equip_inventory_data.inventory_updated.connect(PlayerManager.update_equipment)

func _unhandled_input(_event: InputEvent):
	if Focus.event_is_action_pressed(_event, "Inventory"):
		toggle_inventory.emit()
	if Focus.event_is_action_pressed(_event, "Interact") and target:
		if target.has_method("player_interact"):
			target.player_interact()

func _physics_process(delta : float) -> void:
	var input_vector : Vector2 = Focus.input_get_vector("left", "right", "up", "down").normalized()
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	move_and_slide()

func _process(_delta):
	hotbar_controls()

func heal(_heal_value: int) -> void:
	pass

func hotbar_controls():
	for i in range(1, 10):
		if Input.is_action_just_pressed("hotbar_" + str(i)):
			hotbar_inventory_data.use_slot_data(i - 1)

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
