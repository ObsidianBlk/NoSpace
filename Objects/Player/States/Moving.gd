extends "res://Objects/Player/States/state.gd"


var anim = null

func _ready():
	pass # Replace with function body.

func enter() -> void:
	anim = host.get_node("Anim")

func resume() -> void:
	paused = false

func exit() -> void:
	pass

func pause() -> void:
	paused = true

func handle_input(_event) -> void:
	.handle_input(_event)
	
	if _event.is_action_pressed("trigger") and host.get_speed() < 50.0:
		host.trigger()
	elif _event.is_action_released("trigger"):
		host.trigger(false)
	
	if _event.is_action_pressed("charge"):
		host.charge_tp()
	elif _event.is_action_released("charge") and host.is_charging():
		host.charge_release()


func handle_physics(_delta : float) -> void:
	host.update_movement(_delta)
	if not host.is_moving():
		emit_signal("finished", "Idle")
	_update_animation()

func _update_animation():
	if not anim:
		return
		
	var facing = host.get_facing()
	match(facing):
		Player.DIRECTION.UP:
			anim.play("run_up")
		Player.DIRECTION.DOWN:
			anim.play("run_down")
		Player.DIRECTION.LEFT:
			host.flip_sprite()
			anim.play("run_side")
		Player.DIRECTION.RIGHT:
			host.flip_sprite(false)
			anim.play("run_side")
