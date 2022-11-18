extends Node
#Godot 2D Flipscreen Template V1.3.0
#for getting started with the template
#Visit https://gitlab.com/chucklepie-productions/flipscreen-template
#
#For the tutorial in how the template was made
#https://gitlab.com/chucklepie-productions/tutorials/flipscreen-camera
#
#For youtube 
#https://www.youtube.com/playlist?list=PLtc9v8wsy_BY8l7ViNJamL6ao1SKABM5T
#

#room exit takes player to a new position in the new room
signal map_reposition_player(new_global_position)

const INVALID_ROOM=Vector2(-1,-1)
enum ROOM_TRANSITION {NONE,SLIDE,FADE}
onready var tween=$TransitionTween
onready var rect=$CanvasLayer/ColorRect
export(int,"None","Slide","Fade") var default_transition=ROOM_TRANSITION.NONE
export(float) var default_transition_time=0.5

var _current_room:int
var _camera_controller:Camera2D
var _camera_scrolling:Camera2D
var _map_controller:Node2D
var _room_valid:=false
var _is_scrolling:=false

var debug_mode:=true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(_event: InputEvent) -> void:
	#this is for debugging only
	if !debug_mode:
		return
		
	var direction=Vector2.ZERO
#	if Input.is_action_just_pressed("debug_screen_down"):
#		direction=Vector2.DOWN
#	if Input.is_action_just_pressed("debug_screen_up"):
#		direction=Vector2.UP
#	if Input.is_action_just_pressed("debug_screen_left"):
#		direction=Vector2.LEFT
#	if Input.is_action_just_pressed("debug_screen_right"):
#		direction=Vector2.RIGHT

	if direction!=Vector2.ZERO:
		manage_direction(direction)
	

func setup_rooms(camera:Camera2D, scrolling_camera:Camera2D, map:MapMaster,viewport_size:Vector2=Vector2.ZERO) ->bool:
	#room manager requires camera and map
	#if specify viewport size then it and camera will be automatically sized
	#otherwise you need to call manual_configure and set_navigation_system
	var success:=true
	if camera==null || map==null:
		_room_valid=false
		return false

	_camera_controller=camera
	_camera_scrolling=scrolling_camera
	_map_controller=map
	_current_room=map.get_start_roomid()
	
	#auto size map and camera
	if viewport_size!=null && viewport_size!=Vector2.ZERO:
		print("Auto configure being called by room manager")
		success=map.auto_configure(viewport_size)
		camera.set_navigation_system(viewport_size, _camera_controller.room_navigation_pixel_offset)
	else:
		print("Auto configure NOT called, ensure manual_configure is called")
	_room_valid=success
	return success
	
func manage_direction(direction:Vector2, transition_override=-1, transition_length_override:float=-1.0) -> void:
	if _is_scrolling:
		return
		
	#transition -1 will use whatever is set in room data or default
	#caller wants to change room to a specific direction
	if !_validate():
		return
		
	#get the new room, the methods will handle invalid values just fine
	#index: 0 room, 1 transition, 2 transition duration, 3/4 location override
	var newroom=get_valid_room_in_direction_from_room(_current_room,direction)
	if newroom[0]==-1:
		return
		
	#do we have a room_data room transition
	if transition_override==-1:
		transition_override=newroom[1]
		
	if transition_length_override==-1.0:
		transition_length_override=newroom[2]
		
	#we have a new room, simply set it, mark input as handled then 
	#ask the camera nicely to change room
	_current_room=newroom[0]
	get_tree().set_input_as_handled()
	change_room(-1,transition_override,transition_length_override)
	
	if newroom[3]>=0 && newroom[4]>=0:
		#this new room in this direction requires player to change position
		#convert to global position
		var local=Vector2(newroom[3],newroom[4])
		var start=get_room_topleft_global(_current_room)
		var newpos=start+local
		emit_signal("map_reposition_player",newpos)
	
func change_room(room_id:int, transition:int=-1, transition_length:float=-1, force_transition:bool=false):
	#set the room to a specific id or current location
	#if specific room passed in then no check is performed other than it is valid
	# i.e. no room blocking is performed, may result in camera controller (e.g. player)
	#not be synced
	var room_id_ok
	if !_validate():
		return
	
	if room_id!=-1:
		_current_room=room_id

	room_id_ok=_map_controller.is_valid_room(_current_room)
	
	if !room_id_ok:
		return
		
	if _current_room==-1:
		return
		
	#take the current room and set the camera to this
	print("Changing room to %s" % _current_room)
	var newpos=get_room_topleft_global(_current_room)
	
	if newpos==INVALID_ROOM:
		return
	
	if transition==-1:
		transition=default_transition
	if transition_length==-1:
		transition_length=default_transition_time
		
	if !_is_scrolling || force_transition:
		_transition_camera(newpos,transition,transition_length)
	
	#refresh the exit blocks, guaranteed valid array
	var exits=_map_controller.get_room_exits(_current_room)
	#if -1 we are not allowed so pass false, otherwise pass true

	if !_is_scrolling:
		_camera_controller.set_exits(exits[0]>=0, exits[1]>=0, exits[2]>=0, exits[3]>=0)

func _transition_camera(newpos:Vector2,transition:int,duration:float) ->void:
	#player wants a transition
	match transition:
		ROOM_TRANSITION.SLIDE:
			_transition_slide(newpos,duration)
			
		ROOM_TRANSITION.FADE:
			_transition_fade(newpos,duration)
		_:
			#ensure camera is set to new room
			_camera_controller.set_position(newpos)

			
func _transition_slide(newpos:Vector2,duration:float) ->void:
	#update camera over duration
	get_tree().paused=true
	
	tween.interpolate_method(_camera_controller,"set_position",_camera_controller.position,newpos,duration)
	tween.start()
	yield(tween,"tween_all_completed")
	get_tree().paused=false
	_camera_controller.set_position(newpos)	

func _transition_fade(newpos:Vector2,duration:float) ->void:
	#fade in alpha to clear screen
	get_tree().paused=true
	
	rect.color.a=0.0
	rect.visible=true
	tween.interpolate_property(rect,"color:a",0.0,1.0,duration/2.0,Tween.TRANS_LINEAR,Tween.EASE_IN,duration/2.0)
	tween.start()
	yield(tween,"tween_all_completed")
	
	_camera_controller.set_position(newpos)
	
	#fade out to new
	tween.interpolate_property(rect,"color:a",1.0,0.0,duration/2.0,Tween.TRANS_LINEAR,Tween.EASE_IN,duration/2.0)
	tween.start()
	yield(tween,"tween_all_completed")
	
	#finalise new room
	rect.visible=false
	get_tree().paused=false
	
	
func _validate() -> bool:
	if !_room_valid:
		print("Error. Room manager not configured")
		return false
	return true

func get_roomid_from_global(location:Vector2) -> int:
	if !_validate():
		return -1
	return _map_controller.get_roomid_from_position(location)

func get_valid_room_in_direction_from_position(location:Vector2,direction:Vector2) -> Array:
	#returns array: roomid,transition,new player x, new player y
	if _validate():
		return [-1,-1,-1,-1]
	var room=get_roomid_from_global(location)
	return get_valid_room_in_direction_from_room(room,direction)

		
func get_valid_room_in_direction_from_room(room_id:int,direction:Vector2) -> Array:
	#returns array: roomid,transition,new player x, new player y
	if !_validate():
		return [-1,-1,-1,-1]
	#check valid direciton
	#we can't pass in enums into a function so have to pretent it is an int
	#check if player needs to warp
	#returns array: roomid,new player x, new player y

	#from a global pixel location get the room in any direction, but only if the room can be navigated to
	if !_valid_direction_vector(direction):
		return [-1,-1,-1,-1,-1]

	var exits=_map_controller.get_room_exits(room_id)

	var newroom=_array_item_from_direction(exits,direction)[0]		#the item in the array
	
	#room transitions. array holds type and duration
	var tran_array=_map_controller.get_room_transition(room_id)
	var trans=_array_item_from_direction(tran_array,direction)
	var tran_type=-1
	var tran_dur=-1
	if trans.size()==2:
		tran_type=trans[0]
		tran_dur=trans[1]
		
	#warp stuff
	var new_positions=_map_controller.get_room_warp_location(room_id)
	var new_pos=null
	if new_positions!=null:
		new_pos=_array_item_from_direction(new_positions,direction)
		
	if new_pos!=null && new_pos.size()==2:
		#new position for player
		return [newroom,tran_type,tran_dur,new_pos[0],new_pos[1]]
		
	return [newroom,tran_type, tran_dur,-1,-1]
	
func get_room_topleft_global(room_id:int) -> Vector2:
	if !_validate():
		return INVALID_ROOM
		
	#check room_id is valid first
	if !_map_controller.is_valid_room(room_id):
		return INVALID_ROOM
		
	return _map_controller.get_room_topleft_position(room_id)

func get_room_bottomright_global(room_id:int) -> Vector2:
	if !_validate():
		return INVALID_ROOM
		
	#check room_id is valid first
	if !_map_controller.is_valid_room(room_id):
		return INVALID_ROOM
		
	return _map_controller.get_room_bottomright_position(room_id)
	
func get_room_topleft_global_from_position(location:Vector2) -> Vector2:
	if !_validate():
		return INVALID_ROOM

	#from a pixel location, e.g. the player, get the top left of the room in pixels
	#this is if we want to get camera location based on players current location
	#the methods below all self-validate so no need for more validation
	var room_id=_map_controller.get_roomid_from_position(location)
	return get_room_topleft_global(room_id)
	
func get_room_bottomright_global_from_position(location:Vector2) -> Vector2:
	if !_validate():
		return INVALID_ROOM

	#from a pixel location, e.g. the player, get the top left of the room in pixels
	#this is if we want to get camera location based on players current location
	#the methods below all self-validate so no need for more validation
	var room_id=_map_controller.get_roomid_from_position(location)
	return get_room_bottomright_global(room_id)
	
func _valid_direction_vector(direction:Vector2) ->bool:
	if !_validate():
		return false
	#only want valid direction
	return [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT].has(direction)


func _array_item_from_direction(items:Array, direction:Vector2) ->Array:
	if !_validate():
		return [-1]
	#this saves a big match statement, checks if direction is a valid one
	var index=[Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT].find(direction)
	#guard against invalid direction and invalid array
	if index==-1:
		return [-1]
	if items==null || items.size()!=4:
		return [-1]
		
	#if it's an array then return it
	if items[index] is Array:
		return items[index]
	
	#it's a single value return it as an array
	return [items[index]]
	
func set_camera_flip(position:Vector2, force_transition:bool):
	_is_scrolling=false
	_camera_scrolling.disable()
	_camera_controller.enable()
	_current_room=_map_controller.get_roomid_from_position(position)

	#if game jumps then area for map is set wrong
	var speed=0.5 if force_transition else 0.0
	change_room(_current_room,ROOM_TRANSITION.NONE,speed,force_transition)
		
func set_camera_scrolling(tl:Vector2,br:Vector2,force_transition):
	_is_scrolling=true
	_camera_scrolling.enable()
	_camera_controller.disable()
	_camera_controller.lock_room(false)
	_camera_scrolling.set_limits(tl, br)

	var room#=get_roomid_from_global(tl)
	room=get_roomid_from_global(_camera_controller.global_position)
	#if moving to a different room then force a change room
	#otherwise let it go unless force has been set
	
	if room!=_current_room:
		force_transition=true
	
	if force_transition:
		var speed=0.5 if force_transition else 0.0
		#if game jumps then area for map is set wrong
		change_room(_current_room,ROOM_TRANSITION.SLIDE,speed,force_transition)
