extends Node2D


onready var NEM = $NEM
onready var player_node = $Container/Player
onready var camera_node = $Container/Camera
onready var container_node = $Container

onready var hud_node = $UI/HUD


func _ready():
	NEM.connect("region_change", self, "_on_region_change")
	player_node.connect("carrot_count_change", self, "_on_carrot_counter_changed")
	player_node.connect("stamina_change", self, "_on_stamina_change")
	player_node.max_stamina = 100
	RegionDefs.generate_regions(
		RegionDefs.get_random_hub(),
		RegionDefs.get_random_region()
	)
	var regions = RegionDefs.get_gen_regions()
	for reg in regions:
		NEM.add_region(reg)
	
	NEM.attach_player(player_node, container_node)
	NEM.attach_camera(camera_node, container_node)


func _on_region_change(rname : String) -> void:
	if hud_node:
		hud_node.set_region(rname)

func _on_carrot_counter_changed(count : int) -> void:
	if hud_node:
		hud_node.set_carrots(count)

func _on_stamina_change(val : float, max_val : float) -> void:
	if hud_node:
		hud_node.set_stamina(val, max_val)
