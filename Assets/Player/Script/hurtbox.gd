extends Area2D

func take_damage(name):
	if name == "enemy1":
		get_parent().health -= 30

