class_name Steam_Interface extends RefCounted

signal player_info_updated(name:String, avatar:ImageTexture)

signal steam_connection_initialized()
signal steam_lobby_created(lobby_name:String, lobby_id:int)
signal steam_lobby_joined(lobby_name:String, lobby_id:int)
signal steam_lobby_disconnected()

signal steam_lobby_list_returned(lobbies:Dictionary)
signal steam_lobby_members_changed(lobby_members:Dictionary)

signal lobby_chat_message_received(user:int, message:String)

const APP_ID:int = 480

# Steam Information
var steam_id:int = 0
var user_name:String = ''
var user_avatar:ImageTexture = null

# Lobby Information
var lobby_id:int = 0
var lobby_name:String = ''
var lobby_members:Dictionary = {}

# Peer Information
var steam_peer:SteamMultiplayerPeer = SteamMultiplayerPeer.new()


#region Initialization
func initialize_steam_connection() -> void:
	var ini_err:Dictionary = Steam.steamInitEx(false, APP_ID, true)

	if ini_err.status != Steam.STEAM_API_INIT_RESULT_OK:
		return	
		
	_set_up_steam_callbacks()
	
	steam_id = Steam.getSteamID()
	user_name = Steam.getPersonaName()
	
	
	Steam.getPlayerAvatar(2, steam_id)
	
	print('Succesfully initialized Steam Connection. ID %s, Username %s' % [steam_id, user_name])
	
func _set_up_steam_callbacks() -> void:
	if !Steam.avatar_loaded.is_connected(_on_avatar_loaded):
			Steam.avatar_loaded.connect(_on_avatar_loaded)
			
	if !Steam.lobby_chat_update.is_connected(_on_lobby_chat_update):
		Steam.lobby_chat_update.connect(_on_lobby_chat_update)
		
	if !Steam.lobby_message.is_connected(_on_lobby_message):
		Steam.lobby_message.connect(_on_lobby_message)
		
func create_steam_lobby_as_host(_lobby_name:String = 'Default') -> void:
	if !steam_peer.lobby_created.is_connected(_on_lobby_created):
		steam_peer.lobby_created.connect(_on_lobby_created)
	lobby_name = _lobby_name
	steam_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 4)
	
func connect_steam_lobby_as_client(_lobby_id:int) -> void:
	if !steam_peer.lobby_joined.is_connected(_on_lobby_joined) and !Steam.lobby_joined.is_connected(_on_lobby_joined):
		steam_peer.lobby_joined.connect(_on_lobby_joined)
		Steam.lobby_joined.connect(_on_lobby_joined)
		
	print('Trying to connect to lobby %s.' % _lobby_id)
	steam_peer.connect_lobby(_lobby_id)
#endregion

#region Lobby Interactions
func request_lobby_list(string_filter:String = ''):
	if string_filter != '':
		Steam.addRequestLobbyListStringFilter('name', string_filter, Steam.LOBBY_COMPARISON_EQUAL)
	
	if !Steam.lobby_match_list.is_connected(_on_lobby_match_list):
		Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.requestLobbyList()

func disconnect_from_steam_lobby() -> void:
	Steam.leaveLobby(lobby_id)
	steam_peer.close()
	
	lobby_id = 0
	
	for member in lobby_members:
		if member != steam_id:
			Steam.closeP2PSessionWithUser(member)
			
	lobby_members.clear()
	
	if steam_peer.lobby_joined.is_connected(_on_lobby_joined):
		steam_peer.lobby_joined.disconnect(_on_lobby_joined)
		
	if steam_peer.lobby_created.is_connected(_on_lobby_created):
		steam_peer.lobby_created.disconnect(_on_lobby_created)
		
	if Steam.lobby_joined.is_connected(_on_lobby_joined):
		Steam.lobby_joined.disconnect(_on_lobby_joined)
		
	steam_lobby_disconnected.emit()

func send_chat_message_to_lobby(message:String) -> void:
	if message.length() <= 0:
		return
	if lobby_id == 0:
		return
		
	var was_sent:bool = Steam.sendLobbyChatMsg(lobby_id, message)

	if !was_sent:
		print("Error sending Chat Message.")
		
	

func _update_lobby_members() -> void:
	if lobby_id == 0:
		return
	
	lobby_members.clear()
	
	var num_players_in_lobby:int = Steam.getNumLobbyMembers(lobby_id)
	
	for i in range(0, num_players_in_lobby):
		var lobby_member_steam_id:int = Steam.getLobbyMemberByIndex(lobby_id, i)
		var lobby_member_name:String = Steam.getFriendPersonaName(lobby_member_steam_id)
		
		lobby_members[lobby_member_steam_id] = {'name':lobby_member_name}
		lobby_members[lobby_member_steam_id].avatar = null
		
		Steam.getPlayerAvatar(2, lobby_member_steam_id)
		steam_lobby_members_changed.emit(lobby_members)
#endregion

#region Signal Callbacks
func _set_up_signals() -> void:
	pass
	
# Lobby
func _on_lobby_created(_connect: int, _lobby_id: int) -> void:
	if _connect != Steam.RESULT_OK:
		print('Failed to create Lobby. Error ID: %s', _connect)
		return
	
	lobby_id = _lobby_id
	Steam.setLobbyData(lobby_id, 'name', lobby_name)	
	
	_update_lobby_members()
	steam_lobby_created.emit(lobby_name, lobby_id)
	print('Succesfully created Steam Lobby. Lobby ID: %s, Lobby Name: %s' % [lobby_id, lobby_name])
	
func _on_lobby_joined(lobby: int, permissions: int, locked: bool, response: int) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print('Failed to connet to Lobby. Error ID: %s', response)
		return
		
	lobby_id = lobby
	lobby_name = Steam.getLobbyData(lobby_id, 'name')
	
	_update_lobby_members()
	steam_lobby_joined.emit(lobby_name, lobby_id)
	print('Succesfully connected to Steam Lobby. Lobby ID: %s, Lobby Name: %s' % [lobby_id, lobby_name])

func _on_avatar_loaded(avatar_id: int, size: int, data: Array) -> void:
	var avatar_image:Image = Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, data)
	
	var avatar_texture:ImageTexture = ImageTexture.create_from_image(avatar_image)
	
	if avatar_id == steam_id:
		user_avatar = avatar_texture
		player_info_updated.emit(user_name, user_avatar)
		print('Successfully loaded Player Avatar.')
		
	if !lobby_members.has(avatar_id):
		return
		
	lobby_members[avatar_id].avatar = avatar_texture
		
	steam_lobby_members_changed.emit(lobby_members)
	
	print('Successfully loaded image for Lobby Member %s.' % lobby_members[avatar_id].name)
	
func _on_lobby_match_list(lobbies:Array) -> void:
	var lobbies_dictionary:Dictionary = {}
	for lobby in lobbies:
		lobbies_dictionary[lobby] = {'name' = Steam.getLobbyData(lobby, 'name')}
		lobbies_dictionary[lobby]['num_players'] = Steam.getNumLobbyMembers(lobby)
		lobbies_dictionary[lobby]['max_players'] = Steam.getLobbyMemberLimit(lobby)
		
	steam_lobby_list_returned.emit(lobbies_dictionary)
	
	if Steam.lobby_match_list.is_connected(_on_lobby_match_list):
			Steam.lobby_match_list.disconnect(_on_lobby_match_list)
			
func _on_lobby_chat_update(_lobby_id: int, changed_id: int, making_change_id: int, chat_state: int) -> void:
	if lobby_id == 0:
		return
	if _lobby_id != lobby_id:
		return
		
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		_update_lobby_members()
		
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		_update_lobby_members()
		
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_DISCONNECTED:
		_update_lobby_members()
		
func _on_lobby_message(_lobby_id: int, user: int, message: String, chat_type: int):
	if _lobby_id != lobby_id:
		return
	var user_name:String = Steam.getFriendPersonaName(user)
	lobby_chat_message_received.emit(user_name, message)
	
#endregion
