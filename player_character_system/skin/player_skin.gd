class_name Player_Skin extends Node3D

@export var animation_player:AnimationPlayer

func idle() -> void:
	animation_player.play('idle')
	
func run() -> void:
	animation_player.play('sprint')
