class_name Lobby extends Control

signal disconnect_button_pressed()

@export var player_steam_info_container:Container
@export var lobby_name_label:Label
@export var disconnect_button:Button

var player_steam_info_array:Array[Player_Steam_Info] = []

func _ready():
	_set_up_signals()
	
	for child in player_steam_info_container.get_children():
		player_steam_info_array.append(child)

func _set_up_signals() -> void:
	disconnect_button.pressed.connect(func():disconnect_button_pressed.emit())

func enter_menu(lobby_name:String, lobby_id:int):
	lobby_name_label.text = lobby_name
	
func update_lobby_members(lobby_members:Dictionary) -> void:
	_clear_player_info()

	for member in lobby_members:
		if member == MI.steam_interface.steam_id:
			continue
		var already_in_room:Player_Steam_Info = _try_get_steam_id_player_steam_info(member)
		if already_in_room:
			already_in_room.player_name_label.text = lobby_members[member].name
			already_in_room.player_avatar.texture = lobby_members[member].avatar
			continue
			
		var empty_slot:Player_Steam_Info = _find_empty_player_steam_info()
		
		if !empty_slot:
			print('No empty slot.')
			return
			
		empty_slot.is_empty = false
		empty_slot.player_name_label.text = lobby_members[member].name
		empty_slot.player_avatar.texture = lobby_members[member].avatar
		empty_slot.steam_id = member
		
func _find_empty_player_steam_info() -> Player_Steam_Info:
	for player_info:Player_Steam_Info in player_steam_info_array:
		if player_info.is_empty:
			return player_info
			
	return null

func _try_get_steam_id_player_steam_info(steam_id:int) -> Player_Steam_Info:
	for member:Player_Steam_Info in player_steam_info_array:
		if member.steam_id == steam_id:
			return member
	return null

func _clear_player_info() -> void:
	for child:Player_Steam_Info in player_steam_info_container.get_children():
		child.clear_info()
