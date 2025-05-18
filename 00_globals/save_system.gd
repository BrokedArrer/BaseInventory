extends Node

const path = "user://AutoSave.tres"  # Persistent save file location
var data : SaveData  # Reference to our save data resource

# Initialize a new SaveData resource when the system loads
func _ready() -> void:
	data = SaveData.new()

# Saves all game data including:
# - Player data (via save group)
# - All chest inventories
# - Writes to disk using ResourceSaver
func save_data():
	# First collect data from all nodes in the "save" group (player, inventories)
	get_tree().call_group("save", "save_data")
	
	# Reset and repopulate chest data dictionary
	data.chest_data = {}
	for chest in get_tree().get_nodes_in_group("external_inventory"):
		# Store each chest's data using its instance ID as the key
		data.chest_data[chest.get_instance_id()] = chest.save_data()
	
	# Save to persistent storage
	ResourceSaver.save(data, path)

# Loads all game data including:
# - Player data (via save group)
# - All chest inventories
# Returns: true if load succeeded, false if no save file exists
func load_data():
	if not FileAccess.file_exists(path):
		return false
	
	# Load the save file from disk
	data = ResourceLoader.load(path, "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE)
	if not data:
		return false
	
	# First load player data
	get_tree().call_group("save", "load_data")
	
	# Then load each chest's inventory data
	for chest in get_tree().get_nodes_in_group("external_inventory"):
		var chest_id = chest.get_instance_id()
		if data.chest_data.has(chest_id):
			chest.load_data(data.chest_data[chest_id])
	
	return true

# Handles keyboard shortcuts for quick saving/loading (F5/F4)
func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_F5:
			save_data()
		if event.keycode == KEY_F4:
			load_data()
