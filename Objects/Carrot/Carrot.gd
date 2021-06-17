extends Node2D

signal carrot_picked_up(pos)

func _on_body_entered(body):
	if body.has_method("get_carrot"):
		body.get_carrot()
		emit_signal("carrot_picked_up", position)
		var parent = get_parent()
		if parent:
			parent.remove_child(self)
		queue_free()
