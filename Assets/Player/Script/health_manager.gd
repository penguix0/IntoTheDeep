extends Panel

var player
var health
var max_health
export(int) var hp_for_heart = 10
var hearts : float
var hearts_array = []
var texture_directory = "res://Assets/Sprite/Health/"
var full = "heart_full.png"
var half_full = "heart_half.png"
var empty = "heart_empty.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	
	## Calculate number of hearts for the player
	max_health = player.health
	health = max_health
	hearts = health / hp_for_heart
	hearts = floor(hearts)
	
	## Load textures
	full = load(texture_directory + full)
	half_full = load(texture_directory + half_full)
	empty = load(texture_directory + empty)
	
	## Add hearts to UI
	for heart in hearts:
		var instance = TextureRect.new()
		instance.texture = full
		
		$CenterContainer/list.add_child(instance)
		
		hearts_array.append(instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	## Update hearts
	if not player.health == health:
		## calculate health hearts left
		var full_hearts_left = floor(float(player.health) / float(hp_for_heart))

		## There can only b eone half heart left at the same time

		var empty_hearts_left = hearts-ceil(float(player.health) / float(hp_for_heart))
		
		var half_hearts_left = 0
		if not (full_hearts_left+empty_hearts_left) == hearts:
			half_hearts_left = 1
			
		## Asign texture to each heart
		var counter = 0
		for heart in hearts_array:
			heart.texture = full
			counter += 1
			
			if counter <= empty_hearts_left:
				heart.texture = empty
				
			elif half_hearts_left == 1:
				half_hearts_left = 0
				heart.texture = half_full
	
	## Update player health
	health = player.health
