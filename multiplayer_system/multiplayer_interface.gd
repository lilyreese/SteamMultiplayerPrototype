class_name Multiplayer_Interface extends Node

#Steam Callbacks
signal steam_lobby_created(lobby_name:String, lobby_id:int)
signal lobby_list_updated(lobby_list:Dictionary)
signal steam_player_info_updated(name:String, avatar:ImageTexture)
signal steam_lobby_members_changed(lobby_members:Dictionary)

signal steam_lobby_joined(lobby_name:String, lobby_id:int)
signal lobby_chat_message_received(user_name:String, message:String)

var steam_interface:Steam_Interface = Steam_Interface.new()

func _ready():
	_set_up_signals()
	steam_interface.initialize_steam_connection()
	
func _set_up_signals() -> void:
	steam_interface.player_info_updated.connect(func(_name, _avatar): steam_player_info_updated.emit(_name, _avatar))
	steam_interface.steam_lobby_members_changed.connect(func(lobby_members): steam_lobby_members_changed.emit(lobby_members))
	steam_interface.steam_lobby_joined.connect(func(_name, _id): steam_lobby_joined.emit(_name,_id))
	steam_interface.lobby_chat_message_received.connect(func(user_name, message): lobby_chat_message_received.emit(user_name, message))

#region Lobby
func create_lobby_as_host(lobby_name:String) -> void:
	if !steam_interface.steam_lobby_created.is_connected(_on_steam_lobby_created):
		steam_interface.steam_lobby_created.connect(_on_steam_lobby_created)
	steam_interface.create_steam_lobby_as_host(lobby_name)
	
func connect_to_lobby_as_client(lobby_id:int) -> void:
	steam_interface.connect_steam_lobby_as_client(lobby_id)

func request_updated_lobby_list(name_filter:String = '') -> void:
	if !steam_interface.steam_lobby_list_returned.is_connected(_on_steam_lobby_list_returned):
		steam_interface.steam_lobby_list_returned.connect(_on_steam_lobby_list_returned)

	steam_interface.request_lobby_list(name_filter)
	
func disconnect_from_lobby() -> void:
	steam_interface.disconnect_from_steam_lobby()
	
func send_chat_message_to_lobby(message:String) -> void:
	steam_interface.send_chat_message_to_lobby(message)
	
func _on_steam_lobby_list_returned(lobbies:Dictionary) -> void:
	lobby_list_updated.emit(lobbies)
	if steam_interface.steam_lobby_list_returned.is_connected(_on_steam_lobby_list_returned):
		steam_interface.steam_lobby_list_returned.disconnect(_on_steam_lobby_list_returned)

func _on_steam_lobby_created(lobby_name:String, lobby_id:int) -> void:
	steam_lobby_created.emit(lobby_name, lobby_id)
	
#endregion
