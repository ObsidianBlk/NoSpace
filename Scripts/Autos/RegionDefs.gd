extends Node

const ANY_TAG = "__ANY__"

const REGIONS = {
	# -------------------------------------------------
	# Hub Regions
	# -------------------------------------------------
	"HUB_One":{
		"is_hub": true,
		"the_shattered": Vector2(8, 8),
		"floor_color": Color(0.75, 0.75, 0.75),
		"wall_color": Color(0.25, 0.25, 0.25),
		"rect_list":[
			Rect2(3, 3, 10, 10),
			Rect2(2, 4, 12, 8),
			Rect2(1, 5, 14, 6),
			Rect2(0, 6, 16, 4),
			Rect2(4, 2, 8, 12),
			Rect2(5, 1, 6, 14),
			Rect2(6, 0, 4, 16)
		],
		"door_list": [
		{
			"x":0,
			"y":8,
			"facing": DoorTile.FACING.LEFT,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x": 7,
			"y": 0,
			"facing": DoorTile.FACING.UP,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x": 15,
			"y": 8,
			"facing": DoorTile.FACING.RIGHT,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x": 7,
			"y": 15,
			"facing": DoorTile.FACING.DOWN,
			"rname": ANY_TAG,
			"to_didx": -1
		}
		],
		"player_start": Vector2(8, 10)
	},	
	
	# -------------------------------------------------
	# Test Regions
	# -------------------------------------------------
	"Blue_Room":{
		"floor_color": Color(0.25, 0.25, 1.0),
		"wall_color": Color(0.25, 0.75, 1.0),
		"rect_list":[
			Rect2(0, 0, 30, 30),
			Rect2(10, 28, 6, 15)
		],
		"carrots":[
			Vector2(4, 10),
			Vector2(28, 28),
			Vector2(12, 38)
		],
		"door_list": [
		{
			"x":0,
			"y":4,
			"facing": DoorTile.FACING.LEFT,
			"rname": "Green_Room",
			"to_didx": 0
		},
		{
			"x": 10,
			"y": 0,
			"facing": DoorTile.FACING.UP,
			"rname": "Red_Room",
			"to_didx": 1
		},
		{
			"x": 10,
			"y": 34,
			"facing": DoorTile.FACING.LEFT,
			"rname": ANY_TAG,
			"to_didx": -1
		}
		],
		"player_start": Vector2(5, 5)
	},
	
	"Green_Room":{
		"floor_color": Color(0.25, 1.0, 0.25),
		"wall_color": Color(1.0, 0.75, 0.25),
		"rect_list": [
			Rect2(-10, -10, 20, 20),
			Rect2(8, -10, 20, 9),
			Rect2(14, -3, 6, 10)
		],
		"door_list": [{
			"x": 9,
			"y": 0,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "Blue_Room",
			"to_didx": 0
		},
		{
			"x": 14,
			"y": 2,
			"facing": DoorTile.FACING.LEFT,
			"rname": "Red_Room",
			"to_didx": 0
		}
		],
		"player_start": Vector2(5, 5)
	},
	
	"Red_Room": {
		"floor_color": Color(1.0, 0.25, 0.25),
		"wall_color": Color(0.75, 1.0, 0.25),
		"rect_list": [
			Rect2(0, 0, 20, 20)
		],
		"door_list": [{
			"x": 19,
			"y": 5,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "Green_Room",
			"to_didx": 1
		},
		{
			"x": 15,
			"y": 19,
			"facing": DoorTile.FACING.DOWN,
			"rname": "Blue_Room",
			"to_didx": 1
		}
		],
		"player_start": Vector2(5, 5)
	}
}


var reg_list = null
var any_doors = null
var hub_doors = null

func get_random_hub() -> String:
	var keys = REGIONS.keys()
	var avail = []
	for key in keys:
		if _is_region_hub(key):
			avail.append(key)
	if avail.size() > 0:
		var idx = floor(rand_range(0, avail.size()))
		return avail[idx]
	return ""

func get_random_region() -> String:
	var keys = REGIONS.keys()
	var avail = []
	for key in keys:
		if not _is_region_hub(key):
			avail.append(key)
		if avail.size() > 0:
			var idx = floor(rand_range(0, avail.size()))
			return avail[idx]
	return ""

func get_gen_regions() -> Array:
	var rl = []
	if reg_list != null:
		rl = reg_list
		reg_list = null
	return rl

func generate_regions(hub_name : String, start_region : String, depth : int = 4) -> void:
	if _is_region_hub(hub_name):
		reg_list = []
		any_doors = []
		hub_doors = []
		_gen_regions(hub_name, 0)
		_gen_regions(start_region, depth)
		_link_any_doors()

func _gen_regions(rname : String, depth : int = 4) -> int:
	if reg_list == null:
		return -1
	
	var ridx = _get_reg_index_from_name(rname)
	if ridx >= 0:
		return ridx
	ridx = reg_list.size()
	
	if rname in REGIONS:
		var reg = {
			"name": rname,
			"ridx": ridx,
			"the_shattered": null,
			"floor_color": REGIONS[rname].floor_color,
			"wall_color": REGIONS[rname].wall_color,
			"rect_list": [],
			"door_list": [],
			"carrots": [],
			"player_start": REGIONS[rname].player_start
		}
		reg_list.append(reg)
		
		for rect in REGIONS[rname].rect_list:
			reg.rect_list.append(rect)
		
		var carrot_list = REGIONS[rname].get("carrots")
		if carrot_list != null:
			for carrot in carrot_list:
				reg.carrots.append(carrot)

		var the_shattered = REGIONS[rname].get("the_shattered")
		if the_shattered != null:
			reg.the_shattered = the_shattered

		var didx = 0
		for door in REGIONS[rname].door_list:
			var to_ridx = -1
			if depth > 0 and door.rname != ANY_TAG:
				to_ridx = _gen_regions(door.rname, depth - 1)
			var ndoor = {
				"didx": didx,
				"x": door.x,
				"y": door.y,
				"facing": door.facing,
				"to_ridx": to_ridx,
				"to_didx": door.to_didx
			}
			if to_ridx < 0:
				if ridx > 0:
					any_doors.append([rname, ndoor])
				else:
					hub_doors.append([rname, ndoor])
			reg.door_list.append(ndoor)
			didx += 1
	return ridx

func _link_any_doors() -> void:
	var hub_linkback = false
	# Link HUB Doors first... they're most important.
	for hubdoor in hub_doors:
		var adidx = _random_any_door(_opposite_facing(hubdoor[1].facing))
		if adidx >= 0:
			var anydoor = any_doors[adidx]
			hubdoor[1].to_ridx = _get_reg_index_from_name(anydoor[0])
			hubdoor[1].to_didx = anydoor[1].didx
			anydoor[1].to_ridx = 0
			anydoor[1].to_didx = hubdoor[1].didx
			any_doors.remove(adidx)
			hub_linkback = true
		else:
			var link = _random_reg_door(hubdoor[1].facing, hubdoor[0])
			if link != null:
				hubdoor[1].to_ridx = link[0]
				hubdoor[1].to_didx = link[1]

	for anydoor in any_doors:
		var link = _random_reg_door(anydoor[1].facing, anydoor[0])
		if link != null:
			anydoor[1].to_ridx = link[0]
			anydoor[1].to_didx = link[1]
	any_doors = null
	hub_doors = null
	if not hub_linkback:
		print("WARNING: Unable to return to HUB region!")

func _random_any_door(facing : int) -> int:
	for i in range(0, any_doors.size()):
		var anydoor = any_doors[i]
		if anydoor[1].facing == facing:
			return i
	return -1

func _is_region_hub(rname : String) -> bool:
	if rname in REGIONS:
		var hub = REGIONS[rname].get("is_hub")
		return hub == true
	return false

func _get_reg_index_from_name(rname : String) -> int:
	if reg_list != null:
		for i in range(0, reg_list.size()):
			if reg_list[i].name == rname:
				return reg_list[i].ridx
	return -1

func _random_door_idx(ridx : int, facing : int) -> int:
	if reg_list != null:
		if ridx >= 0 and ridx < reg_list.size():
			var reg = reg_list[ridx]
			var avail = []
			for door in reg.door_list:
				if door.facing == facing:
					avail.append(door)
			if avail.size() > 0:
				var idx = floor(rand_range(0, avail.size()))
				return avail[idx].didx
	return -1

func _random_region(ex_name : String) -> int:
	if reg_list != null:
		var idx = floor(rand_range(0, reg_list.size()))
		if reg_list[idx].name != ex_name:
			return int(idx)
	return -1

func _random_reg_door(facing : int, ex_name : String, depth : int = 10):
	var ridx = _random_region(ex_name)
	if ridx < 0:
		if depth > 0:
			return _random_reg_door(facing, ex_name, depth - 1)
		return null
	var didx = _random_door_idx(ridx, _opposite_facing(facing))
	if didx < 0:
		if depth > 0:
			return _random_reg_door(facing, ex_name, depth - 1)
		return null
	return [ridx, didx]

func _opposite_facing(facing : int) -> int:
	match(facing):
		DoorTile.FACING.UP:
			return DoorTile.FACING.DOWN
		DoorTile.FACING.DOWN:
			return DoorTile.FACING.UP
		DoorTile.FACING.LEFT:
			return DoorTile.FACING.RIGHT
		DoorTile.FACING.RIGHT:
			return DoorTile.FACING.LEFT
	return -1


