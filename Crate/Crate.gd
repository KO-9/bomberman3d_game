extends Spatial

var exploded = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func explode():
	if exploded:
		return
	exploded = true
	print("crate_exploded")
	WebSocket.crate_exploded($"CenterPoint".global_transform.origin)
	#$"Bodies/Down".set_collision_layer_bit()
	var bodies = $"Bodies".get_children()
	for body in bodies:
		body.set_mode(body.MODE_RIGID)
		body.apply_impulse(Vector3(0,0,0), Vector3(1, -1, 0))
		body.set_collision_layer_bit(0, false)
		body.set_collision_layer_bit(3, false)
		body.set_collision_layer_bit(4, false)
		
	$"destroyTimer".start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_destroyTimer_timeout():
	queue_free()
