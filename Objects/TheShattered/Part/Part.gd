extends Node2D

signal part_picked_up

const ARC_RAD_START = 44.0
const ARC_RAD_END = 56.0

const ARC_THICK_START = 3.0
const ARC_THICK_END = 1.0

export (TheShattered.PARTS) var id = TheShattered.PARTS.BODY	setget _set_id
export var target_path : NodePath = ""							setget _set_target_path
export (float, 0.0, 1.0) var alpha = 1.0						setget _set_alpha

var alive = true
var target = null

var arc_rad = ARC_RAD_START
var arc_thick = ARC_THICK_START

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

func _set_target_path(p : NodePath) -> void:
	target_path = p
	if p == "":
		target = null
	else:
		var _t = get_node(p)
		if _t:
			target = _t

func _set_alpha(a : float) -> void:
	alpha = a
	if sprite:
		var mat = sprite.get_material()
		mat.set_shader_param("alpha", alpha)

func _ready() -> void:
	_set_id(id)
	_set_target_path(target_path)
	_set_alpha(alpha)

func _process(delta):
	arc_rad += delta * 10
	if arc_rad > ARC_RAD_END:
		arc_rad -= ARC_RAD_START
	
	arc_thick -= delta
	if arc_thick < ARC_THICK_END:
		arc_thick = ARC_THICK_START - (ARC_THICK_END - arc_thick)
		
	update()

func _draw():
	if target == null:
		return
	
	var arc_deg = deg2rad(25)
	var tpos = target.position + Vector2(0, -32)
	var dist = position.distance_to(tpos)
	if dist > 64.0:
		var angle = position.angle_to_point(tpos)
		var from = Vector2(-64, 0).rotated(angle)
		var to = Vector2(-(dist - 64), 0).rotated(angle)
		#print("Drawing From: ", position, " | To: ", to, " | Target Pos: ", target.position)
		draw_line(from, to, Color(255, 255, 255), 2, true)
		draw_arc(tpos - position, arc_rad, angle - arc_deg, angle + arc_deg, 16, Color(255, 255, 255), arc_thick, true)

func is_alive() -> bool:
	return alive

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
	if alive and body.has_method("pickup_part"):
		body.pickup_part(id)
		alive = false
		emit_signal("part_picked_up")

