extends Camera2D


export var target_path : NodePath = ""			setget _set_target_path

var target = null

func _set_target_path(tp : NodePath) -> void:
	target_path = tp
	if tp == "":
		target = null
	else:
		var _t = get_node(target_path)
		if _t:
			target = _t

func _ready():
	if target == null and target_path != "":
		_set_target_path(target_path)

func _physics_process(delta):
	if target != null:
		global_position = target.global_position
