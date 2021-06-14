extends KinematicBody2D
class_name Player

enum DIRECTION {UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3}

export var sight : int = 512					setget _set_sight
export var speed : float = 200.0				setget _set_speed
export var friction : float = 0.1				setget _set_friction
export var acceleration : float = 0.2			setget _set_acceleration
export var vel_threshold : float = 4.0			setget _set_vel_threshold

var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO
var motion : Array = [0,0,0,0]

onready var vizcast_node = $Vizcast
onready var vizcast2_node = $Vizcast2

func _set_sight(s : int) -> void:
	if s > 0:
		sight = s

func _set_speed(s : float) -> void:
	if s > 0.0:
		speed = s

func _set_friction(f : float) -> void:
	if f >= 0.0:
		friction = f

func _set_acceleration(a : float) -> void:
	if a > 0.0:
		acceleration = a

func _set_vel_threshold(t : float) -> void:
	if t > 0.0:
		vel_threshold = t

func _update_direction() -> void:
	direction.x = motion[DIRECTION.RIGHT] - motion[DIRECTION.LEFT]
	direction.y = motion[DIRECTION.DOWN] - motion[DIRECTION.UP]
	if direction.length() > 1.0:
		direction = direction.normalized()

func _caster_to_position(cast : RayCast2D, pos : Vector2):
	var dist = cast.global_position.distance_to(pos)
	var cast_to = Vector2(-dist, 0).rotated(cast.global_position.angle_to_point(pos))
	cast.cast_to = cast_to
	cast.force_raycast_update()
	return cast.get_collider()

func _cast_can_see_position(cast : RayCast2D, pos : Vector2) -> bool:
	var dist = cast.global_position.distance_to(pos)
	var cast_to = Vector2(-dist, 0).rotated(cast.global_position.angle_to_point(pos))
	cast.cast_to = cast_to
	cast.force_raycast_update()
	return cast.get_collider() == null

func _cast_can_see_node(cast : RayCast2D, n : Node2D) -> bool:
	var dist = cast.global_position.distance_to(n.position)
	var cast_to = Vector2(-dist, 0).rotated(cast.global_position.angle_to_point(n.position))
	cast.cast_to = cast_to
	cast.force_raycast_update()
	var col = cast.get_collider()
	return col == null or col == n

func _ready() -> void:
	pass

func in_sight_range(pos : Vector2) -> bool:
	return position.distance_to(pos) < sight

func can_see_position(pos : Vector2) -> bool:
	var dist = position.distance_to(pos)
	if dist < sight:
		if _caster_to_position(vizcast_node, pos) == null:
			return true
	return false

func can_see_node(n : Node2D) -> bool:
	var dist = position.distance_to(n.position)
	if dist < sight:
		var res = _caster_to_position(vizcast_node, n.position)
		if res == null or res == n:
			return true
		if n is PulseTile:
			var corners = n.get_corners()
			for corner in corners:
				res = _caster_to_position(vizcast_node, corner)
				if res == null or res == n:
					return true
	return false

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


