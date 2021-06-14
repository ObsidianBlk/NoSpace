extends Node2D


onready var NEM = $NEM
onready var player_node = $Container/Player
onready var container_node = $Container


func _ready():
	NEM.add_region(
		Color(0.25, 0.25, 1.0), Color(0.25, 0.75, 1.0),
		[
			Rect2(0, 0, 10, 10),
			Rect2(8, 4, 6, 15)
		],
		[],
		Vector2(5, 5)
	)
	NEM.attach_player(player_node, container_node)

