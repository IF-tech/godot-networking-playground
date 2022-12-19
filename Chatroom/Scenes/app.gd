extends Control

#import refereces to other nodes

#Taskbar nodes
@onready var join_button = $Background/AppContents/Rows/ConnectionBar/Join
@onready var host_button = $Background/AppContents/Rows/ConnectionBar/Host
@onready var status = $Background/AppContents/Rows/ConnectionBar/Status
@onready var colors = $Background/AppContents/Rows/ConnectionBar/Color
@onready var ip_address = $Background/AppContents/Rows/ConnectionBar/IP
@onready var user_name = $Background/AppContents/Rows/ConnectionBar/Name

#Input/Output display nodes
@onready var message = $Background/AppContents/Rows/Row2/InputField/LineEdit
@onready var history = $Background/AppContents/Rows/Row1/OutputWindow/MarginContainer/OutputText
@onready var users = $Background/AppContents/Rows/Row1/Sidebar/ActiveUsers


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("ui_accept")):
		#Check it's not an empty space, if it isn't, then sendmessage
		if(message.text != "\n"):
			#Create the message and tell everyone else to add it to their history
			rpc("send_chat",create_message())
			history.text += create_message()
			message.text = ""
		else:
			message.text = ""

#when host button is pressed, create a server
func _on_host_pressed():
	print("host button pressed")
	create_server()

#when host button is pressed, join a server
func _on_join_pressed():
	join_server()
	print("join button pressed")
	print("ip address is " + ip_address.text)


func create_server():
	#hide buttons
	join_button.hide()
	host_button.hide()
	
	#changed from godot 3.x, used to be NetworkedMultiplayerEnet
	var server : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var gateway := SceneMultiplayer.new()
	
	#create server on specified port
	server.create_server(9999, 32)
	get_tree().set_multiplayer(gateway, self.get_path())
	multiplayer.set_multiplayer_peer(server)
	
	#update status
	status.text = "Status: Hosting Server"
	#unique network id for server is 0
	print(get_tree().get_multiplayer().get_unique_id())

#called when join button is pressed	
func join_server():
	#hide buttons
	join_button.hide()
	host_button.hide()
	
	#create client on the multiplayer network
	var client : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var gateway := SceneMultiplayer.new()	
	client.create_client(ip_address.text,9999)
	get_tree().set_multiplayer(gateway, self.get_path())
	multiplayer.set_multiplayer_peer(client)
	
	#update status
	status.text = "Status: Joined server"

#updates chat history on all clients
@rpc(any_peer)	
func send_chat(txt):
	history.text += txt
	history.text += ""

#create message using richtextlabel which allows us to format color
func create_message() -> String:
	return "[b][color=" + colors.text +"]" + user_name.text + ": "+"[/color][/b]" + message.text + "\n"
