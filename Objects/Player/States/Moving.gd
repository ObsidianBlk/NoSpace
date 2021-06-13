extends "res://Objects/Player/States/state.gd"


func _ready():
	pass # Replace with function body.

func enter() -> void:
	print("In Moving")
	pass

func resume() -> void:
	paused = false

func exit() -> void:
	pass

func pause() -> void:
	paused = true

func handle_input(_event) -> void:
	.handle_input(_event)


func handle_physics(_delta : float) -> void:
	host.update_movement(_delta)
	if not host.is_moving():
		emit_signal("finished", "Idle")
