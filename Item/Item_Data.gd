extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var texture: AtlasTexture
@export_enum ("Weapon", "Armor", "Potion", "Quest", "Accessory", "Tool", "General")
var type : String = "General"

@export_enum("Material","Common", "Uncommon", "Rare", "Epic", "Legendary")
var rarity : String = "Common"


func use(_target) -> void:
	pass
