extends Spatial

onready var crate_scene = preload("res://Crate/Crate.tscn")
var crates = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var currentCrates = $"Crates".get_children()
	for currentCrate in currentCrates:
		crates.append({"x": currentCrate.transform.origin.x, "y": currentCrate.transform.origin.y, "z": currentCrate.transform.origin.z})
	WebSocket.map_loaded(self)
	
func respawnCrates():
	#Remove all crates
	var currentCrates = $"Crates".get_children()
	for currentCrate in currentCrates:
		$"Crates".remove_child(currentCrate)
		currentCrate.queue_free()
	for crate in crates:
		var newCrate = crate_scene.instance()
		newCrate.transform.origin.x = crate.x
		newCrate.transform.origin.y = crate.y
		newCrate.transform.origin.z = crate.z
		$"Crates".add_child(newCrate)
