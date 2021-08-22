extends Spatial

onready var lobby_scene = preload("res://Lobby/Lobby.tscn")
onready var player_scene = preload("res://Player/Player.tscn")
onready var main_menu_scene = preload("res://MainMenu.tscn")
onready var otherplayer_scene = preload("res://Player/OtherPlayer.tscn")
onready var map_scene = preload("res://GameContainer.tscn")
onready var explosion = preload("res://Bomb/explosion.tscn")

#export var SOCKET_URI = "ws://127.0.0.1:3000"
export var SOCKET_URI = "wss://ollieb.co.uk:3000"
var _client = WebSocketClient.new()
var username = ""
var player = null
var player_id = null
var room_index = null
var player_state = playerStates.IDLE
var room_players = []
var map = null

var current_round = 0
var max_rounds = 0

var loginPacket = null

enum WebSocketStates {
	DISCONNECTED,
	CONNECTED
}

enum playerStates {
	IDLE,
	IN_LOBBY,
	IN_GAME,
}

var WebSocketState = WebSocketStates.DISCONNECTED

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_client.connect("connection_established", self, "_on_connected")
	_client.connect("connection_closed", self, "_on_connection_closed")
	_client.connect("connection_error", self, "_on_connection_closed")
	_client.connect("data_received", self, "_on_data")


func ws_connect():
	username = loginPacket.username
	var err = _client.connect_to_url(SOCKET_URI)
	if err != OK:
		print("Unable to connect")

func login():
	var packet = JSON.print(loginPacket).to_utf8()
	_client.get_peer(1).put_packet(packet)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	_client.poll()

func _on_connected(proto = ""):
	print("connected")
	WebSocketState = WebSocketStates.CONNECTED
	login()

func _on_connection_closed(was_clean = false):
	WebSocketState = WebSocketStates.DISCONNECTED
	player_state = playerStates.IDLE
	get_tree().change_scene_to(main_menu_scene)
	print("Closed clean: ", was_clean)
	
func _sendWalkState(walkState):
	walkState = { "type": "walkState", "walkState": walkState }
	var packet = JSON.print(walkState).to_utf8()
	_client.get_peer(1).put_packet(packet)

func load_map():
	get_tree().change_scene_to(map_scene)

func map_loaded(newMap):
	map = newMap
	player_state = playerStates.IN_GAME
	var scene_root = get_tree().get_current_scene()
	var instacedScene = player_scene.instance()
	scene_root.get_node("Players").add_child(instacedScene)
	instacedScene.global_transform.origin = scene_root.get_node("Map").get_node("map").get_node("Spawns").get_children()[player_id].global_transform.origin
	loadPlayers()
	_send({"type": "map_loaded"})

func player_loaded(newPlayer):
	player = newPlayer
	player.player_id = player_id
	player.room_index = room_index
	
func handleLobbyState(payload):
	if player_state == playerStates.IDLE:
		player_id = payload.your_id
		room_index = payload.your_room_index
		var lobby_instance = lobby_scene.instance()
		lobby_instance.players = payload.players
		lobby_instance.code = payload.code
		get_node("/root").add_child(lobby_instance)
		get_node("/root").remove_child(get_node("/root").get_node("MainMenu"))
		get_tree().current_scene = lobby_instance
		player_state = playerStates.IN_LOBBY
	elif player_state == playerStates.IN_LOBBY:
		var lobby_node = get_node("/root").get_node("Lobby")
		lobby_node.updateState(payload.players)
	
func addNewBomb(payload):
	var scene_root = get_tree().get_current_scene()
	var instancedexplosion = explosion.instance()
	print(payload.position.x)
	var bomb_player = yield(findPlayerById(payload.id), "completed")
	instancedexplosion.player = bomb_player
	scene_root.get_node("Items").add_child(instancedexplosion)
	#instancedexplosion.get_node("Bomb").get_node("bomb").add_collision_exception_with(bomb_player)
	instancedexplosion.global_transform.origin.x = payload.position.x
	#instancedexplosion.global_transform.origin.y = payload.position.y + 1.2
	instancedexplosion.global_transform.origin.y = payload.position.y + 0.5
	instancedexplosion.global_transform.origin.z = payload.position.z
	
func findPlayerById(id):
	var Players = get_tree().get_current_scene().get_node("Players").get_children()
	for currentPlayer in Players:
		if currentPlayer.player_id == id:
			yield(get_tree(), "idle_frame")
			return currentPlayer
	return null
	
func updatePlayerState(payload):
	if payload.id == player_id:
		return
		#player.global_transform.origin.x = payload.position.x
		#player.global_transform.origin.y = payload.position.y
		#player.global_transform.origin.z = payload.position.z
		#player.walkState = payload.walkState
	else:
		var currentPlayer = yield(findPlayerById(payload.id), "completed")
		if currentPlayer != null:
			currentPlayer.walkState = payload.walkState
			currentPlayer.global_transform.origin.x = payload.position.x
			currentPlayer.global_transform.origin.y = payload.position.y
			currentPlayer.global_transform.origin.z = payload.position.z

func startRound(payload):
	current_round = payload.round
	max_rounds = payload.max_rounds
	player.startRound()
	
func spawnItem(payload):
	if player_state == playerStates.IN_GAME:
		var scene_root = get_tree().get_current_scene()
		scene_root.addItem(payload.item_id, payload.position)

func loadPlayers():
	var scene_root = get_tree().get_current_scene()
	for currentPlayer in room_players:
		if currentPlayer.id != player_id:
			var instacedScene = otherplayer_scene.instance()
			instacedScene.player_id = currentPlayer.id
			instacedScene.room_index = currentPlayer.room_index
			instacedScene.username = currentPlayer.username
			instacedScene.name = currentPlayer.username
			scene_root.get_node("Players").add_child(instacedScene)
			instacedScene.global_transform.origin = scene_root.get_node("Map").get_node("map").get_node("Spawns").get_children()[currentPlayer.room_index].global_transform.origin
			instacedScene.namePlate.text = currentPlayer.username
			
func addNewPlayer(payload):
	var scene_root = get_tree().get_current_scene()
	var instacedScene = otherplayer_scene.instance()
	instacedScene.player_id = payload.id
	instacedScene.username = payload.username
	instacedScene.name = payload.username
	scene_root.get_node("Players").add_child(instacedScene)
	instacedScene.global_transform.origin = scene_root.get_node("Map").get_node("map").get_node("Spawns").get_children()[payload.id].global_transform.origin
	instacedScene.namePlate.text = payload.username

func playerKilled(payload):
	var killed_player = null
	if payload.id == player_id:
		killed_player = player
	else:
		killed_player = yield(findPlayerById(payload.id), "completed")
	
	if killed_player != null:
		killed_player.die(payload)
		
func gameEnded(payload):
	var lobby_instance = lobby_scene.instance()
	lobby_instance.players = payload.players
	lobby_instance.code = payload.code
	lobby_instance.state = "game_ended"
	get_node("/root").add_child(lobby_instance)
	get_node("/root").remove_child(get_node("/root").get_node("GameContainer"))
	get_tree().current_scene = lobby_instance
	player_state = playerStates.IN_LOBBY
	
func _on_data():
	var payload = JSON.parse(_client.get_peer(1).get_packet().get_string_from_utf8()).result
	#print("received: ", payload)
	if ("msg" in payload) && payload.msg == "OK":
		pass
	if ("type" in payload):
		match payload.type:
			"login":
				if payload.status == 1:
					player_id = payload.id
					load_map()
					print("logged in")
			"walkState":
				updatePlayerState(payload)
			"newPlayer":
				addNewPlayer(payload)
			"plant_bomb":
				addNewBomb(payload)
			"player_killed":
				playerKilled(payload)
			"lobby_state":
				handleLobbyState(payload)
			"lobby_start":
				load_map()
			"round_restart":
				startRound(payload)
			"spawn_item":
				spawnItem(payload)
			"game_ended":
				gameEnded(payload)
	
func updateState(pkt):
	_client.get_peer(1).put_packet(pkt)
	
func startLobby():
	_send({"type": "lobby_start"})

func crate_exploded(center_origin):
	var pkt_data = { "type": "crate_exploded", "position": { "x": center_origin.x, "y": center_origin.y, "z": center_origin.z } }
	_send(pkt_data)

func _send_killed(dead_player_id, killer_id, death_origin):
	var pkt_data = { "type": "killed", "player_id": dead_player_id, "killer_id": killer_id, "position": { "x": death_origin.x, "y": death_origin.y, "z": death_origin.z } }
	var packet = JSON.print(pkt_data).to_utf8()
	_client.get_peer(1).put_packet(packet)

func _send(dict):
	var packet = JSON.print(dict).to_utf8()
	_client.get_peer(1).put_packet(packet)
