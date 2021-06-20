extends Control
class_name Menus

signal start_game
signal resume_game
signal quit_game
signal escape

enum SCREENS {NONE = 0, TITLE = 1, GAME = 2, OPTIONS = 3, ABOUTGWJ = 4}

export (SCREENS) var screen = SCREENS.TITLE			setget _set_screen

onready var audio_bus_master = AudioServer.get_bus_index("Master")
onready var audio_bus_sfx = AudioServer.get_bus_index("SFX")
onready var audio_bus_music = AudioServer.get_bus_index("Music")

onready var titlemenu_node = $TitleMenu
onready var gamemenu_node = $GameMenu
onready var optionsmenu_node = $OptionsMenu
onready var aboutgwj_node = $AboutGWJ34Menu

func _set_screen(s : int) -> void:
	var found = false
	for key in SCREENS:
		if SCREENS[key] == s:
			found = true
			break
	if not found:
		return
	
	screen = s
	
	var game_paused = false
	titlemenu_node.visible = false
	gamemenu_node.visible = false
	optionsmenu_node.visible = false
	aboutgwj_node.visible = false
	match(screen):
		SCREENS.TITLE:
			titlemenu_node.visible = true
			game_paused = true
		SCREENS.GAME:
			gamemenu_node.visible = true
			game_paused = true
		SCREENS.OPTIONS:
			optionsmenu_node.visible = true
			game_paused = true
		SCREENS.ABOUTGWJ:
			aboutgwj_node.visible = true
			game_paused = true
	get_tree().paused = game_paused

func _ready() -> void:
	_set_screen(screen)
	optionsmenu_node.set_volume_slider(
		0,
		db2linear(AudioServer.get_bus_volume_db(audio_bus_master))
	)
	optionsmenu_node.set_volume_slider(
		1,
		db2linear(AudioServer.get_bus_volume_db(audio_bus_sfx))
	)
	optionsmenu_node.set_volume_slider(
		2,
		db2linear(AudioServer.get_bus_volume_db(audio_bus_music))
	)

func _on_BTN_Proceed_pressed() -> void:
	emit_signal("start_game")

func _on_BTN_Escape_pressed() -> void:
	emit_signal("quit_game")

func _on_BTN_Adjustments_pressed() -> void:
	if screen == SCREENS.GAME or screen == SCREENS.TITLE:
		_set_screen(SCREENS.OPTIONS)

func _on_BTN_Resume_pressed() -> void:
	emit_signal("resume_game")

func _on_BTN_Back_pressed() -> void:
	emit_signal("escape")

func _on_MasterVol_value_changed(value):
	AudioServer.set_bus_volume_db(audio_bus_master, linear2db(value))

func _on_SFXVol_value_changed(value):
	AudioServer.set_bus_volume_db(audio_bus_sfx, linear2db(value))

func _on_MusicVol_value_changed(value):
	AudioServer.set_bus_volume_db(audio_bus_music, linear2db(value))

