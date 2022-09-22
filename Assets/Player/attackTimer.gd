extends Timer

var started = false
export(float) var attackTimeOut = 0.2
onready var timeOutTimer = $timeOut

func start_timer(time):
	if not timeOutTimer.time_left == 0:
		return
		
	self.wait_time = time
	self.start()
	started = true


func _on_attackTimer_timeout():
	started = false
	timeOutTimer.start()
