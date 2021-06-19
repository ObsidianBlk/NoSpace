extends "res://Scripts/FSM/State.gd"

var consume_locked = false

func _readjust(minv : float, maxv : float, v : float) -> float:
	 return clamp((v - minv) / (maxv - minv), 0.0, 1.0)


func handle_input(_event) -> void:	
	var amount = 1.0
	if _event is InputEventJoypadMotion:
		amount = _readjust(0.4, 0.8, abs(_event.axis_value))
		
		if _event.axis == 0:
			if _event.axis_value < 0:
				host.move(Player.DIRECTION.RIGHT, 0.0)
				host.move(Player.DIRECTION.LEFT, amount)
			else:
				host.move(Player.DIRECTION.LEFT, 0.0)
				host.move(Player.DIRECTION.RIGHT, amount)
		else:
			if _event.axis_value < 0:
				host.move(Player.DIRECTION.DOWN, 0.0)
				host.move(Player.DIRECTION.UP, amount)
			else:
				host.move(Player.DIRECTION.UP, 0.0)
				host.move(Player.DIRECTION.DOWN, amount)
			
		#print("Axis: ", _event.axis, " | Value: ", _event.axis_value, " | Is Action: ", _event.is_action_type())
		
	else:
		if _event.is_action_pressed("consume") and not consume_locked:
			host.consume_carrot()
			consume_locked = true
		elif _event.is_action_released("consume"):
			consume_locked = false
		
		if _event.is_action_pressed("move_up"):
			host.move(Player.DIRECTION.UP, amount)
		elif _event.is_action_pressed("move_down"):
			host.move(Player.DIRECTION.DOWN, amount)
		elif _event.is_action_pressed("move_left"):
			host.move(Player.DIRECTION.LEFT, amount)
		elif _event.is_action_pressed("move_right"):
			host.move(Player.DIRECTION.RIGHT, amount)
		
		if _event.is_action_released("move_up"):
			host.move(Player.DIRECTION.UP, 0.0)
		elif _event.is_action_released("move_down"):
			host.move(Player.DIRECTION.DOWN, 0.0)
		elif _event.is_action_released("move_left"):
			host.move(Player.DIRECTION.LEFT, 0.0)
		elif _event.is_action_released("move_right"):
			host.move(Player.DIRECTION.RIGHT, 0.0)
