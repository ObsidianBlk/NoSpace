extends CenterContainer

onready var btn_resume = $VBC/BTN_Back

func _on_visibility_changed():
	if visible and btn_resume:
		btn_resume.grab_focus()
