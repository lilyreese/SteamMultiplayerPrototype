class_name Main_Menu extends Control

@export var menu_selection:Menu_Selection
@export var join_lobby:Join_Lobby
@export var player_steam_info:Player_Steam_Info
@export var title_demo:Label
@export var connecting_label:Label
@export var backgroundRight:TextureRect
@export var backgroundLeft:TextureRect

@export var lobby:Lobby

var original_background_position:Vector2
var original_title_position:Vector2
var original_connecting_position:Vector2

func _ready() -> void:
	original_background_position = backgroundRight.position
	original_title_position = title_demo.position
	original_connecting_position = connecting_label.position
	_set_up_signals()
	
func _set_up_signals() -> void:
	join_lobby.back_pressed.connect(_on_join_lobby_back_pressed)	
	join_lobby.trying_to_join_lobby.connect(_on_trying_to_join_lobby)
	
	menu_selection.join_game_pressed.connect(_on_menu_selection_join_game_pressed)
	menu_selection.host_game_pressed.connect(_on_menu_selection_host_game_pressed)
	
	MI.steam_player_info_updated.connect(_on_steam_player_info_updated)
	MI.steam_lobby_members_changed.connect(_on_steam_lobby_members_changed)
	MI.steam_lobby_joined.connect(_on_steam_lobby_joined)
	
	lobby.disconnect_button_pressed.connect(_on_lobby_disconnect_button_pressed)
	
# Callbacks
func _on_join_lobby_back_pressed() -> void:
	join_lobby.hide()
	menu_selection.show()
	title_demo.show()
	
	var tween:Tween = create_tween().set_parallel()
	tween.set_ease(tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(backgroundRight, 'position', original_background_position, 0.5)
	tween.tween_property(title_demo, 'position', original_title_position, 0.5)
	
func _on_menu_selection_join_game_pressed() -> void:
	menu_selection.hide()
	
	backgroundLeft.hide()
	backgroundRight.show()
	
	join_lobby.show()
	join_lobby.enter_menu()
	
	var tween:Tween = create_tween().set_parallel()
	tween.set_ease(tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(backgroundRight, 'position', original_background_position + Vector2(-450, 0), 0.5)
	tween.tween_property(title_demo, 'position', original_title_position + Vector2(-2000, 0), 0.5)
	
func _on_menu_selection_host_game_pressed(lobby_name:String) -> void:
	menu_selection.hide()
	
	backgroundRight.hide()
	backgroundLeft.show()
	
	
	var tween:Tween = create_tween().set_parallel()
	tween.set_ease(tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(backgroundLeft, 'position', original_background_position + Vector2(+766, 0), 0.5)
	tween.tween_property(title_demo, 'position', original_title_position + Vector2(+2000, 0), 0.5)	
	tween.tween_property(connecting_label, 'position', Vector2(386.5, 471.5), 0.5)
	
	await(get_tree().create_timer(1).timeout)
	
	if !MI.steam_lobby_created.is_connected(_on_steam_lobby_created):
		MI.steam_lobby_created.connect(_on_steam_lobby_created)
	MI.create_lobby_as_host(lobby_name)

func _on_steam_player_info_updated(_name:String, avatar:ImageTexture) -> void:
	player_steam_info.update_player_info(_name, avatar)
	
func _on_steam_lobby_created(lobby_name:String, lobby_id:int) -> void:
	var tween:Tween = create_tween().set_parallel()
	tween.set_ease(tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(backgroundLeft, 'position', original_background_position, 0.5)
	#tween.tween_property(title_demo, 'position', original_title_position + Vector2(+2000, 0), 0.5)	
	tween.tween_property(connecting_label, 'position', original_connecting_position, 0.5)
	
	lobby.enter_menu(lobby_name, lobby_id)
	lobby.show()
	
func _on_steam_lobby_members_changed(lobby_members:Dictionary) -> void:
	lobby.update_lobby_members(lobby_members)

func _on_trying_to_join_lobby(lobby_id:int) -> void:
	if !MI.steam_lobby_joined.is_connected(_on_steam_lobby_joined):
		MI.steam_lobby_joined.connect(_on_steam_lobby_joined)
		
	MI.connect_to_lobby_as_client(lobby_id)
	
func _on_steam_lobby_joined(lobby_name:String, lobby_id:int) -> void:
	menu_selection.hide()
	join_lobby.hide()
	print("A")
	var tween:Tween = create_tween().set_parallel()
	tween.set_ease(tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(backgroundLeft, 'position', original_background_position, 0.5)
	#tween.tween_property(title_demo, 'position', original_title_position + Vector2(+2000, 0), 0.5)	
	tween.tween_property(connecting_label, 'position', original_connecting_position, 0.5)
	
	lobby.enter_menu(lobby_name, lobby_id)
	lobby.show()

func _on_lobby_disconnect_button_pressed() -> void:
	lobby.hide()
	menu_selection.show()
	title_demo.show()
	
	MI.disconnect_from_lobby()
	
	var tween:Tween = create_tween().set_parallel()
	tween.set_ease(tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(backgroundLeft, 'position', original_background_position, 0.5)
	tween.tween_property(title_demo, 'position', original_title_position, 0.5)
	
