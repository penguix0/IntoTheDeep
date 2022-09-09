extends KinematicBody2D

## export makes the variable show along the node properties
export var controller = 0

const UP = Vector2(0, 1)
export(int) var slope_stop = 64

var velocity = Vector2()
export(int) var moveSpeed = 200
var currentMoveSpeed = moveSpeed
export(float) var runMultiplier = 2
export(float) var acceleration = 0.5
export(float) var decceleration = 0.7
export(float) var decceleration_air = 0.1
export(float) var walkingThreshold = 0.2

export(float) var stamina = 100
export(float) var staminaDrainRunning = 25
export(float) var staminaRegenerationFactor = 10
export(float) var staminaRegenerationFactorWithTimeOut = 5
var currentStamina = stamina
var staminaTimeOut = false

export(float) var gravity = 0
export(float) var TimeToJumpPeak = 0.3
export(int) var JumpHeight = 70
export(float) var JumpSpeed = 0
export(float) var jumpTimeOffPlatform = 0.1

var is_grounded
var jumping
var running

onready var raycasts = $raycasts
onready var AnimPlayer = $AnimationPlayer
onready var wasGroundedTimer = $wasGroundedTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	AnimPlayer.play("idle")
	gravity = (2*JumpHeight)/pow(TimeToJumpPeak, 2)
	JumpSpeed = gravity * TimeToJumpPeak

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	## If the player was on the ground and is not anymore
	if is_grounded and not _check_is_grounded():
		jumping = false
		wasGroundedTimer.wait_time = jumpTimeOffPlatform
		wasGroundedTimer.start()
		
	is_grounded = _check_is_grounded()
	
	if not is_grounded:
		_apply_gravity(delta) 
	
	_get_input(delta)
	
	move_and_slide(velocity, UP, slope_stop)
	
	if is_grounded and velocity.x > -0.2 and velocity.x < 0.2:
		AnimPlayer.play("Idle")

func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func _check_is_grounded():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
	
func jump():
	velocity.y = -JumpSpeed
	if velocity.x > -walkingThreshold and velocity.x < walkingThreshold:
		AnimPlayer.play("jump")
	jumping = true
	
func _get_input(delta):
	var left = int(Input.is_action_pressed(str(controller)+"_left"))
	var right = int(Input.is_action_pressed(str(controller)+"_right"))

	var move_direction = -(left-right)
	
	## The Lerp function smooths out the velocity, this prevents instand acceleration
	if move_direction != 0:
		velocity.x = lerp(velocity.x, move_direction * currentMoveSpeed, acceleration)
	else:
		if not is_grounded:
			velocity.x = lerp(velocity.x, 0, decceleration_air)
		else:
			velocity.x = lerp(velocity.x, 0, decceleration)
	
	### Sprinting
	
	if Input.is_action_pressed(str(controller)+"_run") and move_direction != 0 and currentStamina > 0 and not staminaTimeOut:
		running = true
	elif Input.is_action_just_released(str(controller)+"_run") and running or move_direction == 0:
		running = false
	
	if running:
		## Multiply the moveSpeed
		currentMoveSpeed = moveSpeed * runMultiplier
		## Drain stamina when moving
		currentStamina -= delta * staminaDrainRunning
	else:
		currentMoveSpeed = moveSpeed
	
	
	## Stamina
	## If stamina is empty activate low stamina mode
	if currentStamina < 1:
		staminaTimeOut = true
		running = false
	## Regenerate stamina slower when there's almost none left
	if currentStamina < 0.1*stamina and staminaTimeOut:
		currentStamina += delta * staminaRegenerationFactorWithTimeOut
	if currentStamina > 0.1*stamina and staminaTimeOut:
		staminaTimeOut = false
			
	## If stamina is not the maximum regenerate stamina
	if currentStamina <= stamina and not running and not staminaTimeOut:
		currentStamina += delta * staminaRegenerationFactor
	
	## If the currentStamina value reaches above the original set value: reset it
	if currentStamina > stamina:
		currentStamina = stamina
	
	$ProgressBar.value = currentStamina
	
	
	### Jumping
	
	## Jump when jump is pressed
	if Input.is_action_pressed(str(controller)+"_jump"):
		## If the player was previously on a platform but not anymore:
		if (not is_grounded and wasGroundedTimer.time_left > 0 and not jumping):
			jump()
		## If the player is on the ground
		elif is_grounded:
			jump()

	## Stop the jump if jump is released and not already falling down
	if jumping and Input.is_action_just_released(str(controller)+"_jump") and velocity.y < 0:
		velocity.y = 0
		jumping = false
		
	## Check if the velocity on the y-axis is not bigger than it should be
	if velocity.y > gravity:
		velocity.y = gravity
	
