extends Container

onready var btn_proceed = $VCB/Main/VBC/PanelContainer/Buttons/BTN_Proceed

func _on_visibility_changed():
	print("Title Visible")
	if visible and btn_proceed:
		btn_proceed.grab_focus()
