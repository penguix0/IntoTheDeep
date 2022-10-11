extends TextureProgress

var active = false

export(float) var stamina = 100.0
export(float) var staminaDrainRunning = 25.0
export(float) var staminaDrainAttack = 50.0
export(float) var staminaRegenerationFactor = 10.0
export(float) var staminaRegenerationFactorWithTimeOut = 5.0
var currentStamina = stamina
var staminaTimeOut = false

var blockStaminaRegen : bool = false

onready var animPlayer = $AnimationPlayer

func _on_staminaBar_value_changed(_value):
	if not active:
		animPlayer.play("staminaBar_appear")
		active = true
	
func _process(delta):
	if value == max_value and active:
		animPlayer.play("staminaBar_disappear")
		active = false
	
	## If stamina is empty activate low stamina mode
	if currentStamina < 1:
		staminaTimeOut = true
	
	if staminaTimeOut:
		## Regenerate stamina slower when there's almost none left
		if currentStamina < (0.1 * stamina):
			currentStamina += delta * staminaRegenerationFactorWithTimeOut
		if currentStamina > (0.1 * stamina):
			staminaTimeOut = false
			
	## If stamina is not the maximum regenerate stamina
	if currentStamina <= stamina and not staminaTimeOut:
		currentStamina += delta * staminaRegenerationFactor
	
	## If the currentStamina value reaches above the original set value: reset it
	if currentStamina > stamina:
		currentStamina = stamina
	
	if currentStamina < 0:
		currentStamina = 2
	
	self.value = currentStamina
	
	
	
	
func drain_stamina_running(delta):
	currentStamina -= delta * staminaDrainRunning
	
func drain_stamina_attack(delta, attackType):
	if attackType == 1:
		currentStamina -= delta * staminaDrainAttack
	elif attackType == 2:
		currentStamina -= delta * staminaDrainAttack
	elif attackType == 3:
		currentStamina -= delta * staminaDrainAttack	
