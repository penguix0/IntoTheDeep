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

var gravity : float = 0.0
export(float) var TimeToJumpPeak = 0.3
export(int) var JumpHeight = 70
var JumpSpeed : float = 0.0
export(float) var jumpTimeOffPlatform = 0.1

var is_grounded : bool
var on_ceiling : bool
var jumping : bool
var running : bool
var landing : bool
var walking : bool
var crouching : bool
var sword_out : bool = false
var attack_request : bool = false
export var allow_jump_break : bool = false

onready var raycasts = $raycasts
onready var AnimPlayer = $AnimationPlayer
onready var wasGroundedTimer = $wasGroundedTimer
onready var squeezePlayer = $squeezePlayer
onready var dustParticles = $dustParticles
onready var staminaBar = $staminaBar
onready var walkingDust = $walkingParticles
onready var swordOutTimer = $swordOutTimer
onready var raycastUp = $raycastUp
onready var body = $body
var stateMachine

# Called when the node enters the scene tree for the first time.
func _ready():
	##AnimPlayer.play("idle")
	gravity = (2*JumpHeight)/pow(TimeToJumpPeak, 2)
	JumpSpeed = gravity * TimeToJumpPeak
	Global.gravity = gravity
	
	
	stateMachine = $AnimationTree.get("parameters/playback")
	stateMachine.start("idle_normal")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	## If the player was on the ground and is not anymore
	if is_grounded and not _check_is_grounded():
		wasGroundedTimer.wait_time = jumpTimeOffPlatform
		wasGroundedTimer.start()
	
	is_grounded = _check_is_grounded()
	on_ceiling = _check_hit_ceiling()

	if is_grounded:
		if landing:
			_on_land()
			landing = false
	else:
		if !landing:
			landing = true
	
	if not is_grounded or on_ceiling:
		_apply_gravity(delta) 
	else:
		jumping = false
	
	_apply_input(_get_input(), delta)
	
	_play_animations(_get_input())
	
	move_and_slide(velocity, UP, slope_stop)

func _on_land():
	squeezePlayer.play("squeeze_out")

func _play_animations(moveDirection):
	walkingDust.emitting = false

	## Flip the sprite if going left
	if moveDirection > 0:
		body.scale.x = abs(body.scale.x)
	elif moveDirection < 0:
		body.scale.x = -abs(body.scale.x)
	else:
		if sword_out:
			stateMachine.travel("idle_sword")
		else:		
			stateMachine.travel("idle_normal")
	
	## Only if running
	if running and not jumping:	
		stateMachine.travel("run")
		
		walkingDust.emitting = true
	
	## Only if jumping
	elif jumping:
		if velocity.y < 0:
			stateMachine.travel("jump_mid_air")
		else:
			stateMachine.travel("jump_fall")
	
	## Only if walking
	elif walking and not running and not jumping:
		stateMachine.travel("walk")
		
		walkingDust.emitting = true
		
	## Only if crouching
	elif crouching and not jumping:
		stateMachine.travel("crouch")

func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func _check_is_grounded():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
	
func _check_hit_ceiling():
	for raycast in raycastUp.get_children():
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
	
	## Get input for crouching	
	crouching = false
	if Input.is_action_pressed(str(controller)+"_crouch"):
		crouching = true

	## Get input for attacking
	attack_request = false
	if Input.is_action_pressed(str(controller)+"_attack"):
		attack_request = true

	var move_direction = -(left-right)
	
	return move_direction
	
func _apply_input(moveDirection, delta):
	walking = false
	running = false
	
	### Running
	
	if Input.is_action_pressed(str(controller)+"_run") and moveDirection != 0 and currentStamina > 0 and not staminaTimeOut:
		running = true
	elif Input.is_action_just_released(str(controller)+"_run") and running or moveDirection == 0:
		running = false
		
	if running:
		## Multiply the moveSpeed
		currentMoveSpeed = moveSpeed * runMultiplier
		## Drain stamina when moving
		currentStamina -= delta * staminaDrainRunning
		
		walking = false
		crouching = false
	elif crouching:
		running = false
		walking = false
		moveDirection = 0
	else:
		currentMoveSpeed = moveSpeed
	
	## The Lerp function smooths out the velocity, this prevents instand acceleration
	if moveDirection != 0:
		velocity.x = lerp(velocity.x, moveDirection * currentMoveSpeed, acceleration)
		walking = true
	else:
		if not is_grounded:
			velocity.x = lerp(velocity.x, 0, decceleration_air)
		else:
			velocity.x = lerp(velocity.x, 0, decceleration)
	
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
	if jumping and Input.is_action_just_released(str(controller)+"_jump") and velocity.y < 0 and allow_jump_break:
		velocity.y = 0
		jumping = false
		
	## Check if the velocity on the y-axis is not bigger than it should be
	if velocity.y > gravity:
		velocity.y = gravity
	
