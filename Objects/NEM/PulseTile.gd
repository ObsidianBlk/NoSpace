tool
extends StaticBody2D
class_name PulseTile

export var color : Color = Color(1.0, 1.0, 1.0, 1.0)	setget _set_color
export (float, 0.0, 1.0) var base_intensity = 0.25		setget _set_base_intensity
export (float, 0.0, 1.0) var overall_intensity = 1.0	setget _set_overall_intensity
export (float, 0.0, 1.0) var alpha = 1.0				setget _set_alpha
export (float, 0.01, 0.5) var rim_thickness = 0.02		setget _set_rim_thickness
export (float, 0.0, 1.0) var rim_fade = 0.5				setget _set_rim_fade
export var collision_enabled : bool = false				setget _set_collision_enabled

var ready = false

onready var sparams = $Sprite.get_material()
onready var colshape_node = $CollisionShape2D
onready var sprite = $Sprite

func _set_color(c : Color) -> void:
	color = c
	if sparams:
		sparams.set_shader_param("color", color)

func _set_base_intensity(i : float) -> void:
	base_intensity = i
	if sparams:
		sparams.set_shader_param("base_intensity", base_intensity)

func _set_overall_intensity(i : float) -> void:
	overall_intensity = i
	if sparams:
		sparams.set_shader_param("overall_intensity", overall_intensity)

func _set_alpha(a : float) -> void:
	alpha = a
	if sparams:
		sparams.set_shader_param("alpha", alpha)

func _set_rim_thickness(t : float) -> void:
	rim_thickness = t
	if sparams:
		sparams.set_shader_param("rim_thickness", rim_thickness)

func _set_rim_fade(f : float) -> void:
	rim_fade = f
	if sparams:
		sparams.set_shader_param("rim_fade", rim_fade)

func _set_collision_enabled(e : bool) -> void:
	collision_enabled = e
	if ready:
		if collision_enabled:
			collision_layer = 1
			colshape_node.disabled = false
		else:
			collision_layer = 0
			colshape_node.disabled = true

func _ready() -> void:
	ready = true
	_set_color(color)
	_set_base_intensity(base_intensity)
	_set_overall_intensity(overall_intensity)
	_set_alpha(alpha)
	_set_rim_thickness(rim_thickness)
	_set_rim_fade(rim_fade)
	_set_collision_enabled(collision_enabled)


func get_corners() -> Array:
	var corners = []
	if sprite and sprite.texture:
		var hw = (sprite.texture.get_width() * sprite.scale.x) * 0.5
		var hh = (sprite.texture.get_height() * sprite.scale.y) * 0.5
		
		corners = [
			Vector2((position.x - hw) - 1, (position.y - hh) - 1),
			Vector2((position.x + hw) + 1, (position.y - hh) - 1),
			Vector2((position.x + hw) + 1, (position.y + hh) + 1),
			Vector2((position.x - hw) - 1, (position.y + hh) + 1)
		]
	return corners
