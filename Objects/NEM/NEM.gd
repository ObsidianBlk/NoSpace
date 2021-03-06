tool
extends Node2D

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

signal region_change(rname)
signal life_time_change(v, vmax)
signal completed
signal oot

# ---------------------------------------------------------------------------
# ENUM Definitions
# ---------------------------------------------------------------------------
enum TILE_TYPE {NONE = 0, FLOOR = 1, WALL = 2, DOOR = 3}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------
var tile_resource = preload("res://Objects/NEM/PulseTile.tscn")
var door_resource = preload("res://Objects/NEM/DoorTile.tscn")
var carrot_resource = preload("res://Objects/Carrot/Carrot.tscn")
var shattered_resource = preload("res://Objects/TheShattered/TheShattered.tscn")
var part_resource = preload("res://Objects/TheShattered/Part/Part.tscn")
var tile_size = 32

var player_node = null
var camera_node = null
var regions = []

var living_regions = []
var living_tiles = {}
var the_shattered_node = null
var part_node = null

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
func _activate_living_region(ridx: int, offset : Vector2) -> void:
	if living_regions.size() < 2:
		living_regions.append({
			"offset": offset,
			"ridx": ridx
		})
		if regions[ridx].the_shattered != null:
			the_shattered_node.position = (regions[ridx].the_shattered * tile_size) + offset

func _drop_living_region(keep_lridx : int) -> void:
	if living_regions.size() >= 2:
		living_regions = [living_regions[keep_lridx]]

func _random_living_region(pos : Vector2) -> void:
	if living_regions.size() > 1:
		_drop_living_region(0)
	var ridx = living_regions[0].ridx
	var avail = []
	for i in range(0, regions.size()):
		if i != ridx:
			avail.append(i)
	var nridx = avail[floor(rand_range(0, avail.size()))]
	var offset = pos - (regions[nridx].player_start * tile_size)
	living_regions = []
	_activate_living_region(nridx, offset)

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
	
	# "The Shattered" is a special item... use this special method to handle it's visibility...
	_update_the_shattered()
	_update_part()
			
	for key in dkeys:
		if living_tiles[key].tile is DoorTile:
			living_tiles[key].tile.disconnect("door_opened", self, "_on_door_opened")
			living_tiles[key].tile.disconnect("door_closed", self, "_on_door_closed")
		living_tiles[key].tile.kill()
		if living_tiles[key].carrot != null:
			living_tiles[key].carrot.kill()
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
				
				if tiles[idx].type == TILE_TYPE.NONE and tb[idx].type != TILE_TYPE.NONE:
					tiles[idx] = tb[idx]
	return tiles

func _build_from_tiles(tiles : Array) -> void:
	if tiles.size() > 0:
		var px = int(player_node.position.x) % int(tile_size)
		var py = int(player_node.position.y) % int(tile_size)
		var rad = floor(player_node.sight / tile_size)
		var start = Vector2(px - rad, py - rad)

		for idx in range(0, tiles.size()):
			var ridx = tiles[idx].ridx
			var ttype = tiles[idx].type
			var tpos = tiles[idx].position * tile_size
			var tidx = tiles[idx].tidx
			var carrot_idx = tiles[idx].carrot_idx
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
				var carrot = null
				
				if ttype == TILE_TYPE.DOOR:
					var dinfo = _get_door_info(ridx, tidx)
					if dinfo != null:
						tn = door_resource.instance()
						tn.facing = dinfo.facing
						if dinfo.to_ridx >= 0 and dinfo.to_didx >= 0:
							tn.ridx = dinfo.to_ridx
							tn.didx = dinfo.to_didx
						else:
							tn.locked = true
						tn.color = regions[ridx].wall_color
						tn.connect("door_opened", self, "_on_door_open")
						tn.connect("door_closed", self, "_on_door_closed")
					else:
						ttype = TILE_TYPE.WALL
				
				if ttype == TILE_TYPE.FLOOR:
					tn = tile_resource.instance()
					tn.color = regions[ridx].floor_color
					if carrot_idx >= 0:
						carrot = carrot_resource.instance()
						carrot.position = tpos
						carrot.ridx = ridx
						carrot.idx = carrot_idx
						carrot.connect("carrot_picked_up", self, "_on_carrot_pickup")
						ents_node.add_child(carrot)
				elif ttype == TILE_TYPE.WALL:
					tn = tile_resource.instance()
					tn.color = regions[ridx].wall_color
					tn.collision_enabled = true
					tn.base_intensity = 1.0
				
				if tn != null:
					floors_node.add_child(tn)
					tn.position = tpos
					living_tiles[key] = {"ridx":ridx, "tile":tn, "type": ttype, "carrot":carrot}


func _get_door_info(ridx : int, tidx : int):
	var door_list = regions[ridx].doors
	for door in door_list:
		if door.tidx == tidx:
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
	#var treg = false
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
		#if living_regions[1].ridx == 2:
			#treg = true
			#print("Facing: ", regions[1].doors[1].facing)
			#print("Pos", pos, " | Inc Region: ", inc_region, "Facing: ", opened_door_info.facing)
	
	for y in range(start.y - trad, start.y + trad):
		for x in range(start.x - trad, start.x + trad):
			var tval = TILE_TYPE.NONE
			var tpos = Vector2(x - offset.x, y - offset.y)
			var tidx = (tpos.y * reg_size.x) + tpos.x
			var carrot_idx = -1
			if tpos.x >= 0 and tpos.x < reg_size.x and tpos.y >= 0 and tpos.y < reg_size.y:
				var dist = Vector2(x, y).distance_to(start)
				
				if dist < trad and inc_region.has_point(Vector2(x, y)):
					tval = reg.tiles[tidx]
					for i in range(0, reg.carrots.size()):
						if not reg.carrots[i].eaten and reg.carrots[i].position == tpos:
							carrot_idx = i
			#tiles.append([living_regions[lridx].ridx, tval, tpos + offset, tidx])
			tiles.append({
				"ridx": living_regions[lridx].ridx,
				"type": tval,
				"position": tpos + offset,
				"tidx": tidx,
				"carrot_idx": carrot_idx
			})
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

func _update_the_shattered() -> void:
	if the_shattered_node == null or the_shattered_node.ridx < 0:
		return
		
	for lr in living_regions:
		if lr.ridx == the_shattered_node.ridx:
			if player_node.can_see_node(the_shattered_node):
				the_shattered_node.visible = true
				var dist = player_node.position.distance_to(the_shattered_node.position)
				the_shattered_node.alpha = 1.0 - (dist / player_node.sight)
				return
	the_shattered_node.visible = false

func _update_part() -> void:
	if part_node != null:
		if player_node.can_see_node(part_node):
			var dist = player_node.position.distance_to(part_node.position)
			part_node.alpha = 1.0 - (dist / player_node.sight)
		else:
			part_node.alpha = 0.0
# ---------------------------------------------------------------------------
# NODE Override Methods
# ---------------------------------------------------------------------------
func _ready():
	randomize()
	#rand_seed(OS.get_unix_time())


func _physics_process(delta : float) -> void:
	_update_living_tiles()

# ---------------------------------------------------------------------------
# "Public" Methods"
# ---------------------------------------------------------------------------
func running() -> bool:
	return regions.size() > 0 and living_regions.size() > 0 and player_node != null

func clear_map() -> void:
	living_regions = []
	_clear_living_tiles()
	if the_shattered_node:
		the_shattered_node.kill()
		the_shattered_node = null
	if part_node:
		part_node.kill()
		part_node = null
	regions = []
	opened_door_info = null


func detach_player_to_container(container : Node2D) -> void:
	if player_node != null:
		player_node.disconnect("teleport", self, "_on_teleport")
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
		player_node.connect("teleport", self, "_on_teleport")
		
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


func add_region(data, prnt : bool = false) -> void:
	var reg = {
		"name": data.name,
		"floor_color": data.floor_color,
		"wall_color": data.wall_color,
		"width": 0,
		"height": 0,
		"player_start": null,
		"the_shattered": null,
		"carrots": [],
		"doors": [],
		"tiles":null
	}
	
	var container_rect = Rect2(0, 0, 0, 0)
	for rect in data.rect_list:
		container_rect = container_rect.merge(rect)
	reg.width = container_rect.size.x
	reg.height = container_rect.size.y
	

	# TODO ... Why can't I do the below three lines with a PoolByteArray?!?!?!
	reg.tiles = []
	for _i in range(0, container_rect.size.x * container_rect.size.y):
		reg.tiles.append(TILE_TYPE.NONE)
	
	for rect in data.rect_list:
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
	
	for didx in range(0, data.door_list.size()):
		var door = data.door_list[didx]
		var dx = door.x - container_rect.position.x
		var dy = door.y - container_rect.position.y
		if dx >= 0 and dx < container_rect.size.x and dy >= 0 and dy < container_rect.size.y:
			var idx = (dy * container_rect.size.x) + dx
			if reg.tiles[idx] == TILE_TYPE.WALL:
				#var facing = -1 # -1 = Invalid
				
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
				
#				if idx_l >= 0 and idx_r >= 0 and reg.tiles[idx_l] == TILE_TYPE.WALL and reg.tiles[idx_r] == TILE_TYPE.WALL:
#					if idx_u == -1 or reg.tiles[idx_u] == TILE_TYPE.NONE:
#						facing = DoorTile.FACING.UP
#					elif idx_d == -1 or reg.tiles[idx_d] == TILE_TYPE.NONE:
#						facing = DoorTile.FACING.DOWN
#
#
#				if facing < 0:
#					if idx_u >= 0 and idx_d >= 0 and reg.tiles[idx_u] == TILE_TYPE.WALL and reg.tiles[idx_d] == TILE_TYPE.WALL:
#						if idx_l == -1 or reg.tiles[idx_l] == TILE_TYPE.NONE:
#							facing = DoorTile.FACING.LEFT
#						if idx_r == -1 or reg.tiles[idx_r] == TILE_TYPE.NONE:
#							facing = DoorTile.FACING.RIGHT
				
				if door.facing >= 0:
					reg.doors.append({
						"tidx": idx,
						"didx": didx,
						"x":dx,
						"y":dy,
						"facing": door.facing,
						"to_ridx":door.to_ridx,
						"to_didx":door.to_didx
					})
					reg.tiles[idx] = TILE_TYPE.DOOR
					if door.facing == DoorTile.FACING.UP or door.facing == DoorTile.FACING.DOWN:
						reg.tiles[idx_r] = TILE_TYPE.NONE
					elif door.facing == DoorTile.FACING.LEFT or door.facing == DoorTile.FACING.RIGHT:
						reg.tiles[idx_u] = TILE_TYPE.NONE
	
	var px = int(data.player_start.x) - container_rect.position.x
	var py = int(data.player_start.y) - container_rect.position.y
	if px >= 0 and px < container_rect.size.x and py > 0 and py < container_rect.size.y:
		var pidx = (py * container_rect.size.x) + px
		if reg.tiles[pidx] == TILE_TYPE.FLOOR:
			reg.player_start = Vector2(float(px), float(py))
	
	var carrots = data.get("carrots")
	if carrots != null:
		for carrot in carrots:
			carrot = carrot - container_rect.position
			if Rect2(Vector2.ZERO, container_rect.size).has_point(carrot):
				var idx = (carrot.y * container_rect.size.x) + carrot.x
				if reg.tiles[idx] == TILE_TYPE.FLOOR:
					reg.carrots.append({
						"eaten": false,
						"position": carrot,
						"entity": null
					})
	
	if data.the_shattered != null and the_shattered_node == null:
		var tspos = data.the_shattered - container_rect.position
		the_shattered_node = shattered_resource.instance()
		the_shattered_node.ridx = regions.size()
		the_shattered_node.alpha = 0.0
		the_shattered_node.visible = false
		the_shattered_node.connect("spawn_part", self, "_on_spawn_part")
		the_shattered_node.connect("life_time_change", self, "_on_life_time_change")
		the_shattered_node.connect("completed", self, "_on_completed")
		the_shattered_node.connect("oot", self, "_on_oot")
		ents_node.add_child(the_shattered_node)
		reg.the_shattered = tspos
	
	regions.append(reg)
	if prnt:
		var idx = 0
		for _i in range(0, reg.height):
			print(reg.tiles.slice(idx, idx + (reg.width - 1)))
			idx += reg.width
	
	if living_regions.size() <= 0:
		_activate_living_region(regions.size() - 1, Vector2(0, 0))
		#living_regions.append({
		#	"offset":Vector2(0, 0),
		#	"ridx": regions.size() - 1
		#})
		emit_signal("region_change", regions[living_regions[0].ridx].name)


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
		var foundDoor = false
		for door in door_list:
			if door.didx == didx:
				foundDoor = true
				opened_door_info = {
					"x": door.x,
					"y": door.y,
					"facing": door.facing,
					"regdom": 0
				}
				offset.x = (pos.x - door.x)
				offset.y = (pos.y - door.y)
				_activate_living_region(ridx, offset * tile_size)
				break
		if not foundDoor:
			print("Failed to find door to Region: ", regions[ridx].name, " | DIDX: ", didx)

func _on_door_closed(exited_through : bool) -> void:
	if living_regions.size() > 1:
		opened_door_info = null
		if exited_through:
			_drop_living_region(1)
		else:
			_drop_living_region(0)
		emit_signal("region_change", regions[living_regions[0].ridx].name)

func _on_teleport(to : Vector2) -> void:
	var pos = Vector2(
		floor((player_node.position.x / tile_size) + to.x),
		floor((player_node.position.y / tile_size) + to.y)
	) * tile_size
	var key = String(int(pos.x)) + "x" + String(int(pos.y))
	if key in living_tiles:
		if living_tiles[key].type == TILE_TYPE.FLOOR:
			player_node.position = pos
	else:
		player_node.position = pos
		_random_living_region(player_node.position)

func _on_carrot_pickup(ridx, cidx) -> void:
	if ridx >= 0 and ridx < regions.size():
		if cidx >= 0 and cidx < regions[ridx].carrots.size():
			regions[ridx].carrots[cidx].eaten = true

func _on_part_picked_up() -> void:
	if part_node != null:
		part_node.kill()
		part_node = null

func _on_spawn_part(id : int) -> void:
	if part_node == null:
		var angle = deg2rad(rand_range(0, 360))
		var pos = Vector2(0, floor(rand_range(100, 200)) * tile_size).rotated(angle)
		part_node = part_resource.instance()
		part_node.id = id
		part_node.connect("part_picked_up", self, "_on_part_picked_up")
		ents_node.add_child(part_node)
		part_node.target_path = player_node.get_path()
		part_node.position = player_node.position + pos

func _on_life_time_change(v : float, vmax : float) -> void:
	emit_signal("life_time_change", v, vmax)

func _on_completed() -> void:
	emit_signal("completed")

func _on_oot() -> void:
	emit_signal("oot")

