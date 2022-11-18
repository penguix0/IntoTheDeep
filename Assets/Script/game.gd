extends Node2D
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

#if true then _ready does not configure game, i.e. relies on something else
#typically set this when using hud as hud will configure game
#doesn't matter, it just avoids setting things twice
export(bool) var configure_on_ready=true

onready var _camera_controller:Camera2D=$Cameras/Camera2DFlip
onready var _camera_scrolling:Camera2D=$Cameras/Camera2DScroller
onready var _map_controller:Node2D=$Map
onready var _room_manager:Node2D=$RoomManager

var game_over : bool = false
var win : bool = false

func _ready() -> void:
	#if using HUD then configure_game needs to be called
	#in game_with_hud ready function, otherwise incorrect sizes will be set
	#i.e. will get size of screen including hud not the viewport
	#so leave true if no HUD and for instance inside game_with_hud set to false
	#but doesn't matter, just saves calling it twice
	if configure_on_ready:
		var vp= Vector2(
			ProjectSettings.get("display/window/size/width"),
			ProjectSettings.get("display/window/size/height")
		)
		configure_game(vp)

func configure_game(viewport_size:Vector2):
	#initialise the room manager
	#if using HUD, this needs to be called in addition to _ready
	if !_room_manager.setup_rooms(_camera_controller, _camera_scrolling, _map_controller,viewport_size):
		print("ERROR. Setup rooms failed")
		return
	
	#sample of calling set config manually
	#_map_controller.manual_config(Vector2(32,32),Vector2(16,15))
	#sample setting map sizes manually
	#_camera_controller.set_navigation_system(get_viewport().size)
	
	#set us at the start room
	_room_manager.change_room(-1,_room_manager.ROOM_TRANSITION.NONE,0.0)


#events raised by game
func _on_Camera2DFlip_room_change(direction) -> void:
	#raised by the camera
	#we are here so the static body did not block our path, i.e. this is a valid route, so change room 
	if typeof(direction)!=TYPE_VECTOR2:
		return
	
	#use default direction or direction specified in the array
	_room_manager.manage_direction(direction)
	
	#use this to override
	#_room_manager.manage_direction(direction,_room_manager.ROOM_TRANSITION.SLIDE,0.5)
	#_room_manager.manage_direction(direction,_room_manager.ROOM_TRANSITION.FADE,1.0)


func _on_RoomManager_map_reposition_player(new_global_position) -> void:
	#the room data wants the player to change position
	$Player.global_position=new_global_position


func _on_Map_scroll_start(tl:Vector2, br:Vector2) -> void:
	_room_manager.set_camera_scrolling(tl,br,false)


func _on_Map_scroll_end(position:Vector2) -> void:
	_room_manager.set_camera_flip(position,true)

func _process(_delta):
	if self.game_over:
		$GameOverScreen.appear()
	if self.win:
		$WinScreen.appear()
