class_name Player_Steam_Info extends ColorRect

@export var player_avatar:TextureRect
@export var player_name_label:Label

var steam_id:int = 0
var is_empty:bool = true

func update_player_info(_name:String, avatar:ImageTexture) -> void:
	player_avatar.texture = avatar
	player_name_label.text = _name
	
func clear_info() -> void:
	player_avatar.texture = null
	player_name_label.text = ''
	steam_id = 0
	is_empty = true
