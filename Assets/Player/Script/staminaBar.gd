extends TextureProgress

var active = false
onready var animPlayer = $AnimationPlayer

func _on_staminaBar_value_changed(_value):
	if not active:
		animPlayer.play("staminaBar_appear")
		active = true
	
func _process(_delta):
	if value == max_value and active:
		animPlayer.play("staminaBar_disappear")
		active = false
