extends MarginContainer



func _on_PLAY_pressed():
	#get_tree().change_scene("res://src/GameBoard.tscn")
	get_node("/root/Main Menu/Popup").popup()
	pass # Replace with function body.
