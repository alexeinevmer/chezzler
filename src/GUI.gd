extends MarginContainer
tool

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level : int = 1
var moves : int = 0
var par : int = 0
var boardSize : int = 0
var squareSize = 0
var goal_pos = [0,0]
var boardPositionsX = [[]]
var boardPositionsY = [[]]
var boardIndex = [[]]
var boardShortHand = 0
var piece_pos = [[]]
var stored_piece_pos = [[]]
var stored_movementX = []
var stored_movementY = []
var stored_movementPiece = []
var stored_movementCaptured = []
var tile_set = 1
var restarting_flag : bool = true
var selected_piece = 0
var piece_active : bool = false
var boardOffset = 0

onready var popup_node = get_node("/root/GameBoard/Level Done Popup")
onready var popup_help_node = get_node("/root/GameBoard/Help Popup")


const levelPath = "res://src/Levels"
const BASEPIECESPRITESIZE = 100
const maxLevels = 3

func get_press_position(positionData):
	var indexData = [null,null]
	indexData[0] = int(positionData[0]/squareSize)
	indexData[1] = int(positionData[1]/squareSize)
	return indexData

func _generate_level():
	var data = File.new()
	var path = levelPath.plus_file("L" + String(level).pad_zeros(3) + ".txt")
	data.open(path,File.READ)
	var i = 1
	var board_node = get_node("Background/Seperator1/GameboardBackground")
	while not data.eof_reached():
		var line = data.get_line().strip_escapes()
		if "#" in line:
			var erase_index = line.find("#",0)
			line.erase(erase_index,line.length()-erase_index)
		if line.length() > 1:
			match i:
				1:
					par = int(line)
				2:
					boardSize = int(line)
					_generate_board_piece_array()
				_:
					match line[1]: # check piece type
						"m":
							stored_piece_pos[ int(line[3])][ int(line[5])] = get_node("../Player")
							piece_pos[ int(line[3])][ int(line[5])] = get_node("../Player")
							get_node("../Player").PieceType = line[0]+line[1]
							_setup_main_piece(line,get_node("../Player"))
						"p":
							var piece_node = Sprite.new()
							piece_node.set_script(load("res://src/Pawn.gd"))
							piece_node.init_piece(line[0],line[3],line[5])
							piece_node.set_texture(load("res://Assets/TileSet/Base/PawnPiece.png"))
							board_node.add_child(piece_node)
							piece_node.PieceType = line[0]+line[1]
							stored_piece_pos[ int(line[3])][ int(line[5])] = piece_node
							piece_pos[ int(line[3])][ int(line[5])] = piece_node
						"b":
							var piece_node = Sprite.new()
							piece_node.set_script(load("res://src/Bishop.gd"))
							piece_node.init_piece(line[0],line[3],line[5])
							piece_node.set_texture(load("res://Assets/TileSet/Base/BishopPiece.png"))
							board_node.add_child(piece_node)
							piece_node.PieceType = line[0]+line[1]
							stored_piece_pos[ int(line[3])][ int(line[5])] = piece_node
							piece_pos[ int(line[3])][ int(line[5])] = piece_node
						"k":
							var piece_node = Sprite.new()
							piece_node.set_script(load("res://src/Knight.gd"))
							piece_node.init_piece(line[0],line[3],line[5])
							piece_node.set_texture(load("res://Assets/TileSet/Base/KnightPiece.png"))
							board_node.add_child(piece_node)
							piece_node.PieceType = line[0]+line[1]
							stored_piece_pos[ int(line[3])][ int(line[5])] = piece_node
							piece_pos[ int(line[3])][ int(line[5])] = piece_node
						"s":
							var piece_node = Sprite.new()
							piece_node.set_script(load("res://src/Sentry.gd"))
							piece_node.init_piece(line[0],line[3],line[5])
							piece_node.set_texture(load("res://Assets/TileSet/Base/KingPiece.png"))
							board_node.add_child(piece_node)
							piece_node.PieceType = line[0]+line[1]
							stored_piece_pos[ int(line[3])][ int(line[5])] = piece_node
							piece_pos[ int(line[3])][ int(line[5])] = piece_node
						"q":
							var piece_node = Sprite.new()
							piece_node.set_script(load("res://src/Queen.gd"))
							piece_node.init_piece(line[0],line[3],line[5])
							piece_node.set_texture(load("res://Assets/TileSet/Base/QueenPiece.png"))
							board_node.add_child(piece_node)
							piece_node.PieceType = line[0]+line[1]
							stored_piece_pos[ int(line[3])][ int(line[5])] = piece_node
							piece_pos[ int(line[3])][ int(line[5])] = piece_node
						"r":
							var piece_node = Sprite.new()
							piece_node.set_script(load("res://src/Rook.gd"))
							piece_node.init_piece(line[0],line[3],line[5])
							piece_node.set_texture(load("res://Assets/TileSet/Base/RookPiece.png"))
							board_node.add_child(piece_node)
							piece_node.PieceType = line[0]+line[1]
							stored_piece_pos[ int(line[3])][ int(line[5])] = piece_node
							piece_pos[ int(line[3])][ int(line[5])] = piece_node
						"g":
							goal_pos[0] = int(line[3])
							goal_pos[1] = int(line[5])
			i += 1
	data.close()

func _generate_board_piece_array():
	piece_pos = [[]]
	piece_pos.resize(boardSize)
	stored_piece_pos = [[]]
	stored_piece_pos.resize(boardSize)
	for i in boardSize:
		piece_pos[i] = []
		piece_pos[i].resize(boardSize)
		stored_piece_pos[i] = []
		stored_piece_pos[i].resize(boardSize)
		for j in boardSize:
			piece_pos[i][j] = null
			stored_piece_pos[i][j] = null

func _setup_main_piece(line,player_node):
	player_node.isPlayer = true
	player_node.isMainPiece = true
	player_node.AttackX = []
	player_node.AttackY = []
	player_node.MovementX = []
	player_node.MovementY = [] 
	match line[0]:
		'j':
			player_node.isJumper = true
		'i':
			player_node.isIced = true
		_:
			player_node.isJumper = false
			player_node.isIced = false
	player_node.Position = [int(line[3]),int(line[5])]
	line.erase(0,6)
	while line.length() > 1:
		if line[0] == ',':
			if line[1] == '-':
				player_node.MovementX.append(-int(line[2]))
				line.erase(0,4)
			else:
				player_node.MovementX.append(int(line[1]))
				line.erase(0,3)
			if line[0] == '-':
				player_node.MovementY.append(-int(line[1]))
				line.erase(0,2)
			else:
				player_node.MovementY.append(int(line[0]))
				line.erase(0,1)
		elif line[0] == ';':
			break
		else:
			print("level data error")
	while line.length() > 1:
		if line[1] == '-':
			player_node.AttackX.append(-int(line[2]))
			line.erase(0,4)
		else:
			player_node.AttackX.append(int(line[1]))
			line.erase(0,3)
		if line[0] == '-':
			player_node.AttackY.append(-int(line[1]))
			line.erase(0,2)
		else:
			player_node.AttackY.append(int(line[0]))
			line.erase(0,1)

func _generate_grid():
	var board_node = get_node("Background/Seperator1/GameboardBackground/GameBoard")
	for child in board_node.get_children():
		child.queue_free()
		board_node.remove_child(child)
	board_node.columns = boardSize
	var b_or_w = 0 # 1 for black, 0 for white
	for i in boardSize:
		for j in boardSize:
			var new_tile = TextureRect.new()
			if b_or_w:
				new_tile.set_texture(load("res://Assets/TileSet/Base/TileBlack.png"))
				b_or_w = 0
			else:
				new_tile.set_texture(load("res://Assets/TileSet/Base/TileWhite.png"))
				b_or_w = 1
			new_tile.set("size_flags_horizontal",3)
			new_tile.set("size_flags_vertical",3)
			new_tile.set_expand(true)
			board_node.add_child(new_tile)
		if (boardSize+1) % 2:
			if b_or_w:
				b_or_w = 0
			else:
				b_or_w = 1
	
	pass

func _restart_level():
	stored_movementX = []
	stored_movementY = []
	stored_movementPiece = []
	stored_movementCaptured = []
	moves = 0
	selected_piece = 0
	piece_active = false
	_clearAttackMove()
	_update_move_counter()
	_update_level_counter()
	var goal_offset = get_node("Background/Seperator1/GameboardBackground").get_global_position()
	for i in boardSize:
		for j in boardSize:
			piece_pos[i][j] = stored_piece_pos[i][j]
			if !stored_piece_pos[i][j]:
				continue
			elif stored_piece_pos[i][j].PieceType[1] == 'm':
				piece_pos[i][j].Position = [i,j]
				piece_pos[i][j].visible = true
				piece_pos[i][j].position[0] = squareSize * i + boardOffset[0] + squareSize/float(2)
				piece_pos[i][j].position[1] = squareSize * j + boardOffset[1] + squareSize/float(2)
			else:
				piece_pos[i][j].visible = true
				piece_pos[i][j].Position = [i,j]
				piece_pos[i][j].position[0] = squareSize * i + (boardOffset[0] - goal_offset[0]) + squareSize/float(2)
				piece_pos[i][j].position[1] = squareSize * j + (boardOffset[1] - goal_offset[1]) + squareSize/float(2)

func _update_move_counter():
	var counter_node = get_node("Background/Seperator1/TopTools/Top Bar/MovesCounter/Move Number")
	counter_node.set("text",String(moves))

func _update_level_counter():
	var level_node = get_node("Background/Seperator1/TopTools/Top Bar/Level Info/Level Number")
	level_node.set("text",String(level))

func _get_board_positions():
	boardShortHand = get_node("Background/Seperator1/GameboardBackground/GameBoard")
	squareSize = boardShortHand.get_child(0).get("rect_size")[0]
	boardOffset = boardShortHand.get_global_position()
	boardPositionsX.resize(boardSize)
	boardPositionsY.resize(boardSize)
	boardIndex.resize(boardSize)
	for i in boardSize :
		boardPositionsX[i] = []
		boardPositionsY[i] = []
		boardIndex[i] = []
		boardPositionsX[i].resize(boardSize)
		boardPositionsY[i].resize(boardSize)
		boardIndex[i].resize(boardSize)
		for j in boardSize :
			var n = j*boardSize + i
			boardIndex[i][j] = n
			var tempPositions = boardShortHand.get_child(n).get("rect_position")
			boardPositionsX[i][j] = tempPositions[0]
			boardPositionsY[i][j] = tempPositions[1]
	
func _updatePiecePosition():
	if selected_piece.isMainPiece:
		selected_piece.position[0] = squareSize * selected_piece.Position[0] + boardOffset[0] + squareSize/2
		selected_piece.position[1] = squareSize * selected_piece.Position[1] + boardOffset[1] + squareSize/2
	else:
		var goal_offset = get_node("Background/Seperator1/GameboardBackground").get_global_position()
		selected_piece.position[0] = squareSize * selected_piece.Position[0] + boardOffset[0] - goal_offset[0] + squareSize/2
		selected_piece.position[1] = squareSize * selected_piece.Position[1] + boardOffset[1] - goal_offset[1] + squareSize/2
	if selected_piece.isPlayer:
		moves += 1
		_update_move_counter()

func _drawMove():
	var board_node = get_node("Background/Seperator1/GameboardBackground")
	for numMoves in selected_piece.MovementX.size():
		var moveX = selected_piece.MovementX[numMoves] + selected_piece.Position[0]
		var moveY = selected_piece.MovementY[numMoves] + selected_piece.Position[1]
		if moveX >= boardSize || moveX < 0 || moveY >= boardSize || moveY < 0:
			continue
		var new_tile = TextureRect.new()
		new_tile.set_texture(load("res://Assets/TileSet/Base/TileMove.png"))
		board_node.add_child(new_tile)
		new_tile.add_to_group("HintHighlights")
		var tile_offset = get_node("Background/Seperator1/GameboardBackground").get_global_position()
		new_tile.rect_position[0] = moveX * squareSize + (boardOffset[0] - tile_offset[0])
		new_tile.rect_position[1] = moveY * squareSize + (boardOffset[1] - tile_offset[1])
		new_tile.rect_scale[0] = float(squareSize) / BASEPIECESPRITESIZE
		new_tile.rect_scale[1] = new_tile.rect_scale[0]
		new_tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		new_tile.modulate[3] = float(220)/255
		if selected_piece.validMove([moveX,moveY],boardSize):
			new_tile.modulate[0] = float(55)/255
			new_tile.modulate[1] = float(210)/255
			new_tile.modulate[2] = float(55)/255
		else:
			new_tile.modulate[0] = float(155)/255
			new_tile.modulate[1] = float(155)/255
			new_tile.modulate[2] = float(155)/255

func _drawAttack():
	var board_node = get_node("Background/Seperator1/GameboardBackground")
	for numAttacks in selected_piece.AttackX.size():
		var attackX = selected_piece.AttackX[numAttacks] + selected_piece.Position[0]
		var attackY = selected_piece.AttackY[numAttacks] + selected_piece.Position[1]
		if attackX >= boardSize || attackX < 0 || attackY >= boardSize || attackY < 0:
			continue
		var new_tile = TextureRect.new()
		new_tile.set_texture(load("res://Assets/TileSet/Base/TileAttack.png"))
		board_node.add_child(new_tile)
		new_tile.add_to_group("HintHighlights")
		var tile_offset = get_node("Background/Seperator1/GameboardBackground").get_global_position()
		new_tile.rect_position[0] = attackX * squareSize + (boardOffset[0] - tile_offset[0])
		new_tile.rect_position[1] = attackY * squareSize + (boardOffset[1] - tile_offset[1])
		new_tile.rect_scale[0] = float(squareSize) / BASEPIECESPRITESIZE
		new_tile.rect_scale[1] = new_tile.rect_scale[0]
		new_tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		new_tile.modulate[3] = float(220)/255
		if selected_piece.validMove([attackX,attackY],boardSize):
			new_tile.modulate[0] = float(210)/255
			new_tile.modulate[1] = float(55)/255
			new_tile.modulate[2] = float(55)/255
		else:
			new_tile.modulate[0] = float(155)/255
			new_tile.modulate[1] = float(155)/255
			new_tile.modulate[2] = float(155)/255

func _clearAttackMove():
	var board_node = get_node("Background/Seperator1/GameboardBackground")
	for child in get_tree().get_nodes_in_group("HintHighlights"):
		child.queue_free()
		board_node.remove_child(child)

func _board_init():
	get_node("../Player").scale[0] = float(squareSize) / BASEPIECESPRITESIZE
	get_node("../Player").scale[1] = float(squareSize) / BASEPIECESPRITESIZE
	get_node("Background/Seperator1/GameboardBackground/GoalOutline").scale[0] = float(squareSize) / BASEPIECESPRITESIZE
	get_node("Background/Seperator1/GameboardBackground/GoalOutline").scale[1] = float(squareSize) / BASEPIECESPRITESIZE
	var goal_offset = get_node("Background/Seperator1/GameboardBackground").get_global_position()
	get_node("Background/Seperator1/GameboardBackground/GoalOutline").position[0] = goal_pos[0] * squareSize + (boardOffset[0] - goal_offset[0])
	get_node("Background/Seperator1/GameboardBackground/GoalOutline").position[1] = goal_pos[1] * squareSize + (boardOffset[1] - goal_offset[1])
	for child in get_tree().get_nodes_in_group("Friendly"):
		child.position[0] = child.Position[0] * squareSize + (boardOffset[0] - goal_offset[0]) + squareSize/float(2)
		child.position[1] = child.Position[1] * squareSize + (boardOffset[1] - goal_offset[1]) + squareSize/float(2)
		child.scale[0] = float(squareSize) / BASEPIECESPRITESIZE
		child.scale[1] = float(squareSize) / BASEPIECESPRITESIZE
		child.modulate[0] = float(220)/255
		child.modulate[1] = float(180)/255
	for child in get_tree().get_nodes_in_group("Enemy"):
		child.position[0] = child.Position[0] * squareSize + (boardOffset[0] - goal_offset[0]) + squareSize/float(2)
		child.position[1] = child.Position[1] * squareSize + (boardOffset[1] - goal_offset[1]) + squareSize/float(2)
		child.scale[0] = float(squareSize) / BASEPIECESPRITESIZE
		child.scale[1] = float(squareSize) / BASEPIECESPRITESIZE
		child.modulate[1] = float(185)/255
		child.modulate[2] = float(85)/255

func _check_goal_reached() -> bool:
	if selected_piece.isMainPiece:
		if selected_piece.Position[0] == goal_pos[0] && selected_piece.Position[1] == goal_pos[1]:
			return true
	return false

func _check_enemy_capture() -> bool:
	for child in get_tree().get_nodes_in_group("Enemy"):
		var tempStored_movementX = child.Position[0]
		var tempStored_movementY = child.Position[1]
		if piece_pos[child.Position[0]][child.Position[1]] != child:
			continue
		if child.movePiece(selected_piece.Position,boardSize):
			selected_piece = child
			stored_movementX.push_back(tempStored_movementX)
			stored_movementY.push_back(tempStored_movementY)
			stored_movementPiece.push_back(child)
			_updatePiecePosition()
			piece_active = false
			return true
	return false

func _clear_level():
	# clear pieces
	piece_pos.clear()
	stored_piece_pos.clear()
	var board_node = get_node("Background/Seperator1/GameboardBackground")
	for child in get_tree().get_nodes_in_group("Friendly"):
		child.queue_free()
		board_node.remove_child(child)
	for child in get_tree().get_nodes_in_group("Enemy"):
		child.queue_free()
		board_node.remove_child(child)
	stored_movementX = []
	stored_movementY = []
	stored_movementPiece = []
	stored_movementCaptured = []
	# clear game grid

# Called when the node enters the scene tree for the first time.
func _ready():
	level = global.level
	_generate_level()
	_generate_grid()
	yield(get_tree(), "idle_frame")
	_get_board_positions()
	_board_init()
	_restart_level()

	pass # Replace with function body.

func _on_GameBoard_gui_input(event):
	if event.is_pressed():
		var shhsh = 1.0
		shhsh = get_press_position(event.get("position"))
		if piece_active:
			if selected_piece == piece_pos[shhsh[0]][shhsh[1]]:
				piece_active = false
				selected_piece = null
				_clearAttackMove()
			else:
				var tempStored_movementX = selected_piece.Position[0]
				var tempStored_movementY = selected_piece.Position[1]
				if selected_piece.isPlayer && selected_piece.movePiece(shhsh,boardSize):
					stored_movementX.push_back(tempStored_movementX)
					stored_movementY.push_back(tempStored_movementY)
					stored_movementPiece.push_back(selected_piece)
					_updatePiecePosition()
					_clearAttackMove()
					if _check_enemy_capture():
						return
					if _check_goal_reached():
						popup_node.popup()
						return
					else:
						_drawMove()
						_drawAttack()
				elif piece_pos[shhsh[0]][shhsh[1]] != null:
					piece_active = true
					selected_piece = piece_pos[shhsh[0]][shhsh[1]]
					_clearAttackMove()
					if selected_piece.PieceType[0] != 'e':
						_drawMove()
					_drawAttack()
				else:
					piece_active = false
					selected_piece = null
					_clearAttackMove()
		elif piece_pos[shhsh[0]][shhsh[1]] != null:
			piece_active = true
			selected_piece = piece_pos[shhsh[0]][shhsh[1]]
			_clearAttackMove()
			if selected_piece.PieceType[0] != 'e':
				_drawMove()
			_drawAttack()

func _on_ContinueButton_gui_input(event):
	if event.is_pressed():
		if level >= maxLevels:
			level = 1
		else:
			level = level + 1
		_clear_level()
		_generate_level()
		_generate_grid()
		yield(get_tree(), "idle_frame")
		_get_board_positions()
		_board_init()
		_restart_level()
		popup_node.hide()

func _on_UndoBacking_gui_input(event):
	if event.is_pressed():
		if stored_movementPiece.empty():
			return
		_undoBacking_support_function()
		if !selected_piece.isPlayer:
			_undoBacking_support_function()
		moves -= 1
		_update_move_counter()
		_clearAttackMove()
		piece_active = false

func _undoBacking_support_function():
	selected_piece = stored_movementPiece.pop_back()
	piece_pos[selected_piece.Position[0]][selected_piece.Position[1]] = null
	selected_piece.Position[0] = stored_movementX.pop_back()
	selected_piece.Position[1] = stored_movementY.pop_back()
	piece_pos[selected_piece.Position[0]][selected_piece.Position[1]] = selected_piece
	
	if selected_piece.isMainPiece:
		selected_piece.position[0] = squareSize * selected_piece.Position[0] + boardOffset[0] + squareSize/2
		selected_piece.position[1] = squareSize * selected_piece.Position[1] + boardOffset[1] + squareSize/2
	else:
		var goal_offset = get_node("Background/Seperator1/GameboardBackground").get_global_position()
		selected_piece.position[0] = squareSize * selected_piece.Position[0] + boardOffset[0] - goal_offset[0] + squareSize/2
		selected_piece.position[1] = squareSize * selected_piece.Position[1] + boardOffset[1] - goal_offset[1] + squareSize/2
	
	var temp_storedMovementCaptured = stored_movementCaptured.pop_back()
	if temp_storedMovementCaptured != null:
		temp_storedMovementCaptured.visible = true
		piece_pos[temp_storedMovementCaptured.Position[0]][temp_storedMovementCaptured.Position[1]] = temp_storedMovementCaptured

func _on_RestartBacking_gui_input(event):
	if event.is_pressed():
		_restart_level()


func _on_Panel_gui_input(event):
	if event.is_pressed():
		_clear_level()
		get_tree().change_scene("res://src/Node2D.tscn")


func _on_helpIcon_gui_input(event):
	if event.is_pressed():
		popup_help_node.popup()


func _on_Help_Popup_Exit_gui_input(event):
	if event.is_pressed():
		popup_help_node.visible = false
