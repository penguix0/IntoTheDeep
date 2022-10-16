extends Area2D

var area_entered
onready var collisionShape = $CollisionPolygon2D
## Only name of object this script should save
var area_name = "hurtbox"

## Save and delete the current entered hitbox
func _on_sword_hitbox_area_entered(area):
	## Make sure the entered area is not the enemy itself
	if not area.get_parent() == get_parent() and area.name == "hurtbox":
		area_entered = area
	
func _on_sword_hitbox_area_exited(area):
	if area_entered == area:
		area_entered = null
		
func enable_hitbox():
	collisionShape.disabled = false
	
func disable_hitbox():
	collisionShape.disabled = true
