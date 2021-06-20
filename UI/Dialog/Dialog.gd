extends Control
class_name Dialog

signal dialog_closed

enum SPEAKER {NONE = 0, SHATTERED = 1, ENTITY = 2}

var multi_lines = null
var cur_line = 0

onready var thespeaker_node = $TheSpeaker
onready var text_label_node = $Text/Label_Box/MC/Label
onready var tween_node = $Tween

func _set_speaker(s : int) -> void:
	var found = false
	for key in SPEAKER:
		if SPEAKER[key] == s:
			found = true
	
	if found and thespeaker_node:
		thespeaker_node.speaker = s
	

func _ready():
	pass

func _unhandled_input(event):
	if not visible:
		return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		if tween_node.is_active():
			show_all_text()
		else:
			if multi_lines != null and cur_line + 1 < multi_lines.size():
				say(multi_lines[cur_line].speaker_id, multi_lines[cur_line].text)
				cur_line += 1
			else:
				visible = false
				emit_signal("dialog_closed")


func multi_say(lines : Array) -> void:
	multi_lines = []
	cur_line = 0
	for line in lines:
		if line.get("speaker_id") != null and line.get("text") != null:
			multi_lines.append(line)
	if multi_lines.size() <= 0:
		multi_lines = null
	else:
		say(multi_lines[cur_line].speaker_id, multi_lines[cur_line].text)
		cur_line += 1

func say(speaker_id : int, text : String, duration : float = 1.0) -> void:
	if text_label_node:
		text_label_node.text = text
	_set_speaker(speaker_id)
	if text_label_node:
		text_label_node.percent_visible = 0.0
		if duration > 0.0:
			tween_node.interpolate_property(
				text_label_node,
				"percent_visible",
				0.0, 1.0,
				duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN_OUT
			)
			tween_node.start()

func show_all_text() -> void:
	if tween_node:
		tween_node.stop_all()
	if text_label_node:
		text_label_node.percent_visible = 1.0

