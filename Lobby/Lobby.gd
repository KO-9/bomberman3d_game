extends Node2D

onready var LobbyPlayer = preload("res://Lobby/LobbyPlayer.tscn")
onready var LobbyCodeBox = $"LobbyCodeBpx"
onready var playerContainer = $"VBoxContainer/HBoxContainer/VBoxContainer"
onready var scoreContainer = $"VBoxContainer/HBoxContainer/VBoxContainer2"

var players = []
var code = "CODE"

var state = "pre_game"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	LobbyCodeBox.text = code
	if state == "game_ended":
		$"VBoxContainer/HBoxContainer/VBoxContainer2/Score Label".visible = true
	else:
		$"VBoxContainer/HBoxContainer/VBoxContainer2/Score Label".visible = false
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
		if state == "game_ended":
			addPlayerScore(player)
			
func addPlayerScore(player):
	var newLobbyPlayer = LobbyPlayer.instance()
	newLobbyPlayer.align = newLobbyPlayer.ALIGN_RIGHT
	newLobbyPlayer.username = String(player.kills)+"/"+String(player.deaths)
	newLobbyPlayer.player_id = player.id
	scoreContainer.add_child(newLobbyPlayer)
	
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
