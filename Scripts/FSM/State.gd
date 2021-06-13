extends Node
class_name State


signal finished(next_state)

var host = null
var paused = false

func init(_host : Node) -> void:
	if not host:
		host = _host

func enter() -> void:
	pass

func resume() -> void:
	paused = false

func exit() -> void:
	pass

func pause() -> void:
	paused = true

func handle_input(_event) -> void:
	pass

func handle_update(_delta : float) -> void:
	pass

func handle_physics(_delta : float) -> void:
	pass
