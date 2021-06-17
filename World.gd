extends Node2D


onready var NEM = $NEM
onready var player_node = $Container/Player
onready var camera_node = $Container/Camera
onready var container_node = $Container


func _ready():
	RegionDefs.generate_regions(
		RegionDefs.get_random_hub(),
		RegionDefs.get_random_region()
	)
	var regions = RegionDefs.get_gen_regions()
	for reg in regions:
		NEM.add_region(reg)
	
	NEM.attach_player(player_node, container_node)
	NEM.attach_camera(camera_node, container_node)

