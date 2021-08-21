extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var username = $"Name"
onready var LobbyCode = $"LobbyCode"

var menuAction = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CreateLobby_pressed():
	WebSocket.loginPacket = { "type": "login", "username": username.text, "action": "create_lobby" }
	if WebSocket.WebSocketState == WebSocket.WebSocketStates.DISCONNECTED:
		WebSocket.ws_connect()
	else:
		WebSocket.login()


func _on_JoinLobby_pressed():
	WebSocket.loginPacket = { "type": "login", "username": username.text, "action": "join_lobby", "code": LobbyCode.text }
	if WebSocket.WebSocketState == WebSocket.WebSocketStates.DISCONNECTED:
		WebSocket.ws_connect()
	else:
		WebSocket.login()


func _on_Name_focus_entered():
	if username.text == "Name":
		username.text = ""


func _on_Name_focus_exited():
	if username.text == "":
		username.text = "Name"


func _on_LobbyCode_focus_entered():
	if LobbyCode.text == "Lobby code":
		LobbyCode.text = ""


func _on_LobbyCode_focus_exited():
	if LobbyCode.text == "":
		LobbyCode.text = "Lobby code"
