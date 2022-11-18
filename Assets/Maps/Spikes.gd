extends Area2D

func _on_Spikes_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if "health" in body:
		body.health = 0
