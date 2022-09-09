extends TextureProgress

var active = false

func _on_staminaBar_value_changed(_value):
	if not active:
		$"../AnimationPlayer".play("staminaBar_appear")
		active = true
		print ("appear")
	

func _process(_delta):
	if value == max_value and active:
		$"../AnimationPlayer".play("staminaBar_disappear")
		active = false
		print ("dissappear")

		
