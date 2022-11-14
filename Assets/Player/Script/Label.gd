extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.text = str(round($Timer.wait_time-$Timer.time_left))
