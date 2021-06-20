extends Control


onready var lbl_region = $VBC/Information/HBC/Region/Label
onready var lbl_carrot = $VBC/Information/HBC/Stats/VBC/Carrots/Label
onready var prog_stamina = $VBC/Information/HBC/Stats/VBC/Stamina/Progress/Bar
onready var prog_shattered_time = $VBC/TheShattered/LifeTime/Bar


func set_region(region_name : String) -> void:
	if region_name == "":
		region_name = "__UNKNOWN__"
	if lbl_region:
		lbl_region.text = region_name


func set_carrots(count : int) -> void:
	if lbl_carrot:
		lbl_carrot.text = ":" + String(count)


func set_stamina(v : float, vmax : float) -> void:
	if prog_stamina:
		prog_stamina.max_value = vmax
		prog_stamina.value = v

func set_shattered_life_time(v : float, vmax : float) -> void:
	if prog_shattered_time:
		prog_shattered_time.max_value = vmax
		prog_shattered_time.value = v
