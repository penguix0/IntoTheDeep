extends KinematicBody2D

const UP = Vector2(0, 1)
export(float) var slope_stop = 1.22173

var velocity = Vector2()
export(int) var moveSpeed = 200
export(float) var moveSpeedAir = 0.8
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
export(float) var jumpTimeOffPlatform = 0.15

var is_grounded : bool
var on_ceiling : bool
var jumping : bool
export(float) var jump_time_out = 0.5

var up : bool
var down: bool

var running : bool
var walking : bool
var crouching : bool

export(bool) var attacking = false
var already_damage_dealt : bool = false

export var currentAttack = ""

var lastMoveDirection : int = 1

onready var raycasts = $raycasts
onready var AnimPlayer = $AnimationPlayer
onready var wasGroundedTimer = $wasGroundedTimer
onready var dustParticles = $dustParticles
onready var staminaBar = $staminaBar
onready var raycastUp = $raycastUp
##onready var camera = $"../Camera2D"
onready var jumpTimeOut = $jumpTimeOut
onready var gatherInput = $gatherInput
onready var sword_hitbox = $sword_hitbox

var emitGhost : bool = false
var ghost

export(int) var health = 100

var stateMachine

# Called when the node enters the scene tree for the first time.
func _ready():
	##AnimPlayer.play("idle")
	gravity = (2*JumpHeight)/pow(TimeToJumpPeak, 2)
	JumpSpeed = gravity * TimeToJumpPeak
	Global.gravity = gravity
	
	if gatherInput.controller == 0:
		Global.player1_name = self.name
	elif gatherInput.controller == 1:
		Global.player2_name = self.name
	elif gatherInput.controller == 2:
		Global.player3_name = self.name
	elif gatherInput.controller == 3:
		Global.player4_name = self.name
	
	stateMachine = $AnimationTree.get("parameters/playback")
	stateMachine.start("idle_normal")
	
	ghost = preload("res://Assets/Player/ghost.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	## If the player was on the ground and is not anymore
	if is_grounded and not raycasts.is_grounded:
		wasGroundedTimer.wait_time = jumpTimeOffPlatform
		wasGroundedTimer.start()
	
	is_grounded = raycasts.is_grounded
	on_ceiling = raycastUp.on_ceiling
	
	if is_grounded and jumping:
		jumping = false
	
	_apply_gravity(delta) 
	
	_apply_input(gatherInput, delta)
	
	_move(gatherInput.move_direction)
	
	if attacking and currentAttack == "air_sword_3_end":
		velocity.x = 0
		velocity.y = 0
	
	_limit_gravity()
	
	var _currVel = move_and_slide(velocity, UP, true, 4, slope_stop)
	var slides = get_slide_count()
	if slides:
		slope(slides)
	
	if raycasts.landing and slides <= 1:
		jumpTimeOut.start()
		
	if self.health <= 0:
		get_tree().get_current_scene().game_over = true

func slope(slides: int):
	## See: https://www.youtube.com/watch?v=pyMAakSPUk0
	for slide in slides:
		var touched = get_slide_collision(slide)
		if is_grounded and touched.normal.y < 1.0 and not velocity.x == 0 and not is_on_wall():
			velocity.y = touched.normal.y
	
func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func jump():
	velocity.y = -JumpSpeed
	
	jumping = true

func _check_if_jumping_possible():
	if not jumpTimeOut.time_left == 0:
		return false
		
	if is_grounded:
		return true
		
	## If the player is not grounded but has just left a platform
	
	## If already jumping
	if jumping:
		return false
	
	if wasGroundedTimer.time_left > 0:
		return true
		
	return false

func _apply_input(input, delta):
	## Attacking
	if input.attack_request and not attacking:
		attacking = _attack(input)
	elif not attacking:
		currentAttack = ""
		attacking = false
	
	if currentAttack == "":
		attacking = false
	
	_deal_damage()
		
	if input.jump:
		if _check_if_jumping_possible():
			jump()
		
	## Walking etc.
	walking = false
	running = false
	crouching = false
	
	if input.move_direction == 0:
		_decelerate()
		if is_grounded and input.down:
			crouching = true
			
		return
		
	## if the player is moving and presses the run key, check te follwoing:
	## - is there enough stamina left to run
	## - is there no staminaTimout
	if input.running:
		running = true
	else:
		walking = true
	

func _deal_damage():
	if not attacking:
		return
	
	## deal damage if attacking
	if not sword_hitbox.area_entered == null and not already_damage_dealt:
		sword_hitbox.area_entered.take_damage(self.name)

		## Duratioin, frequency, amplitude, priority, delay
		_shake(0.1, 5, 6, 0, 0)
		already_damage_dealt = true
		
	## Reset variable
	if sword_hitbox.area_entered == null and already_damage_dealt:
		already_damage_dealt = false


	
func _attack(input):
	if not input.sword_out:
		return false
	
	if is_grounded:
		_ground_attack(input)
	else:
		_air_attack(input)
	
	return true
	
func _ground_attack(input):
	## Upwards attack
	if input.up:
		## Prevents spamming
		if jumpTimeOut.time_left > 0:
			return

		currentAttack = "air_sword_2"
	
		jump()
		return
		
	if input.down:
		currentAttack = "sword_3"

		return

	if input.move_direction == 0:
		currentAttack = "sword_2"

		return
		
	if input.move_direction != 0:
		currentAttack = "sword_1"

		return
		
	## In case none of these executed
	return
	
func _air_attack(input):
#	if input.down:
#		currentAttack = "air_sword_3"
#
#		# If the player is doing a downwards attack he can't go up:
#		if velocity.y < 0:
#			velocity.y = 0
#		return
	
	currentAttack = "air_sword_1"
	
	return
	
func _limit_gravity():
	## Check if the velocity on the y-axis is not bigger than it should be
	if velocity.y > 0.5*gravity:
		velocity.y = 0.5*gravity

func _decelerate():
	if is_grounded:
		velocity.x = lerp(velocity.x, 0, decceleration)
	else:
		velocity.x = lerp(velocity.x, 0, decceleration_air)
		
func _move(moveDirection):
	## The Lerp function smooths out the velocity, this prevents instand acceleration
	if running:
		var speed = moveDirection * moveSpeed * runMultiplier
		if is_grounded:
			moveSpeed * runMultiplier
			velocity.x = lerp(velocity.x, speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, speed * moveSpeedAir, acceleration)
	elif walking:
		var speed = moveDirection * moveSpeed
		if is_grounded:
			velocity.x = lerp(velocity.x, speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, speed * moveSpeedAir, acceleration)
	

func _shake(duration = 0.2, frequency = 15, amplitude = 16, priority = 0, delay = 0):
	pass
	#$Camera2D/ScreenShake.start(duration, frequency, amplitude, priority, delay)
	
