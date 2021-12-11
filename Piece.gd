extends Sprite

class_name Piece

#	Piece Encoding:
#	Prefixs:
#		j = jumper
#		i = iced
#		e = enemy piece
#		f = friendly piece
#		_ = no prefix
#	Piece Types:
#		m = main piece
#		p = pawn
#		b = bishop
#		k = kight
#		s = sentry (king type)
#		q = queen
#		r = rook


var isPlayer : bool = false #is piece friendly and therefore moveable
var isMainPiece : bool = false #is this the piece that needs to reach the goal
var isJumper : bool = false # does this piece jump over other pieces in its way
var isIced : bool = false #does this piece move in a direction until it hits the board edge or another piece
var Position = [0,0] #x,y
var MovementX = [0] #dx,dx2
var MovementY = [0] #dy,dy2
var AttackX = [0] #dx,dx2
var AttackY = [0] #dy,dy2
var PieceType = ''


func moveBlocked(move) -> bool: # returns true if move is blocked
	if isJumper:
		return false
	var piece_positions = get_node("/root/GameBoard/GUI").piece_pos
	var moveVector = [0,0]
	if move[0] != 0 : moveVector[0] = move[0] / abs(move[0])
	if move[1] != 0 : moveVector[1] = move[1] / abs(move[1])
	if moveVector[0] == 0:
		for i in range(1,abs(move[1])):
			if piece_positions[Position[0]][Position[1] + moveVector[1] * i] != null:
				return true
	elif moveVector[1] == 0:
		for i in range(1,abs(move[0])):
			if piece_positions[Position[0] + moveVector[0] * i][Position[1]] != null:
				return true
	else:
		for i in range(1,abs(move[0])):
			if piece_positions[Position[0] + moveVector[0] * i][Position[1] + moveVector[1] * i] != null:
				return true
	return false

func validIcedMove(move, boardSize) -> bool:
	if !isIced:
		return true
	if moveBlocked(move):
		return false
	elif Position[0] != boardSize-1 && Position[0] + move[0] == boardSize-1 : return true
	elif Position[0] != 0 && Position[0] + move[0] == 0 : return true
	elif Position[1] != boardSize-1 && Position[1] + move[1] == boardSize-1 : return true
	elif Position[1] != 0 && Position[1] + move[1] == 0 : return true
	elif get_node("/root/GameBoard/GUI").piece_pos[Position[0] + move[0]][Position[1] + move[1]] == null:
		var oneOverX = Position[0] + move[0]
		var oneOverY = Position[1] + move[1]
		if move[0] != 0:
			oneOverX = Position[0] + move[0] + int(move[0]/abs(move[0]))
		if move[1] != 0:
			oneOverY = Position[1] + move[1] + int(move[1]/abs(move[1]))
		if get_node("/root/GameBoard/GUI").piece_pos[oneOverX][oneOverY] == null:
			return false
		else: return true
	return true

func validMove(newPosition,boardSize) -> bool:
	if MovementX.empty():
		return false
	var move = [0,0]
	move[0] = newPosition[0]-Position[0]
	move[1] = newPosition[1]-Position[1]
	if newPosition[0] > boardSize or newPosition[0] < 0:
		return false
	elif newPosition[1] > boardSize or newPosition[1] <0:
		return false
	if moveBlocked(move):
		return false
	if !validIcedMove(move,boardSize):
		return false
	var validMove : bool = false
	var occupyingPiece = get_node("/root/GameBoard/GUI").piece_pos[newPosition[0]][newPosition[1]]
	#check if attack is valid
	if occupyingPiece != null: 
		if isPlayer && occupyingPiece.PieceType[0] == 'e':
			for n in AttackX.size():
				if move[0] == AttackX[n]:
					if move[1] == AttackY[n]:
						validMove = true
						break
		elif PieceType[0] == 'e' && occupyingPiece.isPlayer:
			for n in AttackX.size():
				if move[0] == AttackX[n]:
					if move[1] == AttackY[n]:
						validMove = true
						break
	if validMove : 
		return true
	#check if move is valid
	elif occupyingPiece == null:
		for n in MovementX.size():
			if move[0] == MovementX[n]: # movement in X is valid
				if move[1] == MovementY[n]: # movement in Y is also valid
					validMove = true
					break
	if validMove :
		return true
		
	return false

func movePiece(newPosition,boardSize) -> bool: 
	if validMove(newPosition,boardSize):
		var occupyingPiece = get_node("/root/GameBoard/GUI").piece_pos[newPosition[0]][newPosition[1]]
		if occupyingPiece == null:
			get_node("/root/GameBoard/GUI").stored_movementCaptured.push_back(null)
		elif isPlayer &&  occupyingPiece.PieceType[0] == 'e':
			occupyingPiece.visible = false
			get_node("/root/GameBoard/GUI").stored_movementCaptured.push_back(occupyingPiece)
			get_node("/root/GameBoard/GUI").piece_pos[newPosition[0]][newPosition[1]] = null
		elif occupyingPiece.isPlayer && PieceType[0] =='e':
			get_node("/root/GameBoard/GUI").stored_movementCaptured.push_back(occupyingPiece)
			occupyingPiece.visible = false
			get_node("/root/GameBoard/GUI").piece_pos[newPosition[0]][newPosition[1]] = null
		get_node("/root/GameBoard/GUI").piece_pos[newPosition[0]][newPosition[1]] = get_node("/root/GameBoard/GUI").piece_pos[Position[0]][Position[1]]
		get_node("/root/GameBoard/GUI").piece_pos[Position[0]][Position[1]] = null
		Position = newPosition
		return true
	return false
