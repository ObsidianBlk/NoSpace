extends Node2D


var game_started = false
var played_opening = false

onready var NEM = $NEM
onready var player_node = $Container/Player
onready var camera_node = $Container/Camera
onready var container_node = $Container

onready var hud_node = $UI/HUD
onready var menus_node = $UI/Menus
onready var dialog_node = $UI/Dialog


func _menu_escape() -> void:
	if dialog_node.visible == true:
		return # Don't do anything if dialog is open.
	
	if menus_node.screen == Menus.SCREENS.NONE and game_started:
		menus_node.screen = Menus.SCREENS.GAME
	elif menus_node.screen != Menus.SCREENS.TITLE and menus_node.screen != Menus.SCREENS.GAME:
		if game_started:
			menus_node.screen = Menus.SCREENS.GAME
		else:
			menus_node.screen = Menus.SCREENS.TITLE


func _ready():
	dialog_node.connect("dialog_closed", self, "_on_dialog_closed")
	NEM.connect("region_change", self, "_on_region_change")
	NEM.connect("life_time_change", self, "_on_life_time_change")
	NEM.connect("completed", self, "_on_completed")
	NEM.connect("oot", self, "_on_oot")
	player_node.connect("carrot_count_change", self, "_on_carrot_counter_changed")
	player_node.connect("stamina_change", self, "_on_stamina_change")
	
	
func _unhandled_input(event):
	if event.is_action_pressed("escape"):
		_menu_escape()

func _opening_dialog() -> void:
	dialog_node.visible = true
	get_tree().paused = true
	dialog_node.multi_say([
		{"speaker_id":Dialog.SPEAKER.ENTITY, "text":"Where... where am I?"},
		{"speaker_id":Dialog.SPEAKER.SHATTERED, "text":"Good, Entity, you have come. Space is limited. Not enough time..."},
		{"speaker_id":Dialog.SPEAKER.ENTITY, "text":"Who said... wait... Space is what?"},
		{"speaker_id":Dialog.SPEAKER.SHATTERED, "text":"No space to explain. Parts three I need. You must find and bring them to me. Soon I will have no space left. Search before space runs out!"},
		{"speaker_id":Dialog.SPEAKER.ENTITY, "text":"I don't understand... No space? You're running out of what?"},
		{"speaker_id":Dialog.SPEAKER.SHATTERED, "text":"Yes. Understanding is yours. Fear not. Carrots are plentiful, but space is not. I need more. Find parts of mine three."},
		{"speaker_id":Dialog.SPEAKER.ENTITY, "text":"How am I supposed to..."},
		{"speaker_id":Dialog.SPEAKER.SHATTERED, "text":"[E] to open doors and give me parts, but you must not move.\n[Q] to eat your carrots... helps stamina\n[SPACE] to jump, but you must be moving."},
		{"speaker_id":Dialog.SPEAKER.ENTITY, "text":"I, quite literally, have no idea what you're talking about!"},
		{"speaker_id":Dialog.SPEAKER.SHATTERED, "text":"Good... go! Space is running out!"}
	])

func _on_completed() -> void:
	game_started = false
	dialog_node.visible = true
	get_tree().paused = true
	dialog_node.say(
		Dialog.SPEAKER.SHATTERED,
		"Entity... you have successfully found all of my parts in space. I now have all the time I need. You are no longer required."
	)

func _on_oot() -> void:
	game_started = false
	dialog_node.visible = true
	get_tree().paused = true
	dialog_node.say(
		Dialog.SPEAKER.SHATTERED,
		"Entity... you have failed. I must search out in time for more space now. This failing is yours."
	)

func _on_dialog_closed() -> void:
	dialog_node.visible = false
	if not game_started:
		hud_node.visible = false
		get_tree().paused = false
		NEM.clear_map()
		NEM.detach_player_to_container(container_node)
		NEM.detach_camera_to_container(container_node)
		get_tree().paused = true
		menus_node.screen = Menus.SCREENS.TITLE
	else:
		get_tree().paused = false

func _on_region_change(rname : String) -> void:
	if hud_node:
		hud_node.set_region(rname)

func _on_life_time_change(v : float, vmax : float) -> void:
	if hud_node:
		hud_node.set_shattered_life_time(v, vmax)

func _on_carrot_counter_changed(count : int) -> void:
	if hud_node:
		hud_node.set_carrots(count)

func _on_stamina_change(val : float, max_val : float) -> void:
	if hud_node:
		hud_node.set_stamina(val, max_val)


func _on_start_game() -> void:
	if game_started:
		return
	
	menus_node.screen = Menus.SCREENS.NONE
	hud_node.visible = true
	
	RegionDefs.generate_regions(
		RegionDefs.get_random_hub(),
		RegionDefs.get_random_region(),
		12
	)
	var regions = RegionDefs.get_gen_regions()
	for reg in regions:
		NEM.add_region(reg)
	NEM.attach_player(player_node, container_node)
	NEM.attach_camera(camera_node, container_node)
	player_node.max_stamina = 100
	game_started = true
	
	if not played_opening:
		_opening_dialog()
		played_opening = true
		

func _on_quit_game() -> void:
	get_tree().quit()

func _on_resume_game():
	if game_started and menus_node.screen == Menus.SCREENS.GAME:
		menus_node.screen = Menus.SCREENS.NONE

func _on_escape():
	_menu_escape()
