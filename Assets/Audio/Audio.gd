extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	$MixingDeskMusic.init_song("Song")
	$MixingDeskMusic.play("Song")
