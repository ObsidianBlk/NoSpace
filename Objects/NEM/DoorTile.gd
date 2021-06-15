tool
extends StaticBody2D
class_name DoorTile

signal door_opened(ridx, tidx)

enum FACING {UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3}

export (FACING) var facing = FACING.UP				setget _set_facing
export var ridx : int = -1
export var tidx : int = -1

var trigger_body = null

onready var colshape = $CollisionShape2D
onready var sprite = $Sprite
onready var actarea = $ActArea
onready var anim = $Anim


func _set_facing(f : int) -> void:
	facing = f
	if sprite:
		var a = deg2rad(90 * facing)
		var colpos = Vector2(0, 24).rotated(a)
		sprite.rotation = a
		colshape.rotation = a
		colshape.position = colpos
		actarea.position = colpos

func _enable_collision(e : bool = true) -> void:
	if e:
		collision_layer = 1
		colshape.disabled = false
	else:
		collision_layer = 0
		colshape.disabled = true

func _on_door_trigger():
	if collision_layer == 1:
		anim.play("open")
		emit_signal("door_opened", ridx, tidx)

func _on_body_entered(body):
	if trigger_body == null and body.has_signal("trigger"):
		trigger_body = body
		trigger_body.connect("trigger", self, "_on_door_trigger")

func _on_body_exited(body):
	if trigger_body == body:
		trigger_body.disconnect("trigger", self, "_on_door_trigger")
		if collision_layer == 0:
			anim.play("close")

func _on_anim_finished(anim_name):
	if anim_name == "close":
		anim.play("idle")
