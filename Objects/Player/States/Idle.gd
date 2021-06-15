extends "res://Objects/Player/States/state.gd"


func _ready():
	pass # Replace with function body.

func enter() -> void:
	host.move(Player.DIRECTION.UP, 0.0)
	host.move(Player.DIRECTION.DOWN, 0.0)
	host.move(Player.DIRECTION.LEFT, 0.0)
	host.move(Player.DIRECTION.RIGHT, 0.0)

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
	if host.is_moving():
		emit_signal("finished", "Moving")
	host.update_movement(_delta)
