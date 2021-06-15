tool
extends Node2D

# ---------------------------------------------------------------------------
# ENUM Definitions
# ---------------------------------------------------------------------------
enum TILE_TYPE {NONE = 0, FLOOR = 1, WALL = 2, DOOR = 3}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------
var tile_resource = preload("res://Objects/NEM/PulseTile.tscn")
var door_resource = preload("res://Objects/NEM/DoorTile.tscn")
var tile_size = 32

var player_node = null
var camera_node = null
var regions = []

var living_regions = []
var living_tiles = {}

# ---------------------------------------------------------------------------
# On Ready Variables
# ---------------------------------------------------------------------------
onready var ents_node = $Ents
onready var floors_node = $Floors
onready var vizcast_node = $Viz_cast


# ---------------------------------------------------------------------------
# "Private" Methods
# ---------------------------------------------------------------------------
func _update_living_tiles() -> void:
	if player_node == null:
		return
	if living_regions.size() <= 0:
		return
	
	_clear_living_tiles()
	_scan_for_living_tiles()


func _clear_living_tiles() -> void:
	var dkeys = []
	for key in living_tiles:
		var n = living_tiles[key]
		if is_entity_visible(n):
			if n is PulseTile:
				var dist = player_node.position.distance_to(n.position)
				n.alpha = 1.0 - (dist / player_node.sight)
		else:
			dkeys.append(key)
			
	for key in dkeys:
		if living_tiles[key] is DoorTile:
			living_tiles[key].disconnect("door_opened", self, "_on_door_opened")
		floors_node.remove_child(living_tiles[key])
		living_tiles[key].queue_free()
		living_tiles.erase(key)


func _scan_for_living_tiles() -> void:
	var tiles = []
	if living_regions.size() == 1:
		tiles = _get_tiles(player_node.position, player_node.sight)
	elif living_regions.size() == 2:
		tiles = _get_tiles(player_node.position, player_node.sight, 0)
		var tb = _get_tiles(player_node.position, player_node.sight, 1)
		if tiles.size() != tb.size():
			print("WARNING: Resulting tile counts don't match!")
			tiles = []
			# TODO: If this is an actual issue, figure out a better solution?
		else:
			for idx in range(0, tiles.size()):
				if tiles[idx][1] == TILE_TYPE.NONE:
					tiles[idx] = tb[idx]
	
	if tiles.size() > 0:
		var px = int(player_node.position.x) % int(tile_size)
		var py = int(player_node.position.y) % int(tile_size)
		var rad = floor(player_node.sight / tile_size)
		var start = Vector2(px - rad, py - rad)
		var idx = 0

		for y in range(start.y, (start.y + (rad * 2))):
			for x in range(start.x, (start.x + (rad * 2))):
				var tpos = tiles[idx][2] * tile_size
				var key = String(tpos.x) + "x" + String(tpos.y)
				var ttype = tiles[idx][1]
				
				if not (key in living_tiles) and is_position_visible(tpos) and ttype != TILE_TYPE.NONE:
					var ridx = tiles[idx][0]
					var tidx = tiles[idx][3]
					var tn = null
					
					if ttype == TILE_TYPE.DOOR:
						print("Checking for door")
						var dinfo = _get_door_info(ridx, tidx)
						if dinfo != null:
							tn = door_resource.instance()
							tn.facing = dinfo.facing
							tn.ridx = dinfo.to_ridx
							tn.tidx = dinfo.to_tidx
							tn.connect("door_opened", self, "_on_door_open")
						else:
							print("Failed to find door")
							ttype = TILE_TYPE.WALL
					
					if ttype == TILE_TYPE.FLOOR:
						tn = tile_resource.instance()
						tn.color = regions[ridx].floor_color
					elif ttype == TILE_TYPE.WALL:
						tn = tile_resource.instance()
						tn.color = regions[ridx].wall_color
						tn.collision_enabled = true
						tn.base_intensity = 1.0
					
					if tn != null:
						floors_node.add_child(tn)
						tn.position = tpos
						living_tiles[key] = tn
				idx += 1

func _get_door_info(ridx : int, tidx : int):
	var door_list = regions[ridx].doors
	for door in door_list:
		if door.tidx == tidx and _door_exists(door.to_ridx, door.to_didx):
			return door
	return null

func _door_exists(ridx : int, didx : int) -> bool:
	if ridx >= 0 and ridx <= regions.size():
		var door_list = regions[ridx].doors
		for door in door_list:
			if door.didx == didx:
				return true
	return false

func _world_to_region(pos : Vector2, lridx : int) -> Vector2:
	if living_regions.size() <= 0:
		return pos
	if not (lridx >= 0 and lridx < living_regions.size()):
		return pos
	
	var npos = pos - living_regions[lridx].offset
	npos = Vector2(floor(npos.x / tile_size), floor(npos.y / tile_size))
	
	return npos

func _get_tiles(pos : Vector2, radius : float, lridx : int = 0):
	if living_regions.size() <= 0:
		return
	if not (lridx >= 0 and lridx < living_regions.size()):
		return
	
	var tiles = []
	var reg = regions[living_regions[lridx].ridx]
	var start = _world_to_region(pos, lridx)
	var reg_size = Vector2(reg.width, reg.height)
	
	var trad = floor(radius / tile_size)
	
	for y in range(start.y - trad, start.y + trad):
		for x in range(start.x - trad, start.x + trad):
			var tval = TILE_TYPE.NONE
			var tpos = Vector2(x, y)
			var tidx = (y * reg_size.x) + x
			if x >= 0 and x < reg_size.x and y >= 0 and y < reg_size.y:
				var dist = tpos.distance_to(start)
				if dist < trad:
					tval = reg.tiles[tidx]
			tiles.append([living_regions[lridx].ridx, tval, tpos, tidx])
	return tiles

func _get_cur_region_player_start() -> Vector2:
	if living_regions.size() > 0:
		var ridx = living_regions[0].ridx
		if regions[ridx].player_start == null:
			for y in range(0, regions[ridx].height):
				for x in range(0, regions[ridx].width):
					var idx = (y * regions[ridx].width) + x
					if regions[ridx].tiles[idx] == TILE_TYPE.FLOOR:
						return Vector2(
							(x * tile_size) + living_regions[0].offset.x,
							(y * tile_size) + living_regions[0].offset.y)
		else:
			return (regions[ridx].player_start * tile_size) + living_regions[0].offset
	return Vector2.ZERO

func _link_camera_and_player() -> void:
	if camera_node and player_node:
		camera_node.target_path = player_node.get_path()

# ---------------------------------------------------------------------------
# NODE Override Methods
# ---------------------------------------------------------------------------
func _physics_process(delta : float) -> void:
	_update_living_tiles()

# ---------------------------------------------------------------------------
# "Public" Methods"
# ---------------------------------------------------------------------------
func detach_player_to_container(container : Node2D) -> void:
	if player_node != null:
		ents_node.remove_child(player_node)
		container.add_child(player_node)
		player_node = null

func attach_player(p : Player, container : Node2D) -> void:
	if player_node != p:
		var ppos = null
		
		if player_node != null:
			ppos = player_node.position
			detach_player_to_container(container)
		else:
			ppos = _get_cur_region_player_start()
		
		var pparent = p.get_parent()
		pparent.remove_child(p)
		ents_node.add_child(p)
		player_node = p
		player_node.position = ppos
		
		_link_camera_and_player()


func detach_camera_to_container(container : Node2D) -> void:
	if camera_node != null:
		camera_node.target_path = ""
		remove_child(camera_node)
		container.add_child(camera_node)
		camera_node = null

func attach_camera(c : Camera2D, container : Node2D) -> void:
	if camera_node != c:
		detach_camera_to_container(container)
		var cparent = c.get_parent()
		cparent.remove_child(c)
		add_child(c)
		camera_node = c
		
		_link_camera_and_player()

func is_position_visible(pos : Vector2) -> bool:
	if player_node == null:
		return false
	return player_node.can_see_position(pos)

func is_entity_visible(ent : Node2D) -> bool:
	if player_node == null:
		return false
	return player_node.can_see_node(ent)


func add_region(floor_color : Color, wall_color : Color, rect_list : Array, door_list : Array, player_start_pos : Vector2) -> void:
	var reg = {
		"floor_color": floor_color,
		"wall_color": wall_color,
		"width": 0,
		"height": 0,
		"player_start": null,
		"doors": [],
		"tiles":null
	}
	
	var container_rect = Rect2(0, 0, 0, 0)
	for rect in rect_list:
		container_rect = container_rect.merge(rect)
	reg.width = container_rect.size.x
	reg.height = container_rect.size.y
	

	# TODO ... Why can't I do the below three lines with a PoolByteArray?!?!?!
	reg.tiles = []
	for _i in range(0, container_rect.size.x * container_rect.size.y):
		reg.tiles.append(TILE_TYPE.NONE)
	
	for rect in rect_list:
		var start = Vector2(
			rect.position.x - container_rect.position.x,
			rect.position.y - container_rect.position.y
		)
		var end = Vector2(start.x + rect.size.x, start.y + rect.size.y)
		
		for y in range(start.y, end.y):
			for x in range(start.x, end.x):
				var index = (y * container_rect.size.x) + x
				if (x == start.x or x == end.x - 1 or y == start.y or y == end.y - 1):
					if reg.tiles[index] == TILE_TYPE.NONE:
						reg.tiles[index] = TILE_TYPE.WALL
				else:
					reg.tiles[index] = TILE_TYPE.FLOOR
	
	for didx in range(0, door_list.size() - 1):
		var door = door_list[didx]
		var dx = door.x - container_rect.position.x
		var dy = door.y - container_rect.position.y
		if dx >= 1 and dx < container_rect.size.x - 1 and dy >= 1 and dy < container_rect.size.y - 1:
			var idx = (dy * container_rect.size.x) + dx
			if reg.tiles[idx] == TILE_TYPE.WALL:
				var facing = -1 # -1 = Invalid
				
				var idx_l = (dy * container_rect.size.x) + (dx - 1)
				var idx_r = (dy * container_rect.size.y) + (dx + 1)
				var idx_u = ((dy - 1) * container_rect.size.x) + dx
				var idx_d = ((dy + 1) * container_rect.size.x) + dx
				if reg.tiles[idx_l] == TILE_TYPE.WALL and reg.tiles[idx_r] == TILE_TYPE.WALL:
					if reg.tiles[idx_u] == TILE_TYPE.NONE:
						facing = DoorTile.FACING.UP
					elif reg.tiles[idx_d] == TILE_TYPE.NONE:
						facing = DoorTile.FACING.DOWN
					
				
				if facing < 0:
					if reg.tiles[idx_u] == TILE_TYPE.WALL and reg.tiles[idx_d] == TILE_TYPE.WALL:
						if reg.tiles[idx_l] == TILE_TYPE.NONE:
							facing = DoorTile.FACING.LEFT
						if reg.tiles[idx_r] == TILE_TYPE.NONE:
							facing = DoorTile.FACING.RIGHT
						
				if facing == 0 || facing == 1:
					reg.doors.append({
						"tidx": idx,
						"didx": didx,
						"x":dx,
						"y":dy,
						"facing": facing,
						"to_ridx":door.to_ridx,
						"to_didx":door.to_didx
					})
					reg.tiles[idx] = TILE_TYPE.DOOR
	
	var px = int(player_start_pos.x) - container_rect.position.x
	var py = int(player_start_pos.y) - container_rect.position.y
	if px >= 0 and px < container_rect.size.x and py > 0 and py < container_rect.size.y:
		var pidx = (py * container_rect.size.x) + px
		if reg.tiles[pidx] == TILE_TYPE.FLOOR:
			reg.player_start = Vector2(float(px), float(py))
	
	regions.append(reg)
	if living_regions.size() <= 0:
		living_regions.append({
			"offset":Vector2(0, 0),
			"ridx": regions.size() - 1
		})


# ---------------------------------------------------------------------------
# Signal Handler Methods
# ---------------------------------------------------------------------------

func _on_door_open(ridx : int, tidx : int) -> void:
	pass


