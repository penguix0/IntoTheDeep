extends Area2D

export(Vector2) var respawnPoint

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RespawnZone_body_entered(body):
	print ("deze kleurplaat")
	body.position = respawnPoint
