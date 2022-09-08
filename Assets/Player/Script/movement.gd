extends KinematicBody2D

## export makes the variable show along the node properties
export var controller = 0

const UP = Vector2(0, 1)
export var slope_stop = 64

var velocity = Vector2()
export var move_speed = 5 * 96
export var acceleration = 0.2
export var gravity = 1200
export var jump_velocity = -720
var is_grounded
onready var raycasts = $raycasts

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_get_input()
	
	move_and_slide(velocity, UP, slope_stop)
	
	is_grounded = _check_is_grounded()
	
	if not is_grounded:
		_apply_gravity(delta) 


func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func _check_is_grounded():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true

	return false
	
func _input(event):
	if event.is_action_pressed(str(controller)+"_jump") and is_grounded:
		velocity.y = jump_velocity
	
func _get_input():
	var left = int(Input.is_action_pressed(str(controller)+"_left"))
	var right = int(Input.is_action_pressed(str(controller)+"_right"))

	var move_direction = -(left-right)
	
	## The Lerp function smooths out the velocity, this prevents instand acceleration
	velocity.x = lerp(velocity.x, move_direction * move_speed, acceleration)
