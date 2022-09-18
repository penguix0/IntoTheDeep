extends Sprite

onready var player = $"../.."

func sprite_to_polygon() -> void:
	var data = texture.get_data()
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(data)
	
	var polys = bitmap.opaque_to_polygons(
		Rect2(
			Vector2.ZERO,
			texture.get_size()
		),
		1 ## Detail lower = better
	)

	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		player.add_child(collision_polygon)

		if centered:
			collision_polygon.position -= bitmap.get_size()/2
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	sprite_to_polygon()
