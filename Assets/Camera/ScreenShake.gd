## Copied from https://www.codingkaiju.com/tutorials/screen-shake-in-godot-the-best-way/
extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var camera = get_parent()

func start(duration = 0.2, frequency = 15, amplitude = 16, priority = 0, delay = 0):
	if (priority >= self.priority):
		self.priority = priority
		self.amplitude = amplitude

		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		
		if delay == 0:	
			$Duration.start()
			$Frequency.start()

			_new_shake()
		else:
			$Delay.wait_time = delay
			$Delay.start()

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)

	$ShakeTween.set_active(true)
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

	priority = 0


func _on_Frequency_timeout():
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
	
	$ShakeTween.set_active(false)


func _on_Delay_timeout():
	$Duration.start()
	$Frequency.start()
	
	_new_shake()
