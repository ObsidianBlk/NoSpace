extends Node2D
class_name TheShattered

signal spawn_part(pid)

enum PARTS {BODY=100, LEYE=200, REYE=300}

export (float, 0.0, 1.0) var alpha = 1.0			setget _set_alpha
export var ridx : int = -1

var player = null

onready var base_node = $Base
onready var body_node = $Body
onready var reye_node = $RightEye
onready var leye_node = $LeftEye

func _set_alpha(a : float) -> void:
	alpha = a
	if base_node:
		_set_node_material_alpha(base_node)
	if body_node:
		_set_node_material_alpha(body_node)
	if reye_node:
		_set_node_material_alpha(reye_node)
	if leye_node:
		_set_node_material_alpha(leye_node)

func _ready() -> void:
	body_node.visible = false
	reye_node.visible = false
	leye_node.visible = false
	_set_alpha(alpha)

func _set_node_material_alpha(node : Sprite) -> void:
	var mat = node.get_material()
	mat.set_shader_param("alpha", alpha)

func _emit_spawn_part() -> void:
	var avail = []
	if not body_node.visible:
		avail.append(PARTS.BODY)
	if not reye_node.visisble:
		avail.append(PARTS.REYE)
	if not leye_node.visible:
		avail.append(PARTS.LEYE)
	if avail.size() > 0:
		var idx = floor(rand_range(0, avail.size()))
		emit_signal("spawn_part", avail[idx])

func get_corners() -> Array:
	var view_dist = 16
	return [
		position - Vector2(view_dist, 0),
		position + Vector2(view_dist, 0),
		position - Vector2(0, view_dist),
		position + Vector2(0, view_dist)
	]

func _on_trigger() -> void:
	var new_part = false
	if player.has_method("take_part"):
		var part_id = player.take_part()
		match(part_id):
			PARTS.BODY:
				if not body_node.visible:
					body_node.visible = true
					new_part = true
			PARTS.REYE:
				if not reye_node.visible:
					reye_node.visible = true
					new_part = true
			PARTS.LEYE:
				if not leye_node.visible:
					leye_node.visible = true
					new_part = true
	if new_part and not (body_node.visible and reye_node.visible and leye_node.visible):
		_emit_spawn_part()

func _on_body_entered(body : Node2D) -> void:
	if player == null and body.has_signal("trigger"):
		player = body
		player.connect("trigger", self, "_on_trigger")

func _on_body_exited(body : Node2D) -> void:
	if body == player:
		player.disconnect("trigger", self, "_on_trigger")
		player = null
