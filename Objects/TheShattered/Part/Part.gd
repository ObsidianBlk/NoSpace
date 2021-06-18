extends Node2D

export (TheShattered.PARTS) var id = TheShattered.PARTS.BODY	setget _set_id
export (float, 0.0, 1.0) var alpha = 1.0						setget _set_alpha

onready var sprite = $Sprite

func _set_id(pid : int) -> void:
	if pid == TheShattered.PARTS.BODY or pid == TheShattered.PARTS.LEYE or pid == TheShattered.PARTS.REYE:
		id = pid
		if sprite:
			match(id):
				TheShattered.PARTS.BODY:
					sprite.region_rect.position = Vector2(32, 0)
				TheShattered.PARTS.LEYE:
					sprite.region_rect.position = Vector2(96, 0)
				TheShattered.PARTS.REYE:
					sprite.region_rect.position = Vector2(64, 0)

func _set_alpha(a : float) -> void:
	alpha = a
	if sprite:
		var mat = sprite.get_material()
		mat.get_shader_param("alpha", alpha)

func _ready() -> void:
	_set_id(id)

func get_corners() -> Array:
	var hw = sprite.region_rect.size.x * 0.5
	var hh = sprite.region_rect.size.y * 0.5
	return [
		position + Vector2(-(hw + 1), -(hh + 1)),
		position + Vector2(hw + 1, -(hh + 1)),
		position + Vector2(hw + 1, hh + 1),
		position + Vector2(-(hw + 1), hh + 1)
	]

func kill() -> void:
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	queue_free()

func _on_body_entered(body):
	if body.has_method("pickup_part"):
		body.pickup_part(id)
		kill()

