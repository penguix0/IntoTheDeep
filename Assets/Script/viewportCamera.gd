extends Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	## If the camera actually exists
	if is_instance_valid(Global.camera):
		## Copies all the cameras properties
		global_position = Global.camera.global_position
		offset = Global.camera.offset
		zoom = Global.camera.zoom
		rotation_degrees = Global.camera.rotation_degrees
