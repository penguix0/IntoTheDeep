extends KinematicBody2D

## export makes the variable show along the node properties
export var controller = 0

const UP = Vector2(0, 1)
export(int) var slope_stop = 64

var velocity = Vector2()
export(int) var moveSpeed = 200
export(float) var acceleration = 0.5
export(float) var decceleration = 0.7
export(float) var decceleration_air = 0.1
export(float) var walkingThreshold = 0.2

export(float) var gravity = 0
export(float) var TimeToJumpPeak = 0.3
export(int) var JumpHeight = 70
export(float) var JumpSpeed = 0

var is_grounded
var jumping

onready var raycasts = $raycasts
onready var AnimPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	AnimPlayer.play("idle")
	gravity = (2*JumpHeight)/pow(TimeToJumpPeak, 2)
	JumpSpeed = gravity * TimeToJumpPeak


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	is_grounded = _check_is_grounded()
	
	if not is_grounded:
		_apply_gravity(delta) 
	
	_get_input()
	
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
	
func _get_input():
	var left = int(Input.is_action_pressed(str(controller)+"_left"))
	var right = int(Input.is_action_pressed(str(controller)+"_right"))

	var move_direction = -(left-right)
	
	## The Lerp function smooths out the velocity, this prevents instand acceleration
	if move_direction != 0:
		velocity.x = lerp(velocity.x, move_direction * moveSpeed, acceleration)
	else:
		if not is_grounded:
			velocity.x = lerp(velocity.x, 0, decceleration_air)
		else:
			velocity.x = lerp(velocity.x, 0, decceleration)
	
	
	
	if Input.is_action_pressed(str(controller)+"_jump") and is_grounded:
		jump()
	
	## Stop the jump if jump is released and not already falling down
	if jumping and Input.is_action_just_released(str(controller)+"_jump") and velocity.y < 0:
		velocity.y = 0
		jumping = false
		

	## Check if the velocity on the y-axis is not bigger than it should be
	if velocity.y > gravity:
		velocity.y = gravity
	
