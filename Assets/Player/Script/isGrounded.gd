extends Node2D

var is_grounded : bool = false
var landing : bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	is_grounded = _check_is_grounded()
	_check_if_landed()
	
func _check_if_landed():
	if is_grounded:
		if landing:
			landing = false
	else:
		if !landing:
			landing = true

func _check_is_grounded():
	for raycast in get_children():
		if raycast.is_colliding() and raycast.enabled:
			return true
	return false
