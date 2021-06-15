tool
extends StaticBody2D
class_name DoorTile

signal door_opened(dx, dy, ridx, didx)

enum FACING {UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3}

export var color : Color = Color(0.7, 0.7, 0.7, 1.0)	setget _set_color
export (float, 0.0, 1.0) var alpha = 1.0				setget _set_alpha
export (FACING) var facing = FACING.UP					setget _set_facing
export var ridx : int = -1
export var didx : int = -1

var trigger_body = null

onready var colshape = $CollisionShape2D
onready var sprite = $Sprite
onready var sparams = $Sprite.get_material()
onready var actarea = $ActArea
onready var anim = $Anim


func _set_color(c : Color) -> void:
	color = c
	if sparams:
		sparams.set_shader_param("replace_col_1", color)


func _set_alpha(a : float) -> void:
	alpha = a
	if sparams:
		sparams.set_shader_param("alpha", alpha)

func _set_facing(f : int) -> void:
	facing = f
	_update_facing()

func _ready() -> void:
	_update_facing()
	_set_color(color)
	_set_alpha(alpha)

func _update_facing() -> void:
	if sprite:
		var a = deg2rad(90 * facing)
		sprite.rotation = a
		colshape.rotation = a
		
		match(facing):
			FACING.UP:
				sprite.position = Vector2(16, -16)
				colshape.position = Vector2(16, 8)
				actarea.position = Vector2(16, 8)
			FACING.RIGHT:
				sprite.position = Vector2(16, -16)
				colshape.position = Vector2(-8, -16)
				actarea.position = Vector2(-8, -16)
			FACING.DOWN:
				sprite.position = Vector2(16, 16)
				colshape.position = Vector2(16, -8)
				actarea.position = Vector2(16, -8)
			FACING.LEFT:
				sprite.position = Vector2(-16, -16)
				colshape.position = Vector2(8, -16)
				actarea.position = Vector2(8, -16)

func _enable_collision(e : bool = true) -> void:
	if e:
		collision_layer = 1
		colshape.disabled = false
	else:
		collision_layer = 0
		colshape.disabled = true


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



func _on_door_trigger():
	if collision_layer == 1:
		anim.play("open")
		emit_signal("door_opened", position.x, position.y, ridx, didx)

func _on_body_entered(body):
	if trigger_body == null and body.has_signal("trigger"):
		trigger_body = body
		trigger_body.connect("trigger", self, "_on_door_trigger")

func _on_body_exited(body):
	if trigger_body == body:
		trigger_body.disconnect("trigger", self, "_on_door_trigger")
		trigger_body = null
		if collision_layer == 0:
			anim.play("close")

func _on_anim_finished(anim_name):
	if anim_name == "close":
		anim.play("idle")


func _on_tree_entered():
	_update_facing()
