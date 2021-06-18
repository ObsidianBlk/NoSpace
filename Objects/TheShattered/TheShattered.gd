extends Node2D


var player = null

onready var base_node = $Base
onready var body_node = $Body
onready var reye_node = $RightEye
onready var leye_node = $LeftEye


func _ready() -> void:
	body_node.visible = false
	reye_node.visible = false
	leye_node.visible = false


func _on_trigger() -> void:
	return

func _on_body_entered(body : Node2D) -> void:
	if player == null and body.has_signal("trigger"):
		player = body
		player.connect("trigger", self, "_on_trigger")

func _on_body_exited(body : Node2D) -> void:
	if body == player:
		player.disconnect("trigger", self, "_on_trigger")
		player = null
