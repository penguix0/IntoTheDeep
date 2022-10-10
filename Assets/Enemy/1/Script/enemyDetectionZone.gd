extends Node2D

onready var left = $left
onready var right = $right

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_left_body_entered(body):
	if body.name == Global.player1_name or body.name == Global.player2_name or body.name == Global.player3_name or body.name == Global.player4_name:
		get_parent().turn_left()

func _on_right_body_entered(body):
	if body.name == Global.player1_name or body.name == Global.player2_name or body.name == Global.player3_name or body.name == Global.player4_name:
		get_parent().turn_right()
