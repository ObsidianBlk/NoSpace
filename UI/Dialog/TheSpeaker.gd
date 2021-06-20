extends Control

export (Dialog.SPEAKER) var speaker = Dialog.SPEAKER.NONE		setget _set_speaker

onready var shattered_node = $TheShattered/VBC/HBC
onready var entity_node = $TheEntity/VBC/HBC

func _set_speaker(s : int) -> void:
	var found = false
	for key in Dialog.SPEAKER:
		if Dialog.SPEAKER[key] == s:
			found = true
	
	if found:
		speaker = s
		shattered_node.visible = false
		entity_node.visible = false
		match (speaker):
			Dialog.SPEAKER.SHATTERED:
				shattered_node.visible = true
			Dialog.SPEAKER.ENTITY:
				entity_node.visible = true
