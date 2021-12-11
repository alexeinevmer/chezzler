extends TextureRect

var level = 0




func _on_Level_Select_Tile_gui_input(event):
	if event.is_pressed():
		global.level = level
		get_tree().change_scene("res://src/GameBoard.tscn")
	pass # Replace with function body.
