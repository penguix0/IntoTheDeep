extends Node

export(int) var controller = 0

var crouching : bool
var up : bool
var jump : bool
var just_jumped : bool
var down : bool
var running : bool
var move_direction : float
var last_move_direction : float

var attack_request : bool
var sword_out : bool

onready var swordOutTimer = $"../swordOutTimer"

func _physics_process(_delta):
	_get_input()

func _get_input():
	var left = int(Input.is_action_pressed(str(controller)+"_left"))
	var right = int(Input.is_action_pressed(str(controller)+"_right"))
	
	move_direction = -(left-right)
	
	if not move_direction == 0:
		last_move_direction = move_direction
	
	if Input.is_action_pressed(str(controller)+"_sword"):
		if not swordOutTimer.time_left > 0:
			swordOutTimer.start()
			sword_out = not sword_out

	## Get input for crouching	
	crouching = false
	if Input.is_action_pressed(str(controller)+"_crouch"):
		crouching = true
		
		## Prevents the player from moving while crouching
		move_direction = 0

	## Get input for attacking
	attack_request = false
	if Input.is_action_pressed(str(controller)+"_attack"):
		attack_request = true

	up = false
	if Input.is_action_pressed(str(controller)+"_up"):
		up = true
	
	down = false
	if Input.is_action_pressed(str(controller)+"_down"):
		down = true
		
	running = false
	if Input.is_action_pressed(str(controller)+"_run"):
		running = true
		
	jump = false
	if Input.is_action_pressed(str(controller)+"_jump"):
		jump = true
		
	just_jumped = false
	if Input.is_action_just_pressed(str(controller)+"_jump"):
		just_jumped = true
		


