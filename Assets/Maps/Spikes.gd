extends Area2D

func _on_Spikes_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if "health" in body:
		body.health = 0
