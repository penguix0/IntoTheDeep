extends VisibilityNotifier2D

var on_screen : bool = true

func _process(delta):
	on_screen = self.is_on_screen()
