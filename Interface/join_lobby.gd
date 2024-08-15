class_name Join_Lobby extends Control

signal back_pressed()
signal trying_to_join_lobby(lobby_id:int)

@export var lobby_list_container:VBoxContainer

@export var name_filter:LineEdit
@export var refresh:Button
@export var back:Button


func _ready() -> void:
	_set_up_signals()
	
func enter_menu() -> void:
	_request_updated_lobby_list()
	
func _set_up_signals() -> void:
	refresh.pressed.connect(_on_refresh_pressed)	
	back.pressed.connect(_on_back_pressed)

func _fill_lobby_list_container(lobbies:Dictionary) -> void:
	_clear_lobby_list_container()
	for lobby in lobbies:
		var lobby_button: Button = Button.new()
		lobby_button.set_text("%s - [%s/%s]" % [lobbies[lobby].name, str(lobbies[lobby].num_players), str(lobbies[lobby].max_players)])
		lobby_button.size_flags_horizontal = Control.SIZE_EXPAND
		lobby_button.set_name("lobby_%s" % lobby)
		lobby_button.pressed.connect(_on_lobby_button_join_pressed.bind(lobby))
		
		lobby_list_container.add_child(lobby_button)
	
func _clear_lobby_list_container() -> void:
	for child in lobby_list_container.get_children():
		child.queue_free()
	
func _request_updated_lobby_list(_name_filter:String = '') -> void:
	if !MI.lobby_list_updated.is_connected(_on_lobby_list_updated):
		MI.lobby_list_updated.connect(_on_lobby_list_updated)
	MI.request_updated_lobby_list(_name_filter)
	
# Callbacks
func _on_refresh_pressed() -> void:
	_request_updated_lobby_list(name_filter.text)
	
		
func _on_lobby_list_updated(lobbies:Dictionary) -> void:
	_fill_lobby_list_container(lobbies)
	if MI.lobby_list_updated.is_connected(_on_lobby_list_updated):
		MI.lobby_list_updated.disconnect(_on_lobby_list_updated)
	
func _on_back_pressed() -> void:
	_clear_lobby_list_container()
	back_pressed.emit()
	
func _on_lobby_button_join_pressed(lobby_id:int) -> void:
	trying_to_join_lobby.emit(lobby_id)
