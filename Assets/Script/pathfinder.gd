extends Node2D

var tilemap
var graph 
var cell_size : int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	graph = AStar2D.new()
	tilemap = find_parent("Main").find_node("TileMap")
	createMap()

func createMap():
	var cells = tilemap.get_used_cells()
	
	for cell in cells:
		var above = Vector2(cell[0], cell[1] - 1)
		
		if !(above in cells):
			var sprite = Sprite.new()
			sprite.texture = load("res://icon2.png")
			sprite.position = tilemap.map_to_world(above) + Vector2(cell_size/2, cell_size/2)
			
			add_child(sprite)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
