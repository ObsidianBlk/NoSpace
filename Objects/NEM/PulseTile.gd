tool
extends Sprite

export var color : Color = Color(1.0, 1.0, 1.0, 1.0)	setget _set_color
export (float, 0.0, 1.0) var base_intensity = 0.25		setget _set_base_intensity
export (float, 0.01, 0.5) var rim_thickness = 0.02		setget _set_rim_thickness
export (float, 0.0, 1.0) var rim_fade = 0.5				setget _set_rim_fade


func _set_color(c : Color) -> void:
	color = c
	if sparams:
		sparams.set_shader_param("color", color)

func _set_base_intensity(i : float) -> void:
	base_intensity = i
	if sparams:
		sparams.set_shader_param("base_intensity", base_intensity)

func _set_rim_thickness(t : float) -> void:
	rim_thickness = t
	if sparams:
		sparams.set_shader_param("rim_thickness", rim_thickness)

func _set_rim_fade(f : float) -> void:
	rim_fade = f
	if sparams:
		sparams.set_shader_param("rim_fade", rim_fade)


onready var sparams = get_material()

func _ready() -> void:
	_set_color(color)
	_set_base_intensity(base_intensity)
	_set_rim_thickness(rim_thickness)
	_set_rim_fade(rim_fade)
