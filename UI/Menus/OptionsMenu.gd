extends CenterContainer

onready var btn_resume = $VBC/MainPanel/MC/Controls/BTN_Back
onready var slider_master_volume = $VBC/MainPanel/MC/Controls/MainAudio/Slider
onready var slider_sfx_volume = $VBC/MainPanel/MC/Controls/SFXAudio/Slider
onready var slider_music_volume = $VBC/MainPanel/MC/Controls/MusicAudio/Slider


func set_volume_slider(aid: int, v : float) -> void:
	match(aid):
		0:
			slider_master_volume.value = v
		1:
			slider_sfx_volume.value = v
		2:
			slider_music_volume.value = v

func _on_visibility_changed():
	if visible and btn_resume:
		btn_resume.grab_focus()
