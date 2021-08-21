extends KinematicBody

var velocity = Vector3.ZERO

var Walk_Speed = 0

var vertical_velocity = 0
var gravity = 20

export var Accelaration = 2
export var Maximum_Walk_Speed = 5

var username = ""
var player_id = null
var room_index = null

var bomb_size = 0.5
var bombs = 1
var maxBombs = 1

onready var start_timer = $"startTimer"
var start_time = 3

var walkState = {
	'up': false,
	'down': false,
	'left': false,
	'right': false,
}

enum gameStates {
	WAITING,
	ROUND_STARTING,
	PLAYING,
}

var gamestate = gameStates.WAITING

var dead = false

onready var animPlayer = $"Model/Rig/AnimationPlayer"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func killed(killed_by):
	if dead != true:
		#dead = true
		set_collision_layer_bit(3, false)
		WebSocket._send_killed(player_id, killed_by, global_transform.origin)
		
func die(data):
	dead = true
	animPlayer.play("Death")
	global_transform.origin.x = data.position.x
	global_transform.origin.y = data.position.y
	global_transform.origin.z = data.position.z

func _anim_finished(animationName):
	print(animationName)
	if animationName == "Death":
		print("dead finished")
		$"Model".visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	WebSocket.player_loaded(self)
	animPlayer.connect("animation_finished", self, "_anim_finished")
	animPlayer.get_animation("Idle").set_loop(true)
	animPlayer.get_animation("Run").set_loop(true)
	set_physics_process(false)
	#_client.connect("connection_established", self, "_on_connected")

func clearAllBombs():
	var scene_root = get_tree().get_current_scene()
	var items = scene_root.get_node("Items").get_children()
	for item in items:
		scene_root.get_node("Items").remove_child(item)

func resetVars():
	bomb_size = 0.5
	Maximum_Walk_Speed = 5
	bombs = 1
	maxBombs = 1
	
func startRound():
	clearAllBombs()
	resetVars()
	start_time = 3
	start_timer.start()
	gamestate = gameStates.ROUND_STARTING
	dead = false
	$"Model".visible = true
	$CenterMsg.visible = true
	set_collision_layer_bit(3, true)
	walkState = {
	'up': false,
	'down': false,
	'left': false,
	'right': false,
	}
	$"CenterMsg/Viewport/Label".text = "Round " + String(WebSocket.current_round) + "/" + String(WebSocket.max_rounds) + "\n" + "Starting in " + String(start_time) + " seconds."
	var scene_root = get_tree().get_current_scene()
	global_transform.origin = scene_root.get_node("Map").get_node("map").get_node("Spawns").get_children()[room_index].global_transform.origin
	set_physics_process(true)
	animPlayer.play("Idle")
	scene_root.get_node("Map").get_node("map").respawnCrates()
	var players = scene_root.get_node("Players").get_children()
	for currentPlayer in players:
		if currentPlayer.player_id != player_id:
			currentPlayer.startRound()
	#instacedScene.global_transform.origin = scene_root.get_node("Map").get_node("map").get_node("Spawns").get_children()[payload.id].global_transform.origin
	
	
func canPlay():
	return dead != true && gamestate == gameStates.PLAYING
	
func canPlant():
	return canPlay() && bombs > 0

func bombRespawn():
	if bombs < maxBombs:
		bombs += 1

func _physics_process(delta):
	if canPlay():
		handleMotion()
	if canPlant() && Input.is_action_just_pressed("plant_bomb"):
		bombs -= 1
		var pkt = { "type": "plant_bomb", "position": { "x": global_transform.origin.x, "y": global_transform.origin.y, "z": global_transform.origin.z } }
		WebSocket._send(pkt)

func updateWalkState(newWalkState):
	#need to fix mess with states
	#maybe check state matches on recv?
	#if it doesnt ask server ever something MS to pls update statate
	#but still wait for confirm from server so all up to date
	#issue with wonky movements is because
	#sending 1 state saying ok we walking up
	#then not saving it and sending another saying we walkin right but not up when we still
	#should be walking up
	newWalkState.position = { "x": global_transform.origin.x, "y": global_transform.origin.y, "z": global_transform.origin.z }
	WebSocket._sendWalkState(newWalkState)

func handleMotion():
	#
	#var newWalkState = walkState.duplicate(true)
	var newWalkState = walkState
	newWalkState.changed = false
	if Input.is_action_just_pressed("walk_up"):
		newWalkState.up = true
		newWalkState.changed = true
	if Input.is_action_just_released("walk_up"):
		newWalkState.up = false
		newWalkState.changed = true
	if Input.is_action_just_pressed("walk_down"):
		newWalkState.down = true
		newWalkState.changed = true
	if Input.is_action_just_released("walk_down"):
		newWalkState.down = false
		newWalkState.changed = true
	if Input.is_action_just_pressed("walk_left"):
		newWalkState.left = true
		newWalkState.changed = true
	if Input.is_action_just_released("walk_left"):
		newWalkState.left = false
		newWalkState.changed = true
	if Input.is_action_just_pressed("walk_right"):
		newWalkState.right = true
		newWalkState.changed = true
	if Input.is_action_just_released("walk_right"):
		newWalkState.right = false
		newWalkState.changed = true
	
	if newWalkState.changed:
		updateWalkState(newWalkState)
		
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
	
	velocity.y = -2
	velocity = move_and_slide(velocity, Vector3(0,1,0), false, 4, 0.25)
	if (velocity.x >= 0.01 || velocity.x < -0.01) || (velocity.z >= 0.01 || velocity.z < -0.01):
		if animPlayer.get_current_animation() == "Idle":
			animPlayer.play("Run")
	else:
		if animPlayer.get_current_animation() == "Run":
			animPlayer.play("Idle")
	#move_and_collide(velocity, Vector3(0,1,0), false, 4, 0.25)


func _on_startTimer_timeout():
	start_time = start_time - 1
	if start_time == 0:
		gamestate = gameStates.PLAYING
		start_timer.stop()
		$"CenterMsg".visible = false
	else:
		$"CenterMsg/Viewport/Label".text = "Round " + String(WebSocket.current_round) + "/" + String(WebSocket.max_rounds) + "\n" + "Starting in " + String(start_time) + " seconds."
