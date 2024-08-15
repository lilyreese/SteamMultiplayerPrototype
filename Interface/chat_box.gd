class_name Chat_Box extends ColorRect

@export var chat_text:Label

@export var text_insert:LineEdit
@export var send:Button

@export var scroll:ScrollContainer

func _ready():
	_set_up_signals()
	
func _set_up_signals() -> void:
	MI.lobby_chat_message_received.connect(_on_lobby_chat_message_received)
	send.pressed.connect(_on_send_pressed)

func _on_send_pressed() -> void:
	if text_insert.text == '':
		return
		
	MI.send_chat_message_to_lobby(text_insert.text)
	
func add_message_to_chat(sender_name:String, message:String) -> void:
	chat_text.text += '\n %s: %s' % [sender_name, message]
	scroll.set_deferred('scroll_vertical', scroll.scroll_vertical + 500)

func _on_lobby_chat_message_received(user_name:String, message:String) -> void:
	add_message_to_chat(user_name, message)
