extends Camera2D

var _flipper:Camera2D

func _ready() -> void:
	pass # Replace with function body.

func set_limits(top_left:Vector2, bottom_right:Vector2) ->void:
	limit_left=int(top_left.x)
	limit_right=int(bottom_right.x)
	limit_top=int(top_left.y)
	limit_bottom=int(bottom_right.y)
	
func enable():
	current=true
	
func disable():
	current=false
