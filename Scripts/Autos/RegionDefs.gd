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
	# Main Game Regions
	# -------------------------------------------------
	"_ZetGret_":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(0, 0, 6, 3),
			Rect2(3, 0, 3, 6),
			Rect2(3, 3, 9, 3),
			Rect2(9, 0, 3, 6),
			Rect2(6, 3, 3, 9),
			Rect2(11, 3, 5, 3),
			Rect2(11, 3, 3, 7),
			Rect2(0, 7, 13, 3),
			Rect2(3, 11, 9, 5),
		],
		"carrots":[
			Vector2(5, 13),
			Vector2(9, 13)
		],
		"door_list": [
		{
			"x":0,
			"y":1,
			"facing": DoorTile.FACING.LEFT,
			"rname": "N1lb0x__",
			"to_didx": 2
		},
		{
			"x": 10,
			"y": 0,
			"facing": DoorTile.FACING.UP,
			"rname": "_PI.11",
			"to_didx": 3
		},
		{
			"x": 15,
			"y": 4,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "#R0ozm$",
			"to_didx": 2
		},
		{
			"x": 5,
			"y": 15,
			"facing": DoorTile.FACING.DOWN,
			"rname": ".T33_",
			"to_didx": 0
		},
		{
			"x": 9,
			"y": 15,
			"facing": DoorTile.FACING.DOWN,
			"rname": "C1.0z3t",
			"to_didx": 1
		},
		{
			"x": 0,
			"y": 8,
			"facing": DoorTile.FACING.LEFT,
			"rname": ANY_TAG, # Actually a REAL ANY!
			"to_didx": -1
		},
		{
			"x": 9,
			"y": 11,
			"facing": DoorTile.FACING.UP,
			"rname": ANY_TAG, # Actually a REAL ANY!
			"to_didx": -1
		}
		],
		"player_start": Vector2(7, 13)
	},
	
	"N1lb0x__":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(2, 0, 3, 12),
			Rect2(2, 0, 13, 3),
			Rect2(2, 4, 13, 3),
			Rect2(2, 9, 13, 3),
			Rect2(6, 0, 4, 16),
			Rect2(11, 0, 4, 12),
			Rect2(0, 3, 4, 3),
			Rect2(6, 13, 10, 3),
		],
		"carrots":[
			Vector2(3, 2),
			Vector2(12, 7)
		],
		"door_list": [
		{
			"x":0,
			"y":4,
			"facing": DoorTile.FACING.LEFT,
			"rname": "F1.zh_",
			"to_didx": 2
		},
		{
			"x":2,
			"y":9,
			"facing": DoorTile.FACING.LEFT,
			"rname": "_PI.11",
			"to_didx": 5
		},
		{
			"x":14,
			"y":2,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "_ZetGret_",
			"to_didx": 0
		},
		{
			"x":15,
			"y":14,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "_10ng.",
			"to_didx": 0
		},
		# Actual Any Doors...
		{
			"x":5,
			"y":2,
			"facing": DoorTile.FACING.DOWN,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":9,
			"y":3,
			"facing": DoorTile.FACING.RIGHT,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":6,
			"y":8,
			"facing": DoorTile.FACING.LEFT,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":10,
			"y":9,
			"facing": DoorTile.FACING.UP,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		],
		"player_start": Vector2(7, 2)
	},
	
	"#R0ozm$":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(5, 0, 5, 16),
			Rect2(0, 2, 6, 5),
			Rect2(0, 6, 6, 5),
			Rect2(0, 10, 6, 5),
			Rect2(9, 2, 7, 5),
			Rect2(9, 6, 7, 5),
			Rect2(9, 10, 7, 5),
			Rect2(4, 4, 7, 3),
			Rect2(4, 8, 7, 3),
			Rect2(4, 12, 7, 3),
		],
		"carrots":[
			Vector2(2, 4),
			Vector2(4, 7),
			Vector2(14, 3),
			Vector2(10, 11),
		],
		"door_list": [
		{
			"x":7,
			"y":0,
			"facing": DoorTile.FACING.UP,
			"rname": "_PI.11",
			"to_didx": 2
		},
		{
			"x":7,
			"y":15,
			"facing": DoorTile.FACING.DOWN,
			"rname": "F1.zh_",
			"to_didx": 0
		},
		{
			"x":0,
			"y":4,
			"facing": DoorTile.FACING.LEFT,
			"rname": "_ZetGret_",
			"to_didx": 2
		},
		{
			"x":0,
			"y":12,
			"facing": DoorTile.FACING.LEFT,
			"rname": "Z3d-Er0",
			"to_didx": 0
		},
		{
			"x":15,
			"y":8,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "C1.0z3t",
			"to_didx": 4
		},
		
		# Actual ANY Doors!!!
		{
			"x":0,
			"y":8,
			"facing": DoorTile.FACING.LEFT,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":15,
			"y":4,
			"facing": DoorTile.FACING.RIGHT,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":15,
			"y":12,
			"facing": DoorTile.FACING.RIGHT,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		],
		"player_start": Vector2(12, 8)
	},
	
	"_PI.11":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(3, 0, 10, 9),
			Rect2(2, 1, 12, 7),
			Rect2(1, 2, 14, 5),
			Rect2(0, 3, 16, 3),
		],
		"carrots":[
			Vector2(4, 4),
			Vector2(7, 4),
			Vector2(10, 4),
		],
		"door_list": [
		{
			"x":5,
			"y":0,
			"facing": DoorTile.FACING.UP,
			"rname": "F1.zh_",
			"to_didx": 3
		},
		{
			"x":10,
			"y":0,
			"facing": DoorTile.FACING.UP,
			"rname": "T41L",
			"to_didx": 1
		},
		{
			"x":5,
			"y":8,
			"facing": DoorTile.FACING.DOWN,
			"rname": "#R0ozm$",
			"to_didx": 0
		},
		{
			"x":10,
			"y":8,
			"facing": DoorTile.FACING.DOWN,
			"rname": "_ZetGret_",
			"to_didx": 1
		},
		{
			"x":0,
			"y":4,
			"facing": DoorTile.FACING.LEFT,
			"rname": "_10ng.",
			"to_didx": 1
		},
		{
			"x":15,
			"y":4,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "N1lb0x__",
			"to_didx": 1
		},
		],
		"player_start": Vector2(7, 2)
	},
	
	"Z3d-Er0":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(0, 0, 5, 16),
			Rect2(11, 0, 5, 16),
			Rect2(3, 0, 10, 3),
			Rect2(3, 13, 10, 3),
		],
		"carrots":[
			Vector2(2, 5),
			Vector2(13, 4),
			Vector2(13, 11),
		],
		"door_list": [
		{
			"x":4,
			"y":8,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "#R0ozm$",
			"to_didx": 3
		},
		{
			"x":11,
			"y":8,
			"facing": DoorTile.FACING.LEFT,
			"rname": "T41L",
			"to_didx": 3
		},
		{
			"x":8,
			"y":2,
			"facing": DoorTile.FACING.DOWN,
			"rname": "_10ng.",
			"to_didx": 2
		},
		{
			"x":7,
			"y":13,
			"facing": DoorTile.FACING.UP,
			"rname": "C1.0z3t",
			"to_didx": 3
		},
		
		],
		"player_start": Vector2(2, 2)
	},
	
	".T33_":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(5, 0, 5, 16),
			Rect2(0, 6, 16, 5),
		],
		"carrots":[
			Vector2(6, 8),
			Vector2(8, 8),
			Vector2(7, 7),
			Vector2(7, 9),
		],
		"door_list": [
		{
			"x":7,
			"y":0,
			"facing": DoorTile.FACING.UP,
			"rname": "_ZetGret_",
			"to_didx": 3
		},
		{
			"x":7,
			"y":15,
			"facing": DoorTile.FACING.DOWN,
			"rname": "T41L",
			"to_didx": 0
		},
		{
			"x":0,
			"y":8,
			"facing": DoorTile.FACING.LEFT,
			"rname": "C1.0z3t",
			"to_didx": 2
		},
		{
			"x":15,
			"y":8,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "F1.zh_",
			"to_didx": 1
		},
		
		# Actual ANY Doors!! ...
		{
			"x":3,
			"y":6,
			"facing": DoorTile.FACING.UP,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":11,
			"y":6,
			"facing": DoorTile.FACING.UP,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":3,
			"y":10,
			"facing": DoorTile.FACING.DOWN,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":11,
			"y":10,
			"facing": DoorTile.FACING.DOWN,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		],
		"player_start": Vector2(7, 13)
	},
	
	"F1.zh_":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(0, 0, 5, 6),
			Rect2(3, 3, 4, 3),
			Rect2(2, 4, 3, 5),
		],
		"carrots":[
			Vector2(2, 4),
		],
		"door_list": [
		{
			"x":2,
			"y":0,
			"facing": DoorTile.FACING.UP,
			"rname": "#R0ozm$",
			"to_didx": 1
		},
		{
			"x":0,
			"y":3,
			"facing": DoorTile.FACING.LEFT,
			"rname": ".T33_",
			"to_didx": 3
		},
		{
			"x":6,
			"y":4,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "N1lb0x__",
			"to_didx": 0
		},
		{
			"x":3,
			"y":8,
			"facing": DoorTile.FACING.DOWN,
			"rname": "_PI.11",
			"to_didx": 0
		},
		],
		"player_start": Vector2(2, 2)
	},
	
	"C1.Oz3t":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(0, 0, 6, 6),
		],
		"carrots":[
			Vector2(1, 1),
		],
		"door_list": [
		{
			"x":0,
			"y":2,
			"facing": DoorTile.FACING.LEFT,
			"rname": "#R0ozm$",
			"to_didx": 4
		},
		{
			"x":2,
			"y":0,
			"facing": DoorTile.FACING.UP,
			"rname": "_ZetGret_",
			"to_didx": 4
		},
		{
			"x":5,
			"y":3,
			"facing": DoorTile.FACING.RIGHT,
			"rname": ".T33_",
			"to_didx": 2
		},
		{
			"x":3,
			"y":5,
			"facing": DoorTile.FACING.DOWN,
			"rname": "Z3d-Er0",
			"to_didx": 3
		},
		
		],
		"player_start": Vector2(3, 3)
	},
	
	"_10ng.":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(0, 0, 16, 5),
		],
		"carrots":[
			Vector2(5, 2),
			Vector2(12, 2),
		],
		"door_list": [
		{
			"x":0,
			"y":2,
			"facing": DoorTile.FACING.LEFT,
			"rname": "N1lb0x__",
			"to_didx": 3
		},
		{
			"x":15,
			"y":2,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "_PI.11",
			"to_didx": 4
		},
		{
			"x":7,
			"y":0,
			"facing": DoorTile.FACING.UP,
			"rname": "Z3d-Er0",
			"to_didx": 2
		},
		{
			"x":7,
			"y":4,
			"facing": DoorTile.FACING.DOWN,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		
		],
		"player_start": Vector2(2, 2)
	},
	
	"T41L":{
		"floor_color": Color(0.5, 0.7, 0.7),
		"wall_color": Color(0.7, 0.7, 0.7),
		"rect_list":[
			Rect2(0, 0, 5, 16),
		],
		"carrots":[
			Vector2(2, 3),
			Vector2(2, 10)
		],
		"door_list": [
		{
			"x":2,
			"y":0,
			"facing": DoorTile.FACING.UP,
			"rname": ".T33_",
			"to_didx": 1
		},
		{
			"x":2,
			"y":15,
			"facing": DoorTile.FACING.DOWN,
			"rname": "_PI.11",
			"to_didx": 1
		},
		{
			"x":0,
			"y":7,
			"facing": DoorTile.FACING.LEFT,
			"rname": ANY_TAG,
			"to_didx": -1
		},
		{
			"x":4,
			"y":7,
			"facing": DoorTile.FACING.RIGHT,
			"rname": "Z3d-Er0",
			"to_didx": 1
		},
		
		],
		"player_start": Vector2(2, 13)
	},
	# -------------------------------------------------
	# Test Regions
	# -------------------------------------------------
#	"Blue_Room":{
#		"floor_color": Color(0.25, 0.25, 1.0),
#		"wall_color": Color(0.25, 0.75, 1.0),
#		"rect_list":[
#			Rect2(0, 0, 30, 30),
#			Rect2(10, 28, 6, 15)
#		],
#		"carrots":[
#			Vector2(4, 10),
#			Vector2(28, 28),
#			Vector2(12, 38)
#		],
#		"door_list": [
#		{
#			"x":0,
#			"y":4,
#			"facing": DoorTile.FACING.LEFT,
#			"rname": "Green_Room",
#			"to_didx": 0
#		},
#		{
#			"x": 10,
#			"y": 0,
#			"facing": DoorTile.FACING.UP,
#			"rname": "Red_Room",
#			"to_didx": 1
#		},
#		{
#			"x": 10,
#			"y": 34,
#			"facing": DoorTile.FACING.LEFT,
#			"rname": ANY_TAG,
#			"to_didx": -1
#		}
#		],
#		"player_start": Vector2(5, 5)
#	},
#
#	"Green_Room":{
#		"floor_color": Color(0.25, 1.0, 0.25),
#		"wall_color": Color(1.0, 0.75, 0.25),
#		"rect_list": [
#			Rect2(-10, -10, 20, 20),
#			Rect2(8, -10, 20, 9),
#			Rect2(14, -3, 6, 10)
#		],
#		"door_list": [{
#			"x": 9,
#			"y": 0,
#			"facing": DoorTile.FACING.RIGHT,
#			"rname": "Blue_Room",
#			"to_didx": 0
#		},
#		{
#			"x": 14,
#			"y": 2,
#			"facing": DoorTile.FACING.LEFT,
#			"rname": "Red_Room",
#			"to_didx": 0
#		}
#		],
#		"player_start": Vector2(5, 5)
#	},
#
#	"Red_Room": {
#		"floor_color": Color(1.0, 0.25, 0.25),
#		"wall_color": Color(0.75, 1.0, 0.25),
#		"rect_list": [
#			Rect2(0, 0, 20, 20)
#		],
#		"door_list": [{
#			"x": 19,
#			"y": 5,
#			"facing": DoorTile.FACING.RIGHT,
#			"rname": "Green_Room",
#			"to_didx": 1
#		},
#		{
#			"x": 15,
#			"y": 19,
#			"facing": DoorTile.FACING.DOWN,
#			"rname": "Blue_Room",
#			"to_didx": 1
#		}
#		],
#		"player_start": Vector2(5, 5)
#	}
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
		#print("Found RIDX (", ridx, ") for region '", rname, "'")
		return ridx
	
	if rname in REGIONS:
		ridx = reg_list.size()
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
			if door.rname != ANY_TAG:
				if depth > 0:
					if rname == "_PI.11" and door.rname == "T41L":
						print("Connecting")
					to_ridx = _gen_regions(door.rname, depth - 1)
				else:
					if rname == "_PI.11" and door.rname == "T41L":
						print("Searching")
					to_ridx = _get_reg_index_from_name(door.rname)
				print(rname, "(", ridx, ") -> ", door.rname, "(", to_ridx, ")")
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
					if rname == "_PI.11":
						print("Storing Any Door")
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
			var ridx = _get_reg_index_from_name(anydoor[0])
			hubdoor[1].to_ridx = ridx
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


