extends StaticBody2D


func kill() -> void:
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()

