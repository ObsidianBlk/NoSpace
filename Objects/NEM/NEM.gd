tool
extends Node2D


export (Array, NodePath) var target_paths = []			setget _set_target_paths


var targets = null
var tile = preload("res://Objects/NEM/PulseTile.tscn")


func _set_target_paths(tparr : Array) -> void:
	target_paths = tparr
	_update_target_list()


func _update_target_list():
	targets = []
	for tp in target_paths:
		var tnode = get_node(tp)
		if tnode:
			# TODO: Check if node is a proper node for a target and connect
			#  to them if they are.
			targets.append(tnode)


func _ready():
	_update_target_list()

