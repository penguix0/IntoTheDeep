extends Area2D

func take_damage(name):
	if name == Global.player1_name or name == Global.player2_name or name == Global.player3_name or name == Global.player1_name or name == Global.player4_name:
		get_parent().health -= 30

