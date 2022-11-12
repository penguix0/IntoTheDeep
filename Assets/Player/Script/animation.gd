extends AnimationTree

onready var player = get_parent()
onready var gatherInput = $"../gatherInput"
onready var raycasts = $"../raycasts"
onready var walkingDust = $"../walkingParticles"
onready var body = $"../Sprite"
onready var ghostTimer = $"../ghostTimer"

onready var swordBlood_timeOut = $"../swordBlood/timeOut"
onready var swordBlood = $"../swordBlood"
onready var sword_hitbox = $"../sword_hitbox"

var emitGhost : bool
var ghost

var sword_out : bool
var was_sword_out : bool

var last_move_direction : bool

var running : bool
var walking : bool
var crouching : bool

var attacking : bool
var currentAttack = ""

var jumping : bool
var is_grounded : bool
onready var jump_time_out = player.jump_time_out

var state_machine

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine = get("parameters/playback")
	state_machine.start("idle_normal")
	
	ghost = preload("res://Assets/Player/ghost.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_update_vars()
	_rotate_player(gatherInput.move_direction)
	_play_animations(gatherInput.move_direction)
	##_rotate_hitbox(gatherInput.move_direction)
	_play_attack_animations(gatherInput.last_move_direction)
	was_sword_out = sword_out
	
func _update_vars():
	sword_out = gatherInput.sword_out
	
	running = player.running
	walking = player.walking
	crouching = gatherInput.crouching
	
	attacking = player.attacking
	currentAttack = player.currentAttack
	
	jumping = player.jumping

	is_grounded = raycasts.is_grounded
	
func _play_attack_animations(last_move_direction):
	if not player.attacking:
		return
	
	if sword_hitbox.area_entered == null:
		return
	
	if swordBlood_timeOut.time_left > 0:
		swordBlood.emitting = false
		return
	else:
		swordBlood_timeOut.start()

	swordBlood.global_position = sword_hitbox.area_entered.global_position

	if last_move_direction > 0:
		swordBlood.scale.x = -1
	elif last_move_direction < 0:
		swordBlood.scale.x = 1

	swordBlood.emitting = true

func _play_animations(move_direction : float):
	## Switch of by default
	walkingDust.emitting = false
	if not move_direction == 0 and is_grounded: 
		walkingDust.emitting = true
	
	if is_grounded and not jumping:
		if move_direction == 0:
			if crouching:
				state_machine.travel("crouch")
			elif sword_out and not was_sword_out:
				state_machine.travel("sword_out")
			elif sword_out and was_sword_out:
				state_machine.travel("idle_sword")
			elif not sword_out and was_sword_out:
				state_machine.travel("sword_in")
			elif not sword_out and not was_sword_out:
				state_machine.travel("idle_normal")
		else:
			## Only if running
			if running:
				state_machine.travel("run")
			## Only if walking
			elif walking:
				state_machine.travel("walk")
	else:
		if not is_grounded and (gatherInput.just_jumped or gatherInput.jump):
			state_machine.travel("jump_mid_air")
		
	if attacking:
		if currentAttack == "air_sword_3":
			state_machine.travel("air_sword_3_loop")

			## Start to emit ghosts
			emitGhost = true
			ghostTimer.start()
		elif currentAttack == "air_sword_3_end":
			emitGhost = false

			state_machine.travel("air_sword_3_end")

				## add impact by shaking the screen
				## Duration, frequency, amplitude, priority
				#camera.ScreenShake.start(0.3, 15, 10, 1)
		else:
			state_machine.travel(currentAttack)
	
func _rotate_player(move_direction : float):
	## Flip the sprite if going left
	if move_direction > 0:
		body.scale.x = abs(body.scale.x)
	elif move_direction < 0:
		body.scale.x = -abs(body.scale.x)

func _on_ghostTimer_timeout():
	if emitGhost:
		ghostTimer.start()
	
	var instance = ghost.instance()
	instance.scale.x = body.scale.x
	instance.texture = $"../Sprite".texture
	instance.position = player.position
	
	player.get_parent().add_child(instance)

		
