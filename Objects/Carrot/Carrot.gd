extends Node2D

signal carrot_picked_up(ridx, cidx)

export var ridx : int = -1
export var idx : int = -1

var picked_up = false

func kill() -> void:
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()

func _on_body_entered(body):
	if not picked_up and body.has_method("pickup_carrot"):
		picked_up = true
		body.pickup_carrot()
		emit_signal("carrot_picked_up", ridx, idx)
		hide()
