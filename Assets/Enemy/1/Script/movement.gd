extends KinematicBody2D

const UP = Vector2(0, 1)
export(int) var slope_stop = 45

var velocity = Vector2()
export(int) var moveSpeed = 100
var currentMoveSpeed = moveSpeed

var gravity : float 
onready var raycasts = $raycasts
var JumpSpeed : float = 0.0
export(float) var TimeToJumpPeak = 0.3

var is_grounded : bool
var jumping : bool


onready var animatedSprite = $AnimatedSprite
onready var collider = $CollisionShape2D
var direction : int = 0

var shank : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	while gravity == 0:
		gravity = Global.gravity
		
	JumpSpeed = gravity * TimeToJumpPeak

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	is_grounded = raycasts.is_grounded
	
	_apply_gravity(delta) 
	
	if raycasts.landing:
		jumping = false
		
	_limit_gravity()
	
	##velocity.x = direction * currentMoveSpeed
	
	if shank:
		animatedSprite.play("melee")
	else:
		animatedSprite.play("idle")

	if direction < 0:
		turn_right()
	elif direction > 0:
		turn_left()
		
		
	var _currVel = move_and_slide(velocity, UP, slope_stop)
	var slides = get_slide_count()
	if slides:
		slope(slides)
	
func turn_left():
	animatedSprite.position.x = -8.2
	animatedSprite.scale.x = 1
	animatedSprite.flip_h = false
	
func turn_right():
	animatedSprite.position.x = 8.2
	animatedSprite.scale.x = 1
	animatedSprite.flip_h = true
	
func _apply_gravity(delta):
	velocity.y += gravity * delta

func slope(slides: int):
	## See: https://www.youtube.com/watch?v=pyMAakSPUk0
	for slide in slides:
		var touched = get_slide_collision(slide)
		if is_grounded and touched.normal.y < 1.0 and not velocity.x == 0 and not is_on_wall():
			velocity.y = touched.normal.y
			
func jump():
	velocity.y = -JumpSpeed
	
	jumping = true
	
func _limit_gravity():		
	## Check if the velocity on the y-axis is not bigger than it should be
	if velocity.y > 0.5*gravity:
		velocity.y = 0.5*gravity

func _on_AnimatedSprite_animation_finished():
	pass
