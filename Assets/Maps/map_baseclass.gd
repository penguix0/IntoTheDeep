extends Node2D
class_name MapMaster

signal scroll_start(tl,br)
signal scroll_end(pos)

const _INVALID_ROOM=Vector2(-1,-1)

#do not set these outside the inspector. but if you do update map_screen_size_pixels
export(int) var map_width_screens:=-1   #number of screens per row in our game
export(int) var start_room:=0			#where it all begins

#these are normally set via auto or manual config function
#but you can set room size pixels manually if desired

#these should be pixel size of viewport, usualy set them via auto_configure
#but can be set via manual
var room_size_pixels:=Vector2(-1,-1)
var map_room_size_cells:=Vector2(-1,-1)		#size of each room in cells

#pixel size of each tile/cell. set via _ready normally
#normally will be square, but you never know
var cell_size:=Vector2(0,0)
var scrolling
#this is the 'interface' for all map instances
#refer to sample map for structures required

func _ready() -> void:
	#get scrolling
	
	scrolling=find_node("ScrollingRegions")
	
	#try to set defaults for cell size
	#and if room size is set use this as a starter
	#normally you will call auto configure via room manager with actual viewport
	#to save having to remember to do it here
	#assumes following node structure
	
	for m in get_children():	#nodes within map. should normally be 1
		for n in m.get_children():	#should be tilemaps
			if n is TileMap:
				cell_size=n.cell_size
				return
	print("ERROR. No tilemaps found to set cell size. Default is " + str(cell_size))
	
func auto_configure(viewport_size:Vector2) ->bool:
	map_room_size_cells.x=viewport_size.x/cell_size.x
	map_room_size_cells.y=viewport_size.y/cell_size.y
	room_size_pixels=viewport_size

	if !valid_config():
		return false
		
	if int(viewport_size.x)%int(cell_size.x)!=0 && int(viewport_size.y)%int(cell_size.y)!=0:
		print("Viewport size given %s cannot be divided by cell size of %s" % [viewport_size,cell_size])
		return false
		
	_show_config()
	return true

func manual_config(tile_cell_size:Vector2, room_size_cells:Vector2) ->bool:
	cell_size=tile_cell_size
	map_room_size_cells=room_size_cells
	room_size_pixels=map_room_size_cells*cell_size
	if !valid_config():
		return false

	_show_config()
	return true
	
func get_start_roomid():
	return start_room

### start interface
#these must be implemented by subclasses
func get_room_exits(_room_id:int) ->Array:
	#return array of exits for room
	return []

func get_room_warp_location(_room_id:int) ->Array:
	#return array of positions
	#used if going in a particular direction will reposition player
	#e.g. non-linear room
	return []
	
func is_valid_room(_room_id:int) ->bool:
	#is this room valid
	return false
	
func get_roomid_from_position(_location:Vector2) -> int:
	#return a room id based on a position
	return -1

func get_room_topleft_position(_room_id:int) -> Vector2:
	#return the origin of this room for the camera
	return Vector2.ZERO

func get_room_bottomright_position(_room_id:int) -> Vector2:
	#return the origin of this room for the camera
	return Vector2.ZERO

### end of interface

#### helper functions
func _show_config():
	print("start room given: %s " % [start_room])
	print("cell_size: %s " % [cell_size])
	print("width in rooms given: %s " % [map_width_screens])
	print("room size given: %s " % [room_size_pixels])
	print("room size cells: %s " % [map_room_size_cells])
	return true
	
func valid_config() ->bool:
	if room_size_pixels.x<=0 || room_size_pixels.y<=0:
		print("Invalid map. Pixel size not set")
		return false
		
	if map_width_screens<=0:
		print("Invalid map width in screens")
		return false
		
	if map_room_size_cells.x<=0 || map_room_size_cells.y<=0:
		print("Invalid room size cells")
		return false
		
	if cell_size.x<=0 || cell_size.y<=0:
		print("Invalid cell size set")
		return false
	return true
