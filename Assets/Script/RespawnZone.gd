extends Area2D

export(Vector2) var respawnPoint

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	respawnPoint = $RespawnPoint.global_position
	$RespawnPoint.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RespawnZone_body_entered(body):
	if body.name == "Player":
		body.position = respawnPoint
