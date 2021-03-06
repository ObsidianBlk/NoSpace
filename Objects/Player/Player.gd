extends KinematicBody2D
class_name Player


signal trigger
signal teleport(to)
signal charging_up(percent)
signal carrot_count_change(new_count)
signal stamina_change(new_val, max_val)

const TP_DIST_START = 4.0
const TP_DIST_END = 10.0
const SUPER_STAMINA_REGEN_MULTIPLIER = 4.0
const SUPER_STAMINA_REGEN_TIME = 10.0

enum DIRECTION {UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3}

export var sight : int = 512					setget _set_sight
export var speed : float = 200.0				setget _set_speed
export var friction : float = 0.1				setget _set_friction
export var acceleration : float = 0.2			setget _set_acceleration
export var vel_threshold : float = 30.0			setget _set_vel_threshold
export var max_stamina : float = 100.0			setget _set_max_stamina

var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO
var motion : Array = [0,0,0,0]

var triggered = false
var facing = DIRECTION.DOWN

var carrot_count = 0
var part_id = 0
var stamina = 100.0

var super_stamina_timer = 0.0

var tp_charge = 0.0

onready var vizcast_node = $Vizcast
onready var sprite = $Sprite
onready var anim = $Anim

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

func _set_max_stamina(s : float) -> void:
	if s > 0.0:
		max_stamina = s
		if max_stamina < stamina:
			stamina = max_stamina
		emit_signal("stamina_change", stamina, max_stamina)

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

func _process(delta):
	var stamina_multiplier = 1.0
	if super_stamina_timer > 0.0:
		super_stamina_timer = max(0.0, super_stamina_timer - delta)
		if super_stamina_timer > 0.0:
			stamina_multiplier = SUPER_STAMINA_REGEN_MULTIPLIER
			
	if tp_charge >= TP_DIST_START and tp_charge < TP_DIST_END:
		tp_charge += delta * 10
		change_stamina(-(delta * (10 / stamina_multiplier)))
		if stamina > 0.0:
			if tp_charge > TP_DIST_END:
				tp_charge = TP_DIST_END
			emit_signal("charging_up", (tp_charge - TP_DIST_START) / (TP_DIST_END - TP_DIST_START))
		else:
			charge_release()
	else:
		change_stamina(delta * stamina_multiplier)

func get_speed() -> float:
	return velocity.length()

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
		if n.has_method("get_corners"):
			var corners = n.get_corners()
			for corner in corners:
				res = _caster_to_position(vizcast_node, corner)
				if res == null or res == n:
					return true
	return false

func play_animation(anim_name : String) -> void:
	if anim:
		anim.stop()
		anim.play(anim_name)

func flip_sprite(f : bool = true) -> void:
	sprite.flip_h = f

func pickup_part(pid) -> void:
	part_id = pid

func take_part() -> int:
	var p = part_id
	part_id = 0
	return p

func pickup_carrot() -> void:
	carrot_count += 1
	emit_signal("carrot_count_change", carrot_count)

func consume_carrot() -> void:
	if carrot_count > 0:
		carrot_count -= 1
		super_stamina_timer += SUPER_STAMINA_REGEN_TIME
		#change_stamina(10.0)
		emit_signal("carrot_count_change", carrot_count)

func get_carrot_count() -> int:
	return carrot_count

func clear_carrots() -> void:
	carrot_count = 0
	emit_signal("carrot_count_change", carrot_count)

func change_stamina(amount : float) -> void:
	stamina = min(max_stamina, max(0.0, stamina + amount))
	emit_signal("stamina_change", stamina, max_stamina)

func get_facing() -> int:
	return facing

func trigger(e : bool = true) -> void:
	if triggered != e:
		triggered = e
		if triggered:
			emit_signal("trigger")

func is_charging() -> bool:
	return tp_charge > 0.0

func charge_tp() -> void:
	if tp_charge <= 0.0 and stamina > TP_DIST_START:
		tp_charge = TP_DIST_START
		change_stamina(-TP_DIST_START)

func charge_cancel() -> void:
	tp_charge = 0.0
	emit_signal("charging_up", 0.0)

func charge_release() -> void:
	var to = Vector2.ZERO
	if get_speed() > 50.0:
		to = Vector2(tp_charge, 0).rotated(velocity.angle())
	charge_cancel()
	if to.length() > 0.0:
		emit_signal("teleport", to)

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
	if velocity.length() > 0.5:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x < 0:
				facing = DIRECTION.LEFT
			else:
				facing = DIRECTION.RIGHT
		else:
			if velocity.y < 0:
				facing = DIRECTION.UP
			else:
				facing = DIRECTION.DOWN


