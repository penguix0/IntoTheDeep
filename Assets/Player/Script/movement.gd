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

var gravity : float = 0.0
export(float) var TimeToJumpPeak = 0.3
export(int) var JumpHeight = 70
var JumpSpeed : float = 0.0
export(float) var jumpTimeOffPlatform = 0.1

var is_grounded : bool
var on_ceiling : bool
var jumping : bool
var allow_stop_jump : bool = false
var running : bool
var landing : bool
var walking : bool
var crouching : bool
var sword_out : bool = false

var attack_request : bool = false
var attacking : bool = false
var attack_1_dur : float = 0.4
var attack_2_dur : float = 0.4
var attack_3_dur : float = 0.4

var attack_1_dash_speed : float = 300

var attack_1_stamina : float = 10
var attack_2_stamina : float = 20
var attack_3_stamina : float = 30

var lastMoveDirection : int = 1

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
onready var attackTimer = $attackTimer
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
	
	_walk(_get_input())
	
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
		if lastMoveDirection > 0:
			body.scale.x = abs(body.scale.x)
		else:
			body.scale.x = -abs(body.scale.x)
		
		if sword_out:
			stateMachine.travel("idle_sword")
		else:		
			stateMachine.travel("idle_normal")
	
	## Only if running
	if running and not jumping:	
		stateMachine.travel("run")
		
		if is_grounded: walkingDust.emitting = true
	
	## Only if jumping
	elif jumping:
		stateMachine.travel("jump_mid_air")
	
	## Only if walking
	elif walking and not running and not jumping:
		stateMachine.travel("walk")
		
		if is_grounded: walkingDust.emitting = true
		
	## Only if crouching
	elif crouching and not jumping:
		stateMachine.travel("crouch")
		
	if attacking:
		stateMachine.travel("sword_1")

	if moveDirection != 0: lastMoveDirection = moveDirection

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
	
	if moveDirection != 0:
		if Input.is_action_pressed(str(controller)+"_run") and staminaBar.currentStamina > 0 and not staminaBar.staminaTimeOut:
			running = true
		else:
			walking = true
	
	if not crouching:	
		if running:
			## Multiply the moveSpeed
			currentMoveSpeed = moveSpeed * runMultiplier
			## Drain stamina when moving
			staminaBar.drain_stamina_running(delta)
		if walking:
			currentMoveSpeed = moveSpeed
	else:
		moveDirection = 0
	

	if sword_out and attack_request:
		attack_request = false
		attacking = true
		
		velocity.x = lerp(velocity.x, 3000 * lastMoveDirection, acceleration)
		
		attackTimer.wait_time = attack_1_dur
		if not attackTimer.started:
			attackTimer.start()
			attackTimer.started = true 
		## Dash forward and drain stamina

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
	if jumping and Input.is_action_just_released(str(controller)+"_jump") and velocity.y < 0 and allow_stop_jump:
		velocity.y = 0
		jumping = false
		
	## Check if the velocity on the y-axis is not bigger than it should be
	if velocity.y > gravity:
		velocity.y = gravity
	
func _walk(moveDirection):
	## The Lerp function smooths out the velocity, this prevents instand acceleration
	if moveDirection != 0:
		velocity.x = lerp(velocity.x, moveDirection * currentMoveSpeed, acceleration)
	else:
		## Deccelerate
		if not is_grounded:
			velocity.x = lerp(velocity.x, 0, decceleration_air)
		else:
			velocity.x = lerp(velocity.x, 0, decceleration)
	
func _on_attackTimer_timeout():
	attackTimer.started = false
	attacking = false
	attack_request = false
