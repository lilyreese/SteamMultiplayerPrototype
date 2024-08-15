class_name Menu_Selection extends Control

signal join_game_pressed()
signal host_game_pressed(lobby_name:String)

@export var exit:Button
@export var host_game:Button
@export var join_game:Button
@export var lobby_name:LineEdit
@export var host_container:Container

func _ready() -> void:
	_set_up_signals()
	
func _set_up_signals() -> void:
	host_game.pressed.connect(_on_host_game_pressed)
	join_game.pressed.connect(_on_join_game_pressed)
	exit.pressed.connect(func():get_tree().quit())

# Callbacks

func _on_host_game_pressed() -> void:
	print('Host Game Pressed')
	host_game_pressed.emit(lobby_name.text)
	
func _on_join_game_pressed() -> void:
	print('Join Game Pressed')
	join_game_pressed.emit()
