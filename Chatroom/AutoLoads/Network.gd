extends Node

@onready var users : ItemList = $Background/AppContents/Rows/Row1/Sidebar
var user_name : String = "Default"
var user_color : String = "Red"

var user_list : Dictionary

#If we successful connect to the server, go into the chatroom
func connected():
	print("connected to server")
	var compile_data : Array = [str(get_tree().get_network_unique_id()),user_name]
	rpc_id(1,"update_user",compile_data)
	enter_chat_room()
	
#Only run on the server
func update_user(user):
	user_list[str(user[0])] = user[1]
	emit_signal("update_user_list")
	rpc("client_update",user_list)
	pass
	
func client_update(update_user_list):
	user_list = update_user_list
	emit_signal("update_user_list")

#Server just closed
func server_disconnected():
	print("server_disconnected")
	OS.alert('Server closed', 'Status')

#Called when a user enters the chat, clear the list and repopulate withupdated one
func update_user_list():
	users.clear()
	for i in Network.user_list:
		var data = Network.user_list[i]
		users.add_item(Network.user_list[i])
			
func user_left(ID):
	print(ID)
	Network.user_list.erase(str(ID)) # remove  from user_list
	update_user_list()
	

func create_server():
	#changed from godot 3.x, used to be NetworkedMultiplayerEnet
	var server : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var gateway := SceneMultiplayer.new()
	
	server.create_server(9999, 32)
	get_tree().set_multiplayer(gateway, self.get_path())
	multiplayer.set_multiplayer_peer(server)

func enter_chat_room():
	#Connect to our custom signal in Network
	Network.connect("update_user_list",update_user_list)
	get_tree().connect("network_peer_disconnected", user_left)
	
	# if we're server just update list
	if(get_tree().get_network_unique_id() == 1): 
		update_user_list()
