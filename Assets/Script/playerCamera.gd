extends Camera2D

onready var ScreenShake = $ScreenShake

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.camera = self
	
func _exit_tree():
	Global.camera = null
	

