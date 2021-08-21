extends Spatial


onready var map_scene = preload("res://Levels/bomberlevel3.tscn")
onready var bomb_up = preload("res://Pickups/Bomb up.tscn")
onready var bomb_plus = preload("res://Pickups/Bomb plus.tscn")
onready var boots = preload("res://Pickups/Boots.tscn")

onready var Items = $"Items"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var mapInstance = map_scene.instance()
	get_node("Map").add_child(mapInstance)

func addItem(item_id, position):
	var instance_pickup = null
	if item_id == 0:
		instance_pickup = bomb_up.instance()
	if item_id == 1:
		instance_pickup = bomb_plus.instance()
	if item_id == 2:
		instance_pickup = boots.instance()
	Items.add_child(instance_pickup)
	instance_pickup.global_transform.origin.x = position.x
	instance_pickup.global_transform.origin.y = position.y
	instance_pickup.global_transform.origin.z = position.z

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
