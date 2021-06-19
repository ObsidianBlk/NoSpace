extends CenterContainer

onready var btn_resume = $VBC/MainPanel/MC/Buttons/BTN_Resume

func _on_visibility_changed():
	if visible and btn_resume:
		btn_resume.grab_focus()
