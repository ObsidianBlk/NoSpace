extends Node2D


onready var NEM = $NEM
onready var player_node = $Container/Player
onready var camera_node = $Container/Camera
onready var container_node = $Container


func _ready():
	NEM.add_region(
		Color(0.25, 0.25, 1.0), Color(0.25, 0.75, 1.0),
		[
			Rect2(15,15,2,2),
			Rect2(0, 0, 30, 30),
			Rect2(10, 28, 6, 15)
		],
		[{
			"x":0,
			"y":4,
			"to_ridx":1,
			"to_didx":0
		}],
		Vector2(5, 5)
	)
	
	NEM.add_region(
		Color(0.25, 1.0, 0.25), Color(1.0, 0.75, 0.25),
		[
			Rect2(-10, -10, 20, 20)
		],
		[{
			"x": 10,
			"y": 0,
			"to_ridx": 0,
			"to_didx": 0
		}],
		Vector2(5, 5)
	)
	
	#NEM.add_region(
	#	Color(0.25, 1.0, 0.25), Color(1.0, 0.75, 0.25),
	#	[
	#		Rect2(-25, -25, 24, 24),
	#		Rect2(-25, 1, 24, 24),
	#		Rect2(1, 1, 24, 24),
	#		Rect2(1, -25, 24, 24),
	#		Rect2(-3, -20, 5, 6),
	#		Rect2(-3, -10, 5, 6),
	#		Rect2(10, -3, 6, 5)
	#	],
	#	[{
	#		"x": 25,
	#		"y": 15,
	#		"to_ridx":0,
	#		"to_didx":0
	#	}],
	#	Vector2(5, 5)
	#)
	
	NEM.attach_player(player_node, container_node)
	NEM.attach_camera(camera_node, container_node)

