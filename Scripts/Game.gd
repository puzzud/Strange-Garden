extends Node2D
class_name Game

var teamTurnIndex = 0

export(Array, Color) var teamColors

var activePiece: Piece

func _ready():
	Global.game = self
	
	initializeBoard()
	
	setTeamTurnIndex(teamTurnIndex)

func initializeBoard():
	$Board.clear()
	
	# Fill board with pieces based on their current location.
	for teamPieces in [$Pieces/Team1, $Pieces/Team2]:
		for piece in teamPieces.get_children():
			#print(teamPieces.name + ":" + piece.name)
			if !$Board.insertPiece(piece):
				printerr("Unable to insert piece into board: " + piece.name)
	
	#print($Board.cellContents)

func setTeamTurnIndex(teamTurnIndex: int):
	self.teamTurnIndex = teamTurnIndex
	
	$Cursor.modulate = getTeamColor(teamTurnIndex)
	
	$Board.overlayActivatablePieces(teamTurnIndex)

func getTeamColor(teamIndex: int) -> Color:
	var teamColor = teamColors[teamIndex]
	return teamColor

func onBoardCellHover(cellCoordinates: Vector2):
	if activePiece != null && activePiece.moving:
		return
	
	$Cursor.set_global_position($Board.getCellPosition(cellCoordinates) - Vector2(1.0, 1.0))
	
	$Cursor.visible = true
	
	#var cellContent = $Board.getCellContent(cellCoordinates)

func onBoardCellPress(cellCoordinates: Vector2):
	if activePiece != null && activePiece.moving:
		return
	
	var cellPiece = $Board.getCellContent(cellCoordinates)
	if cellPiece == null:
		if activePiece != null:
			# TODO: Can the active piece move to this cell?
			activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
			$Board.removePiece(activePiece)
			$Board.insertPiece(activePiece, cellCoordinates)
			return
		else:
			return
	else:
		if activePiece != null:
			if activePiece == cellPiece:
				activePiece.setActivated(false)
				activePiece = null
				return
			else:
				if cellPiece.teamIndex == activePiece.teamIndex:
					return
				else:
					# TODO: Can the active piece attack this cell?
					activePiece.attack(cellPiece)
					activePiece.moveToPosition($Board.getCellPosition(cellCoordinates) + activePiece.BoardCellOffset)
					$Board.removePiece(activePiece)
		else:
			if cellPiece.teamIndex == teamTurnIndex:
				cellPiece.setActivated(true)
				activePiece = cellPiece
				return

func processPieceAttackingPiece(attackingPiece, targetPiece):
	var cellCoordinates = $Board.getCellCoordinatesFromPiece(targetPiece)
	$Board.removePiece(targetPiece)
	targetPiece.queue_free()
	$Board.insertPiece(attackingPiece, cellCoordinates)

func endTurn():
	var nextTeamTurnIndex = teamTurnIndex + 1
	if nextTeamTurnIndex > 1:
		nextTeamTurnIndex = 0
	
	$Cursor.visible = false
	
	setTeamTurnIndex(nextTeamTurnIndex)

func onOkButtonPressed():
	endTurn()
