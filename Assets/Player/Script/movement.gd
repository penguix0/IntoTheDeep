extends KinematicBody2D

const UP = Vector2(0, 1)
export(int) var slope_stop = 45

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
export(float) var jump_time_out = 0.5

var up : bool
var down: bool

var running : bool
var landing : bool
var walking : bool
var crouching : bool

var attacking : bool = false
var attack_1_dur : float = 0.4
var attack_2_dur : float = 0.6
var attack_3_dur : float = 0.6
var attack_1_air_dur : float = 0.4
var attack_2_air_dur : float = 0.3
var attack_3_air_stop : bool = false

var attack_1_dash_speed : float = 300

var attack_1_stamina : float = 10
var attack_2_stamina : float = 20
var attack_3_stamina : float = 30

var currentAttack = ""

var lastMoveDirection : int = 1

onready var raycasts = $raycasts
onready var AnimPlayer = $AnimationPlayer
onready var wasGroundedTimer = $wasGroundedTimer
onready var dustParticles = $dustParticles
onready var staminaBar = $staminaBar
onready var walkingDust = $walkingParticles
onready var swordOutTimer = $swordOutTimer
onready var raycastUp = $raycastUp
onready var body = $body
onready var attackTimer = $attackTimer
onready var comboTimer = $comboTimer
onready var camera = $Camera2D
onready var jumpTimeOut = $jumpTimeOut
onready var ghostTimer = $ghostTimer
onready var gatherInput = $gatherInput

var emitGhost : bool = false
var ghost

var stateMachine

# Called when the node enters the scene tree for the first time.
func _ready():
	##AnimPlayer.play("idle")
	gravity = (2*JumpHeight)/pow(TimeToJumpPeak, 2)
	JumpSpeed = gravity * TimeToJumpPeak
	Global.gravity = gravity
	
	
	stateMachine = $AnimationTree.get("parameters/playback")
	stateMachine.start("idle_normal")
	
	ghost = preload("res://Assets/Player/ghost.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	## If the player was on the ground and is not anymore
	if is_grounded and not raycasts.is_grounded:
		wasGroundedTimer.wait_time = jumpTimeOffPlatform
		wasGroundedTimer.start()
	
	is_grounded = raycasts.is_grounded
	on_ceiling = _check_hit_ceiling()
	
	if not is_grounded or on_ceiling:
		_apply_gravity(delta) 

	if raycasts.landing:
		jumping = false
	
	_apply_input(gatherInput.move_direction, delta)
	
	_walk(gatherInput.move_direction)
	
	_limit_gravity()
	
	var currVel = move_and_slide(velocity, UP, slope_stop)
	var slides = get_slide_count()
	if slides:
		slope(slides)

func slope(slides: int):
	## See: https://www.youtube.com/watch?v=pyMAakSPUk0
	for slide in slides:
		var touched = get_slide_collision(slide)
		if is_grounded and touched.normal.y < 1.0 and not velocity.x == 0 and not is_on_wall():
			velocity.y = touched.normal.y
	
func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func _check_hit_ceiling():
	for raycast in raycastUp.get_children():
		if raycast.is_colliding():
			return true
	return false

func jump():
	velocity.y = -JumpSpeed
	
	jumping = true

func _apply_input(moveDirection, delta):
	walking = false
	running = false
	
	if moveDirection != 0:
		## if the player is moving and presses the run key, check te follwoing:
		## - is there enough stamina left to run
		## - is there no staminaTimout
		if gatherInput.running and staminaBar.currentStamina > 0 and not staminaBar.staminaTimeOut:
			running = true
		else:
			walking = true
	
	if not crouching:	
		if running and is_grounded:
			## Multiply the moveSpeed
			currentMoveSpeed = moveSpeed * runMultiplier
			## Drain stamina when moving
			staminaBar.drain_stamina_running(delta)
		if walking:
			currentMoveSpeed = moveSpeed

	if gatherInput.sword_out and gatherInput.attack_request and (not attackTimer.started):
		_attack(delta, moveDirection)
	
	if attackTimer.started:
		attacking = true
	else:
		attacking = false
	
	_jump_after_leaving_platform()
	
func _attack(delta, moveDirection):
	## Check wether the player is in the air:
	if is_grounded:
		## Start combo
		## If up and attack are pressed at the same time
		if gatherInput.up:
			currentAttack = "air_sword_2"
			
			if not attackTimer.started:
				attackTimer.start_timer(attack_2_dur)
				
			staminaBar.drain_stamina_attack(delta, 2)
			
			jump()
			
		## if the player is not moving
		elif moveDirection == 0:
			if comboTimer.time_left > 0:
				## Change the current attack
				currentAttack = "sword_3"
				if not attackTimer.started:
					attackTimer.start_timer(attack_3_dur)
				
				staminaBar.drain_stamina_attack(delta, 3)	
			else:
				currentAttack = "sword_2"
				if not attackTimer.started:
					attackTimer.start_timer(attack_2_dur)
				
				staminaBar.drain_stamina_attack(delta, 2)
		## If the player is moving
		else:
			## Change the current attack
			currentAttack = "sword_1"
			if not attackTimer.started:
				attackTimer.start_timer(attack_1_dur)
				
			staminaBar.drain_stamina_attack(delta, 1)

	## If the player is in the air
	else:
		if gatherInput.down:
			currentAttack = "air_sword_3"
			if not attackTimer.started:
				attackTimer.start_timer(60)
			
			attack_3_air_stop = false
			
			# If the player is doing a downwards attack he can't go up:
			if velocity.y < 0:
				velocity.y = 0
		else:
			currentAttack = "air_sword_1"
			if not attackTimer.started:
				attackTimer.start_timer(attack_1_air_dur)

func _jump_after_leaving_platform():
	## Jump when jump is pressed
	if gatherInput.jump:
		## If the player was previously on a platform but not anymore:
		if (not is_grounded and wasGroundedTimer.time_left > 0 and not jumping) and jumpTimeOut.time_left == 0:
			jump()
		## If the player is on the ground
		elif is_grounded and jumpTimeOut.time_left == 0:
			jump()
	
func _limit_gravity():		
	## Check if the velocity on the y-axis is not bigger than it should be
	if velocity.y > 0.5*gravity:
		velocity.y = 0.5*gravity

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

