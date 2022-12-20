extends Node2D

onready var sprite_animPlayer = $"../Sprite/AnimationPlayer"
var notice_played : bool = false

func _on_left_body_entered(body):
	if if_player(body.name):
		get_parent().turn_left()

func _on_right_body_entered(body):
	if if_player(body.name):
		get_parent().turn_right()

func _on_shank_body_entered(body):
	if if_player(body.name):
		get_parent().shank = true

func _on_shank_body_exited(body):
	if if_player(body.name):
		get_parent().shank = false

func _on_notice_body_entered(body):
	if if_player(body.name):
		if not notice_played:
			sprite_animPlayer.play("notice")
			notice_played = true
			Global.play_exciting = true

func _on_notice_body_exited(body):
	if if_player(body.name):
		notice_played = false
		Global.play_exciting = false

func if_player(name):	
	if name == Global.player1_name or name == Global.player2_name or name == Global.player3_name or name == Global.player4_name:
		return true
	return false
