extends KinematicBody

var velocity = Vector3.ZERO

var Walk_Speed = 0

var vertical_velocity = 0
var gravity = 20

export var Accelaration = 2
export var Maximum_Walk_Speed = 10

var username = ""
var player_id = null
var room_index = null

var bomb_size = 0.5
var bombs = 1
var maxBombs = 1

var walkState = {
	'up': false,
	'down': false,
	'left': false,
	'right': false,
}

var dead = false

onready var animPlayer = $"Model/Rig/AnimationPlayer"

onready var namePlate = $"NamePlate/Viewport/Label"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func killed(killed_by):
	if dead != true:
		#dead = true
		set_collision_layer_bit(3, false)
		#set_physics_process(false)
		WebSocket._send_killed(player_id, killed_by, global_transform.origin)
		
func die(data):
	dead = true
	animPlayer.play("Death")
	global_transform.origin.x = data.position.x
	global_transform.origin.y = data.position.y
	global_transform.origin.z = data.position.z

func _anim_finished(animationName):
	if animationName == "Death":
		print("dead finished")
		$"Model".visible = false
		$"NamePlate".visible = false
		
func _ready():
	animPlayer.connect("animation_finished", self, "_anim_finished")
	
func resetVars():
	bomb_size = 0.5
	Maximum_Walk_Speed = 5
	bombs = 1
	maxBombs = 1

func startRound():
	dead = false
	resetVars()
	$"Model".visible = true
	$"NamePlate".visible = true
	animPlayer.play("Idle")
	set_collision_layer_bit(4, true)
	walkState = {
	'up': false,
	'down': false,
	'left': false,
	'right': false,
	}
	var scene_root = get_tree().get_current_scene()
	global_transform.origin = scene_root.get_node("Map").get_node("map").get_node("Spawns").get_children()[room_index].global_transform.origin
	set_physics_process(true)
		
		
func bombRespawn():
	if bombs < maxBombs:
		bombs += 1
		
func _physics_process(delta):
	if dead != true:
		handleMotion()

func handleMotion():
	if walkState.up:
		Walk_Speed += Accelaration
		if Walk_Speed > Maximum_Walk_Speed:
			Walk_Speed = Maximum_Walk_Speed
		velocity.x = -global_transform.basis.z.x * Walk_Speed
		velocity.z = -global_transform.basis.z.z * Walk_Speed
	if walkState.down:
		Walk_Speed += Accelaration
		if Walk_Speed > Maximum_Walk_Speed:
			Walk_Speed = Maximum_Walk_Speed
		velocity.x = global_transform.basis.z.x * Walk_Speed
		velocity.z = global_transform.basis.z.z * Walk_Speed
	if walkState.left:
		Walk_Speed += Accelaration
		if Walk_Speed > Maximum_Walk_Speed:
			Walk_Speed = Maximum_Walk_Speed
		velocity.x = -global_transform.basis.x.x * Walk_Speed
		velocity.z = -global_transform.basis.x.z * Walk_Speed
		
	if walkState.right:
		Walk_Speed += Accelaration
		if Walk_Speed > Maximum_Walk_Speed:
			Walk_Speed = Maximum_Walk_Speed
		velocity.x = global_transform.basis.x.x * Walk_Speed
		velocity.z = global_transform.basis.x.z * Walk_Speed
		
	#if not(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_RIGHT)):
	#	velocity.x = 0
	#	velocity.z = 0
	if not(walkState.up or walkState.down or walkState.left or walkState.right):
		velocity.x = 0
		velocity.z = 0
	
	velocity.y = -1
	velocity = move_and_slide(velocity, Vector3(0,1,0), false, 4, 0.25)
	if (velocity.x >= 0.01 || velocity.x < -0.01) || (velocity.z >= 0.01 || velocity.z < -0.01):
		if animPlayer.get_current_animation() == "Idle":
			animPlayer.play("Run")
	else:
		if animPlayer.get_current_animation() == "Run":
			animPlayer.play("Idle")
