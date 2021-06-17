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

var opened_door_info = null

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
	
	var tiles = _scan_for_living_tiles()
	_build_from_tiles(tiles)
	_clear_living_tiles()


func _clear_living_tiles() -> void:
	var dkeys = []
	for key in living_tiles:
		var n = living_tiles[key]
		if _is_region_alive(n.ridx) and is_entity_visible(n.tile):
			if n.tile is PulseTile or n.tile is DoorTile:
				var dist = player_node.position.distance_to(n.tile.position)
				n.tile.alpha = 1.0 - (dist / player_node.sight)
			else:
				print("This is odd")
		else:
			dkeys.append(key)
			
	for key in dkeys:
		if living_tiles[key].tile is DoorTile:
			living_tiles[key].tile.disconnect("door_opened", self, "_on_door_opened")
			living_tiles[key].tile.disconnect("door_closed", self, "_on_door_closed")
		living_tiles[key].tile.kill()
		#floors_node.remove_child(living_tiles[key].tile)
		#living_tiles[key].tile.queue_free()
		living_tiles.erase(key)


func _scan_for_living_tiles() -> Array:
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
				#if tiles[idx][1] == TILE_TYPE.NONE and tb[idx][1] != TILE_TYPE.NONE:
				#	tiles[idx] = tb[idx]
				#elif opened_door_info != null:
				#var doffs = Vector2(
				#	(opened_door_info.x * tile_size) - living_regions[0].offset.x,
				#	(opened_door_info.y * tile_size) - living_regions[0].offset.y
				#)
				#var swap = false
				#match(opened_door_info.facing):
				#	DoorTile.FACING.UP:
				#		swap = player_node.position.y < doffs.y
				#	DoorTile.FACING.DOWN:
				#		swap = player_node.position.y > doffs.y
				#	DoorTile.FACING.LEFT:
				#		swap = player_node.position.x < doffs.x
				#	DoorTile.FACING.RIGHT:
				#		swap = player_node.position.x > doffs.x
				
				#if swap:
				#	var t = tiles
				#	tiles = tb
				#	tb = t
				
				if tiles[idx][1] == TILE_TYPE.NONE and tb[idx][1] != TILE_TYPE.NONE:
					tiles[idx] = tb[idx]
	return tiles

func _build_from_tiles(tiles : Array) -> void:
	if tiles.size() > 0:
		var px = int(player_node.position.x) % int(tile_size)
		var py = int(player_node.position.y) % int(tile_size)
		var rad = floor(player_node.sight / tile_size)
		var start = Vector2(px - rad, py - rad)

		for idx in range(0, tiles.size()):
			var ridx = tiles[idx][0]
			var ttype = tiles[idx][1]
			var tpos = tiles[idx][2] * tile_size
			var tidx = tiles[idx][3]
			var key = String(int(tpos.x)) + "x" + String(int(tpos.y))
			
			#var allow = true
			#if (key in living_tiles):
			#	if opened_door_info == null:
			#		allow = false
			#	elif living_tiles[key].tile is DoorTile:
			#		allow = false
			#	else:
			#		if living_tiles[key].ridx == ridx or opened_door_info.regdom != ridx:
			#			allow = false
			if not (key in living_tiles) and is_position_visible(tpos) and ttype != TILE_TYPE.NONE:
				var tn = null
				
				if ttype == TILE_TYPE.DOOR:
					var dinfo = _get_door_info(ridx, tidx)
					if dinfo != null:
						tn = door_resource.instance()
						tn.facing = dinfo.facing
						tn.ridx = dinfo.to_ridx
						tn.didx = dinfo.to_didx
						tn.color = regions[ridx].wall_color
						tn.connect("door_opened", self, "_on_door_open")
						tn.connect("door_closed", self, "_on_door_closed")
					else:
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
					living_tiles[key] = {"ridx":ridx, "tile":tn}


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

func _get_tiles(pos : Vector2, radius : float, lridx : int = 0):
	if living_regions.size() <= 0:
		return
	if not (lridx >= 0 and lridx < living_regions.size()):
		return
	
	var tiles = []
	pos = Vector2(floor(pos.x / tile_size), floor(pos.y / tile_size))
	var reg = regions[living_regions[lridx].ridx]
	var reg_size = Vector2(reg.width, reg.height)
	var offset = living_regions[lridx].offset / tile_size
	var start = pos
	
	var trad = floor(radius / tile_size)
	var inc_region = Rect2(start.x - trad, start.y - trad, trad*2, trad*2)
	var treg = false
	if lridx == 0 and opened_door_info != null:
		# NOTE: For my own confusion, the actual inclusion regions are INVERTED due to an error in
		# facing that cannot be fixed quickly (I think).
		match(opened_door_info.facing):
			DoorTile.FACING.UP:
				inc_region = Rect2(start.x - trad, start.y - trad, trad*2, trad)
			DoorTile.FACING.DOWN:
				inc_region = Rect2(start.x - trad, start.y, trad*2, trad)
			DoorTile.FACING.LEFT:
				inc_region = Rect2(start.x - trad, start.y - trad, trad, trad*2)
			DoorTile.FACING.RIGHT:
				inc_region = Rect2(start.x, start.y - trad, trad, trad*2)
		if living_regions[1].ridx == 2:
			treg = true
			#print("Facing: ", regions[1].doors[1].facing)
			#print("Pos", pos, " | Inc Region: ", inc_region, "Facing: ", opened_door_info.facing)
	
	for y in range(start.y - trad, start.y + trad):
		for x in range(start.x - trad, start.x + trad):
			var tval = TILE_TYPE.NONE
			var tpos = Vector2(x - offset.x, y - offset.y)
			var tidx = (tpos.y * reg_size.x) + tpos.x
			if tpos.x >= 0 and tpos.x < reg_size.x and tpos.y >= 0 and tpos.y < reg_size.y:
				var dist = Vector2(x, y).distance_to(start)
				
				#if treg and not (inc_region.has_point(Vector2(x, y))):
				#	print("Cannot Store: ", Vector2(x, y))
				if dist < trad and inc_region.has_point(Vector2(x, y)):
					tval = reg.tiles[tidx]
			tiles.append([living_regions[lridx].ridx, tval, tpos + offset, tidx])
	return tiles

func _is_region_alive(ridx : int) -> bool:
	for lr in living_regions:
		if lr.ridx == ridx:
			return true
	return false

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


func add_region(floor_color : Color, wall_color : Color, rect_list : Array, door_list : Array, player_start_pos : Vector2, prnt : bool = false) -> void:
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
		
		if rect.position.x == 14 and rect.position.y == 7:
			pass
		
		for y in range(start.y, end.y):
			for x in range(start.x, end.x):
				var index = (y * container_rect.size.x) + x
				if (x == start.x or x == end.x - 1 or y == start.y or y == end.y - 1):
					if reg.tiles[index] == TILE_TYPE.NONE:
						reg.tiles[index] = TILE_TYPE.WALL
				else:
					reg.tiles[index] = TILE_TYPE.FLOOR
	
	for didx in range(0, door_list.size()):
		var door = door_list[didx]
		var dx = door.x - container_rect.position.x
		var dy = door.y - container_rect.position.y
		if dx >= 0 and dx < container_rect.size.x and dy >= 0 and dy < container_rect.size.y:
			var idx = (dy * container_rect.size.x) + dx
			if reg.tiles[idx] == TILE_TYPE.WALL:
				var facing = -1 # -1 = Invalid
				
				var idx_l = (dy * container_rect.size.x) + (dx - 1)
				if dx - 1 < 0:
					idx_l = -1
					
				var idx_r = (dy * container_rect.size.x) + (dx + 1)
				if dx + 1 >= container_rect.size.x:
					idx_r = -1
					
				var idx_u = ((dy - 1) * container_rect.size.x) + dx
				if dy - 1 < 0:
					idx_u = -1
					
				var idx_d = ((dy + 1) * container_rect.size.x) + dx
				if dy + 1 >= container_rect.size.y:
					idx_d = -1
				
				if idx_l >= 0 and idx_r >= 0 and reg.tiles[idx_l] == TILE_TYPE.WALL and reg.tiles[idx_r] == TILE_TYPE.WALL:
					if idx_u == -1 or reg.tiles[idx_u] == TILE_TYPE.NONE:
						facing = DoorTile.FACING.UP
					elif idx_d == -1 or reg.tiles[idx_d] == TILE_TYPE.NONE:
						facing = DoorTile.FACING.DOWN
					
				
				if facing < 0:
					if idx_u >= 0 and idx_d >= 0 and reg.tiles[idx_u] == TILE_TYPE.WALL and reg.tiles[idx_d] == TILE_TYPE.WALL:
						if idx_l == -1 or reg.tiles[idx_l] == TILE_TYPE.NONE:
							facing = DoorTile.FACING.LEFT
						if idx_r == -1 or reg.tiles[idx_r] == TILE_TYPE.NONE:
							facing = DoorTile.FACING.RIGHT
				
				if facing >= 0:
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
					if facing == DoorTile.FACING.UP or facing == DoorTile.FACING.DOWN:
						reg.tiles[idx_r] = TILE_TYPE.NONE
					elif facing == DoorTile.FACING.LEFT or facing == DoorTile.FACING.RIGHT:
						reg.tiles[idx_u] = TILE_TYPE.NONE
	
	var px = int(player_start_pos.x) - container_rect.position.x
	var py = int(player_start_pos.y) - container_rect.position.y
	if px >= 0 and px < container_rect.size.x and py > 0 and py < container_rect.size.y:
		var pidx = (py * container_rect.size.x) + px
		if reg.tiles[pidx] == TILE_TYPE.FLOOR:
			reg.player_start = Vector2(float(px), float(py))
	
	regions.append(reg)
	if prnt:
		var idx = 0
		for _i in range(0, reg.height):
			print(reg.tiles.slice(idx, idx + (reg.width - 1)))
			idx += reg.width
	
	if living_regions.size() <= 0:
		living_regions.append({
			"offset":Vector2(0, 0),
			"ridx": regions.size() - 1
		})


# ---------------------------------------------------------------------------
# Signal Handler Methods
# ---------------------------------------------------------------------------

func _on_door_open(dx : float, dy: float, ridx : int, didx : int) -> void:
	if living_regions.size() > 1:
		return # We will only ever have 2 regions at most "alive" at once!
	
	var pos = Vector2(dx / tile_size, dy / tile_size)
	var offset = Vector2.ZERO
	if ridx >= 0 and ridx <= regions.size():
		var door_list = regions[ridx].doors
		for door in door_list:
			if door.didx == didx:
				opened_door_info = {
					"x": door.x,
					"y": door.y,
					"facing": door.facing,
					"regdom": 0
				}
				offset.x = (pos.x - door.x)
				offset.y = (pos.y - door.y)
				#print("Pos: ", pos, " | Door Pos: ", Vector2(door.x, door.y), " | Result: ", offset)
				living_regions.append({
					"offset": offset * tile_size,
					"ridx": ridx
				})
				break

func _on_door_closed(exited_through : bool) -> void:
	if living_regions.size() > 1:
		opened_door_info = null
		if exited_through:
			living_regions = [living_regions[1]]
		else:
			living_regions = [living_regions[0]]

