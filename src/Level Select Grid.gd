extends GridContainer
const maxLevels = 10


func _ready():
	var level_tile = preload("res://src/Level Select Tile.tscn")
	for i in maxLevels:
		var instance = level_tile.instance()
		instance.set_name('level ' + str(i+1))
		instance.get_node('Level Text').set_text(str(i+1))
		instance.level = i+1
		add_child(instance)
	pass
	
