extends Timer

var started = false
export(float) var attackTimeOut = 0.2
onready var timeOutTimer = $timeOut
onready var comboTimer = $"../comboTimer"
var timeOutTimerStarted = false

func start_timer(time):
	if not timeOutTimer.time_left == 0:
		return
		
	self.wait_time = time
	self.start()
	started = true

func stop_timer():
	self.wait_time = 0.001
	self.start()
	started = false

func _on_attackTimer_timeout():
	started = false
	timeOutTimer.start()
	timeOutTimerStarted = true
	
	comboTimer.start()

func _on_timeOut_timeout():
	timeOutTimerStarted = false
