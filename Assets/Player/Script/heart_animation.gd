extends VBoxContainer

onready var timer = $animationTimer
onready var time_out = $animationTimeOut
onready var hearts = $"../..".hearts_array
var current_heart = 0

## Changing y to sth other than 0 will break this
export(Vector2) var offset = Vector2(1, 0)
var default_pos : Vector2
	
func _on_animationTimeOut_timeout():
	timer.start()
	default_pos = hearts[0].rect_position

func _on_animationTimer_timeout():
	## Gets the current heart and moves it
	hearts[current_heart].rect_position += offset
	
	## Puts the last heart back to its old position
	hearts[current_heart-1].rect_position.x = default_pos.x
		
	current_heart += 1
	
	## Reset the counter and time out
	if current_heart >= len(hearts):
		current_heart = 0
		hearts[-1].rect_position.x = default_pos.x
		timer.stop()
