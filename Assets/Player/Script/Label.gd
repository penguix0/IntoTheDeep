extends Label

var stop = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not stop:
		self.text = str(round($Timer.wait_time-$Timer.time_left))
