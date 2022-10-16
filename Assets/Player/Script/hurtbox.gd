extends Area2D

## Makes the player take damage
func take_damage(name):
	if name == "enemy1":
		get_parent().health -= 5

