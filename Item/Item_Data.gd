extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var texture: AtlasTexture
@export_enum ("Weapon", "Armor", "Potion", "Quest", "Accessory")
var type : String = ""

@export_enum("General", "Material","Common", "Uncommon", "Rare", "Epic", "Legendary")
var rarity : String = "General"


func use(_target) -> void:
	pass
