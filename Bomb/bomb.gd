extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	set_collision_layer_bit(0, true)
	set_collision_layer_bit(3, true)
	set_collision_layer_bit(4, true)
	add_collision_exception_with(body)
	



func _on_Area_body_exited(body):
	remove_collision_exception_with(body)
