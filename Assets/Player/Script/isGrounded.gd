extends Node2D

var is_grounded : bool = false
var landing : bool

onready var jumpTimeOut = $"../jumpTimeOut"
export var jump_time_out = 0.2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	is_grounded = _check_is_grounded()
	_check_if_landed()
	
func _check_if_landed():
	if is_grounded:
		if landing:
			landing = false
	else:
		if !landing:
			landing = true
				
			## Prevents the player from jumping every 0 seconds
			jumpTimeOut.wait_time = jump_time_out
			jumpTimeOut.start()
	

func _check_is_grounded():
	for raycast in get_children():
		if raycast.is_colliding() and raycast.enabled:
			return true
	return false
