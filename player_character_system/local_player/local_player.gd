class_name Local_Player extends CharacterBody3D

@export_range(3.0, 12.0, 0.1) var max_speed:float = 6.0
@export_range(1.0, 50.0, 0.1) var steering_factor:float = 20.0

@export var player_skin:Player_Skin

func _physics_process(delta:float) -> void:
	var input_vector:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction:Vector3 = Vector3(input_vector.x, 0, input_vector.y)
	
	var target_ground_velocity:Vector3 = max_speed * direction
	var steering_vector:Vector3 = target_ground_velocity - velocity
	
	steering_vector.y = 0
	
	var steering_amount: float = min(steering_factor * delta, 1.0)
	
	velocity += steering_vector * steering_amount
	
	move_and_slide()
	
	if not direction.is_zero_approx():
		player_skin.run()
	else:
		player_skin.idle()
	
	if position.is_equal_approx(position + direction):
		return
		
	player_skin.look_at(position + direction)
