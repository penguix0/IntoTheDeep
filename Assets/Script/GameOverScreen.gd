extends CanvasLayer

func _ready():
	self.visible = false

onready var player = get_node("../Player")

func appear():
	self.visible = true
	player.pause_mode = Node.PAUSE_MODE_STOP
	

func _on_Button_pressed():
	if self.visible:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Assets/Scene/Main.tscn")

func _on_Button2_pressed():
	if self.visible:
		get_tree().quit()
