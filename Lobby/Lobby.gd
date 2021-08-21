extends Node2D

onready var LobbyPlayer = preload("res://Lobby/LobbyPlayer.tscn")
onready var LobbyCodeBox = $"LobbyCodeBpx"
onready var playerContainer = $"VBoxContainer/HBoxContainer/VBoxContainer"
onready var scoreContainer = $"VBoxContainer/HBoxContainer/VBoxContainer2"

var players = []
var code = "CODE"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	LobbyCodeBox.text = code
	updateState(players)

func updateState(newPlayers):
	var vbox_kids = playerContainer.get_children()
	for vbox_kid in vbox_kids:
		if vbox_kid.name != "Name Label":
			vbox_kid.queue_free()
	players = newPlayers
	WebSocket.room_players = players
	for player in players:
		addPlayer(player.username, player.id)

func addPlayer(username, player_id):
	var newLobbyPlayer = LobbyPlayer.instance()
	newLobbyPlayer.username = username
	newLobbyPlayer.player_id = player_id
	playerContainer.add_child(newLobbyPlayer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	WebSocket.startLobby()
