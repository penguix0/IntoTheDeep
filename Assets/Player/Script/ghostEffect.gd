extends Particles2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.emitting:
		self.texture = $"../Sprite".texture
