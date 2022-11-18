extends Area2D

func _on_end_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	name = body.name
	if name == Global.player1_name or name == Global.player2_name or name == Global.player3_name or name == Global.player1_name or name == Global.player4_name:
		body.end = true
