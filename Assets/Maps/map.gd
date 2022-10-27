extends MapMaster

#map navigation dictionary
#each item is a room number, each item in the exits array is whether can move up,down,left,right with -1 meaning not allowed
#transitions is an array containing 4 arrays for each up,down,left,right direction
#each item contains 2 elements for transition type and duration
#refer to ROOM_TRANSITIONS (but defaults are 0/1/2 none/slide/fade)
#duration not used when 0. The default is what is set in room manager default
#exit_positions structure is same as transitions but contains x/y co-ordinate
#to place player when new room is reached in that direction.
#location is local to the room and default is no change. Typically use for
#warping rooms. this just sends a signal, your game should pick this up
#
#this dictionary in real-world will contain more data, e.g. room enemies, etc
#even though there are room numbers in the array we are simply using -1 for no direction 0+ for a direction
#i.e. we treat -1 as false and any 0+ number as true for navigation allowed
#scrolling camera is achieved via the scrolling camera not here and will
#override anything to do with flip screens like data below
const _ROOM_DATA = {
	#			    u,  d, l, r
	"-1" : {"exits": [-1,-1,-1,-1]},
	"0" : {"exits": [-1,-1,-1,1]},
	"1" : {"exits": [-1,-1,0,2]},
	"2" : {"exits": [-1,-1,1,3]},
	"3" : {"exits": [-1,-1,2,4]},
	"4" : {"exits": [-1,-1,3,5]},
	"5" : {"exits": [-1,-1,4,6]},
	"6" : {"exits": [-1,-1,5,7]},
	"7" : {"exits": [-1,-1,6,8]},
	"8" : {"exits": [-1,-1,7,9]},
	"9" : {"exits": [-1,-1,8,10]},
	"10" : {"exits": [-1,-1,9,11]},
	"11" : {"exits": [-1,-1,10,-1]}
}

func _ready() -> void:
	#parent MapMaster performs auto configuration
	scrolling=find_node("ScrollingRegions")

#map master provides the base functionality
#and should work for grid based 2D maps
#auto_configure:	call this from your game to auto configure everything
#					if you set viewport manually in export then no need
#manual_configure:	call this if not calling auto_configure

#your map below needs to implement the following methods:
#get_room_exits
#get_room_warp_location
#get_room_topleft_position
#get_roomid_from_position
#is_valid_room

func get_room_exits(room_id:int) ->Array:
	if !is_valid_room(room_id):
		#room does not exist
		return _ROOM_DATA["-1"]
		
	#ensure valid rooms
	for r in _ROOM_DATA[str(room_id)]["exits"]:
		if !is_valid_room(r):
			print("ERROR. Room %s has invalid exit room %d. Setting all exits to false" % [room_id,r])
			return [-1,-1,-1,-1]	#don't rely on -1 being there!
	
	return _ROOM_DATA[str(room_id)]["exits"]
	
func get_room_warp_location(room_id:int):
		#do we need to reposition player
		if !is_valid_room(room_id):
			return null
			
		var x=_ROOM_DATA[str(room_id)]
		if x.has("exit_positions"):
			return x["exit_positions"]
			
		return null

func is_valid_room(room_id:int) ->bool:
	return _ROOM_DATA.has(str(room_id))
	
func get_room_transition(room_id:int) -> Array:
		#is there a transition
		if !is_valid_room(room_id):
			return [-1,-1,-1,-1]
			
		var x=_ROOM_DATA[str(room_id)]
		if x.has("transitions"):
			return x["transitions"]
			
		return [-1,-1,-1,-1]
			
func get_roomid_from_position(location:Vector2) -> int:
	#from a global pixel location get the room id
	if !valid_config():
		return -1
	var screen_x = int(location.x / room_size_pixels.x)
	var screen_y = int(location.y / room_size_pixels.y)
	var room_id = (screen_y * map_width_screens) + screen_x
	return room_id

func get_room_topleft_position(room_id:int) -> Vector2:
	#for a given room return the top left position as a pixel co-ordinate
	#this is to get the top left position of the room to position the camera
	if !valid_config():
		return _INVALID_ROOM
		
	var x=(room_id%map_width_screens)*room_size_pixels.x
	var y=int(room_id/map_width_screens)*room_size_pixels.y
	return Vector2(x,y)

func get_room_bottomright_position(room_id:int) -> Vector2:
	#for a given room return the top left position as a pixel co-ordinate
	#this is to get the top left position of the room to position the camera
	if !valid_config():
		return _INVALID_ROOM
		
	return get_room_topleft_position(room_id)+room_size_pixels
	

func _on_ScrollingRegions_body_exited(body: Node) -> void:
	#inform game/room manager to turn to flip mode
	#game needs to be setup so that the areas and camera limits
	#ensure room exits/scroll position are in place
	#otherwise camera will jump. to avoid this
	#e.g. how Metroid does this, then add a tween
	emit_signal("scroll_end", body.global_position)


func _on_ScrollingRegions_body_shape_entered(_body_id: RID, _body: Node, _body_shape: int, local_shape: int) -> void:
	#inform game/room manager to turn to scrolling mode
	#as scrolling exit signal, presumes correct position is set
	#we pass in the topleft and bottom right of the screens covered
	#by the shape, not the shape, this way the camera will correct
	#itself, as above may need a tween if you do things wrong
	#e.g. room is exited when the camera has not scrolled fully
	
	#get area of shape being entered (i.e. the scroll area)
	if scrolling==null:
		return
		
	var poly=scrolling.get_child(local_shape)
	var shape_size=poly.shape.extents

	#get the position of this shape
	var tl=Vector2(poly.global_position.x-shape_size.x,poly.global_position.y-shape_size.y)
	var br=Vector2(poly.global_position.x+shape_size.x,poly.global_position.y+shape_size.y)
	
	#convert this position to room and get room coordinates
	var st=get_roomid_from_position(tl)
	var se=get_roomid_from_position(br)
	var atl=get_room_topleft_position(st)
	var abr=get_room_bottomright_position(se)
	
	#let game/room manger know we have started scrolling
	emit_signal("scroll_start",atl,abr)

