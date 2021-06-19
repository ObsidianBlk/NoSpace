extends "res://Objects/Player/States/state.gd"

var reset = true

func enter() -> void:
	host.move(Player.DIRECTION.UP, 0.0)
	host.move(Player.DIRECTION.DOWN, 0.0)
	host.move(Player.DIRECTION.LEFT, 0.0)
	host.move(Player.DIRECTION.RIGHT, 0.0)
	reset = true

func resume() -> void:
	paused = false

func exit() -> void:
	pass

func pause() -> void:
	paused = true

func handle_input(_event) -> void:
	.handle_input(_event)
	
	if _event.is_action_pressed("trigger"):
		host.trigger()
	elif _event.is_action_released("trigger"):
		host.trigger(false)

	if host.is_moving():
		emit_signal("finished", "Moving")


func handle_physics(_delta : float) -> void:
	if host.is_charging():
		host.charge_cancel()
	if host.is_moving():
		emit_signal("finished", "Moving")
	host.update_movement(_delta)
	if reset:
		reset = false
		_update_animation()

func _update_animation():
	var facing = host.get_facing()
	match(facing):
		Player.DIRECTION.UP:
			host.play_animation("idle_up")
		Player.DIRECTION.DOWN:
			host.play_animation("idle_down")
		Player.DIRECTION.LEFT:
			host.flip_sprite()
			host.play_animation("idle_side")
		Player.DIRECTION.RIGHT:
			host.flip_sprite(false)
			host.play_animation("idle_side")


