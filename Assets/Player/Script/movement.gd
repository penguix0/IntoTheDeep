extends KinematicBody2D

## export makes the variable show along the node properties
export var controller = 0

const UP = Vector2(0, 1)
export(int) var slope_stop = 64

var velocity = Vector2()
export(int) var moveSpeed = 200
var currentMoveSpeed = moveSpeed
export(float) var runMultiplier = 2.0
export(float) var acceleration = 0.5
export(float) var decceleration = 0.7
export(float) var decceleration_air = 0.1
export(float) var walkingThreshold = 0.2

export(float) var stamina = 100.0
export(float) var staminaDrainRunning = 25.0
export(float) var staminaRegenerationFactor = 10.0
export(float) var staminaRegenerationFactorWithTimeOut = 5.0
var currentStamina = stamina
var staminaTimeOut = false

export(float) var gravity = 0.0
export(float) var TimeToJumpPeak = 0.3
export(int) var JumpHeight = 70
export(float) var JumpSpeed = 0.0
export(float) var jumpTimeOffPlatform = 0.1

var is_grounded : bool
var jumping : bool
var running : bool
var landing : bool
var walking : bool
var crouching : bool
var sword_out : bool = false
var was_sword_out : bool = false

var idle_sc : float  = 0.5 ## Idle speed scale animationplayer
var jump_sc : float = 0.5
var walk_sc : float = 1.3
var run_sc : float = walk_sc * runMultiplier
var sword_out_sc : float = 0.5

onready var raycasts = $raycasts
onready var AnimPlayer = $AnimationPlayer
onready var wasGroundedTimer = $wasGroundedTimer
onready var squeezePlayer = $squeezePlayer
onready var dustParticles = $dustParticles
onready var staminaBar = $staminaBar
onready var walkingDust = $walkingParticles
onready var animSprite = $"body/AnimatedSprite"
onready var swordOutTimer = $swordOutTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	##AnimPlayer.play("idle")
	gravity = (2*JumpHeight)/pow(TimeToJumpPeak, 2)
	JumpSpeed = gravity * TimeToJumpPeak

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	## If the player was on the ground and is not anymore
	if is_grounded and not _check_is_grounded():
		wasGroundedTimer.wait_time = jumpTimeOffPlatform
		wasGroundedTimer.start()
	
	is_grounded = _check_is_grounded()

	if is_grounded:
		if landing:
			_on_land()
			landing = false
	else:
		if !landing:
			landing = true
	
	if not is_grounded:
		_apply_gravity(delta) 
	else:
		jumping = false
	
	_apply_input(_get_input(), delta)
	
	_play_animations(_get_input())
	
	move_and_slide(velocity, UP, slope_stop)

func _on_land():
	squeezePlayer.play("squeeze_out")
	#dustParticles.emitting = true

func _play_animations(moveDirection):
	walkingDust.emitting = false

	## Flip the sprite if going left
	if moveDirection > 0:
		$"body/AnimatedSprite".flip_h = false
	elif moveDirection < 0:
		$"body/AnimatedSprite".flip_h = true

	## Only if running
	if running and not jumping:	
		$"body/AnimatedSprite".play("run")
		$"body/AnimatedSprite".speed_scale = run_sc
		
		walkingDust.emitting = true
	
	## Only if jumping
	elif jumping:
		$"body/AnimatedSprite".play("jump")
		$"body/AnimatedSprite".speed_scale = jump_sc
	
	## Only if walking
	elif walking and not running and not jumping:
		$"body/AnimatedSprite".play("run")
		$"body/AnimatedSprite".speed_scale = walk_sc
		
		walkingDust.emitting = true
		
	## Only if crouching
	elif crouching and not jumping:
		$"body/AnimatedSprite".play("crouch")
		
	else:
		## Play the sword out animation
		if sword_out and not was_sword_out:
			$"body/AnimatedSprite".play("sword_out")
			$"body/AnimatedSprite".speed_scale = sword_out_sc
		elif sword_out and was_sword_out:
			$"body/AnimatedSprite".play("idle2")
			$"body/AnimatedSprite".speed_scale = idle_sc
		else:
			$"body/AnimatedSprite".play("idle1")
			$"body/AnimatedSprite".speed_scale = idle_sc

	was_sword_out = sword_out

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
		squeezePlayer.play("squeeze_in")	
	jumping = true
	
func _get_input():
	var left = int(Input.is_action_pressed(str(controller)+"_left"))
	var right = int(Input.is_action_pressed(str(controller)+"_right"))
	
	if Input.is_action_pressed(str(controller)+"_sword"):
		if not swordOutTimer.time_left > 0:
			swordOutTimer.start()
		else:
			sword_out = not sword_out
	
	crouching = false
	if Input.is_action_pressed(str(controller)+"_crouch"):
		crouching = true

	var move_direction = -(left-right)
	
	return move_direction
	
func _apply_input(moveDirection, delta):
	## The Lerp function smooths out the velocity, this prevents instand acceleration
	if moveDirection != 0:
		velocity.x = lerp(velocity.x, moveDirection * currentMoveSpeed, acceleration)
		walking = true
	else:
		walking = false
		running = false
		if not is_grounded:
			velocity.x = lerp(velocity.x, 0, decceleration_air)
		else:
			velocity.x = lerp(velocity.x, 0, decceleration)
	
	### Sprinting
	
	if Input.is_action_pressed(str(controller)+"_run") and moveDirection != 0 and currentStamina > 0 and not staminaTimeOut:
		running = true
		walking = false
		crouching = false
	elif Input.is_action_just_released(str(controller)+"_run") and running or moveDirection == 0:
		running = false
		walking = false
		crouching = false
		
	if running:
		## Multiply the moveSpeed
		currentMoveSpeed = moveSpeed * runMultiplier
		## Drain stamina when moving
		currentStamina -= delta * staminaDrainRunning
	elif crouching:
		running = false
		walking = false
		currentMoveSpeed = 0
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
	
	staminaBar.value = currentStamina
	
	
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
	
