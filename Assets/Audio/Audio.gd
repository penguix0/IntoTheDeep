extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	$MixingDeskMusic.init_song("Song")
	$MixingDeskMusic.play("Song")

func _process(_delta):
	if Global.play_exciting:
		$MixingDeskMusic/Song/CoreContainer/melody.volume_db = -80
	else:
		$MixingDeskMusic/Song/CoreContainer/melody.volume_db = 0
		
	if Global.play_beat_at_higher_volume:
		$MixingDeskMusic/Song/CoreContainer/beat.volume_db = 3
	else:
		$MixingDeskMusic/Song/CoreContainer/beat.volume_db = 0

	if Global.player_dead: ## Fade de instrumten uit
		$MixingDeskMusic/Song/CoreContainer/melody.volume_db = -80
		$MixingDeskMusic/Song/CoreContainer/bass.volume_db = -80
		$MixingDeskMusic/Song/CoreContainer/beat.volume_db = -80
