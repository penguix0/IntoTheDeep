extends CanvasLayer

func _ready():
	self.visible = false

func _on_Button_pressed():
	if self.visible:
		get_tree().change_scene("res://Assets/Scene/Main.tscn")

func _on_Button2_pressed():
	if self.visible:
		get_tree().quit()
