extends Area2D

## Makes the enemy take damage
func take_damage(name):
	## If it is the player who attacks and not another enemy
	if name == Global.player1_name or name == Global.player2_name or name == Global.player3_name or name == Global.player1_name or name == Global.player4_name:
		get_parent().health -= 30
		$"../AnimationPlayer".play("hurt")

