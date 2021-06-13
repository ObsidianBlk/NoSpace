extends KinematicBody2D
class_name Player

enum DIRECTION {UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3}


export var speed : float = 200.0				setget _set_speed
export var friction : float = 0.1
export var acceleration : float = 0.2
export var vel_threshold : float = 4.0

var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO
var motion : Array = [0,0,0,0]


func _set_speed(s : float) -> void:
	if s > 0.0:
		speed = s

func _update_direction() -> void:
	direction.x = motion[DIRECTION.RIGHT] - motion[DIRECTION.LEFT]
	direction.y = motion[DIRECTION.DOWN] - motion[DIRECTION.UP]
	if direction.length() > 1.0:
		direction = direction.normalized()

func _ready() -> void:
	pass


func is_moving() -> bool:
	return velocity.length_squared() > 0.0


func move(dir : int, amount : float = 1.0) -> void:
	if dir == DIRECTION.UP or dir == DIRECTION.DOWN or dir == DIRECTION.LEFT or dir == DIRECTION.RIGHT:
		motion[dir] = clamp(amount, 0.0, 1.0)
		_update_direction()


func update_movement(delta : float) -> void:
	if direction.length_squared() > 0:
		velocity = lerp(velocity, direction * speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
		if velocity.length() < vel_threshold:
			velocity = Vector2.ZERO
	
	velocity = move_and_slide(velocity)


