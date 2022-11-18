extends CanvasLayer

var appeared = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true
	$Node2D.visible = true
	$AnimationPlayer.play("start")

func appear():
	if not appeared:
		$AnimationPlayer.play("appear")
		appeared = true
		
func _on_Quit_pressed():
	if self.appeared:
		get_tree().quit()


func _on_Start_over_pressed():
	if self.appeared:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Assets/Scene/Main.tscn")
