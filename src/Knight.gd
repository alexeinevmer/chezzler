extends Piece

func init_piece(prefix,posX,posY):
	isJumper = true # does this piece jump over other pieces in its way
	isIced = false #does this piece move in a direction until it hits the board edge or another piece
	isMainPiece = false #is this the piece that needs to reach the goal
	Position = [int(posX),int(posY)] #x,y
	if prefix == 'f':
		isPlayer = true 
		MovementX = [1,-1,1,-1,2,-2,2,-2] #dx,dx2
		MovementY = [2,2,-2,-2,1,1,-1,-1] #dy,dy2
		AttackX = [1,-1,1,-1,2,-2,2,-2] #dx,dx2
		AttackY = [2,2,-2,-2,1,1,-1,-1] #dy,dy2
		add_to_group("Friendly")
	else:
		isPlayer = false
		AttackX = [1,-1,1,-1,2,-2,2,-2] #dx,dx2
		AttackY = [2,2,-2,-2,1,1,-1,-1] #dy,dy2
		add_to_group("Enemy")
