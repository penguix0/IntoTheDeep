extends Camera2D

signal room_change(direction)
var block_exits=false			#stop player leaving room. For debugging mainly unless it becomes useful

#offset for the navigation, i.e. how far off screen before
#signalling new room
export(int) var room_navigation_pixel_offset:=16

var transition_time_out : bool

onready var ScreenShake = $ScreenShake

onready var blockers=[$RoomBlocker/CollisionTop, $RoomBlocker/CollisionBottom, $RoomBlocker/CollisionLeft, $RoomBlocker/CollisionRight]
onready var navi=[$RoomNavigation/NavigateUp, $RoomNavigation/NavigateDown, $RoomNavigation/NavigateLeft, $RoomNavigation/NavigateRight]
func _ready() -> void:
	print("Camera ready with pre-configured data")
	_show_config()
	lock_room(block_exits)
	Global.camera = self
	
func enable():
	current=true
	
func disable():
	current=false
	
func set_position(location:Vector2,zoom:float=1.0) -> void:
	#very simple method to set position
	#it does not check map
	#as that is responsibility of the map
	position=location
	if zoom!=1.0:
		self.zoom=Vector2(zoom,zoom)
	
func set_exits(block_up:bool,block_down:bool,block_left:bool,block_right:bool):
	#disabled true means does not check so allows player
	#disabled false means does check so disallows player
	#only works for flip
	blockers[0].set_deferred("disabled",block_up)
	blockers[1].set_deferred("disabled",block_down)
	blockers[2].set_deferred("disabled",block_left)
	blockers[3].set_deferred("disabled",block_right)
	print("Setting exits as follows (u,d,l,r) %s,%s,%s,%s" % [block_up,block_down,block_left,block_right])
	
func lock_room(is_locked:=true):
	#force all exits to be enabled, thus blocking player
	#simplyer helper function for set_exits
	block_exits=is_locked
	set_exits(!block_exits,!block_exits,!block_exits,!block_exits)
	
func _on_RoomNavigation_body_shape_entered(_body_id: RID, _body: Node, _body_shape: int, local_shape: int) -> void:
	if local_shape<0 || local_shape>3:
		return
		
	var directions=[Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]
	var change_direction=directions[local_shape]
	
	## Prevents the camera from skipping rooms instead of transitioning to the next room
	if not transition_time_out:
		emit_signal("room_change",change_direction)
		$navigationTimeOut.start()
		transition_time_out = true
	
	print("Camera changing direction room to direction %s as vector %s" % [local_shape,change_direction])
	
func _show_config():
	print("Room blocker positions (u,d,l,r): (%s),(%s),(%s),(%s)" % [ [blockers[0].position], 
	[blockers[1].position], 
	[blockers[2].position], 
	[blockers[3].position]
	])
	print("Room navigation positions (u,d,l,r): (%s),(%s),(%s),(%s)" % [ [navi[0].position], 
	[navi[1].position], 
	[navi[2].position], 
	[navi[3].position]
	])
	print("Room blocker sizes (u,d,l,r): (%s),(%s),(%s),(%s)" % [ [blockers[0].shape.extents], 
	[blockers[1].shape.extents], 
	[blockers[2].shape.extents], 
	[blockers[3].shape.extents]
	])
	print("Room navigation sizes (u,d,l,r): (%s),(%s),(%s),(%s)" % [ [navi[0].shape.extents], 
	[navi[1].shape.extents], 
	[navi[2].shape.extents], 
	[navi[3].shape.extents]
	])

func set_navigation_system(viewport_size:Vector2,offscreen_gap:int):
	#either set the RoomBlocker and RoomNavigation manually
	#or call this. 
	#roomblocker (i.e. stopping you leaving) is normally the screen size
	#set with viewport_size
	#room navigation is roomblocker but offset by half player to look as though
	#leaving screen, set via offscreen_gap in pixels
	var newx=viewport_size.x/2
	var newy=viewport_size.y/2
	navi[0].position=Vector2(newx,-offscreen_gap)
	navi[1].position=Vector2(newx,viewport_size.y+offscreen_gap)
	navi[2].position=Vector2(-offscreen_gap,newy)
	navi[3].position=Vector2(viewport_size.x+offscreen_gap,newy)

	blockers[0].position=Vector2(newx,0)
	blockers[1].position=Vector2(newx,viewport_size.y)
	blockers[2].position=Vector2(0,newy)
	blockers[3].position=Vector2(viewport_size.x,newy)

	navi[0].shape.extents.x=newx
	navi[1].shape.extents.x=newx
	navi[2].shape.extents.y=newy
	navi[3].shape.extents.y=newy

	blockers[0].shape.extents.x=newx
	blockers[1].shape.extents.x=newx
	blockers[2].shape.extents.y=newy
	blockers[3].shape.extents.y=newy
	print("--- Navigation system configured manually to")
	_show_config()

func _exit_tree():
	Global.camera = null

func _on_navigationTimeOut_timeout():
	transition_time_out = false

func _on_RoomNavigation_body_exited(body):
	pass # Replace with function body.
