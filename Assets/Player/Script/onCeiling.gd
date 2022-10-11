extends Node2D

var on_ceiling : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	on_ceiling = _check_on_ceiling()

func _check_on_ceiling():
	for raycast in get_children():
		if raycast.is_colliding() and raycast.enabled:
			return true
	return false
