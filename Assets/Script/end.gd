extends Area2D

func _on_end_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):

	name = body.name
	if name == Global.player1_name or name == Global.player2_name or name == Global.player3_name or name == Global.player1_name or name == Global.player4_name:
		body.end = true
