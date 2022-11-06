extends AnimatedSprite

func _on_Area2D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if $Timer.time_left <= 0:
		$animationPlayer.play("fade_out")
		$Timer.wait_time = 5
		$Timer.start()

func _on_Area2D_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if $Timer.time_left <= 0:
		$animationPlayer.play("fade_in")
		$Timer.wait_time = 5
		$Timer.start()

