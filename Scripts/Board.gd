extends Node2D
class_name Board

signal cellHover(cellCoordinates)
signal cellPress(cellCoordinates)

export(Vector2) var dimensions = Vector2(8, 8)

var cells = []

const cellActionOverlayTileNameTable = {
	BoardCell.CellAction.NONE: "",
	BoardCell.CellAction.ACTIVATE: "GroundLightBlue",
	BoardCell.CellAction.DEACTIVATE: "GroundWhite",
	BoardCell.CellAction.MOVE: "GroundLightBlue",
	BoardCell.CellAction.ATTACK: "GroundRed",
	BoardCell.CellAction.USE: "GroundGreen"
}

func _ready():
	overlayCellActions()

func _input(event):
	if event is InputEventMouseMotion:
		var cellCoordinates = getCellCoordinatesFromPosition(event.global_position)
		if cellCoordinates != null:
			emit_signal("cellHover", cellCoordinates)
	elif event is InputEventMouseButton:
		var cellCoordinates = getCellCoordinatesFromPosition(event.global_position)
		if cellCoordinates != null:
			if event.pressed:
				emit_signal("cellPress", cellCoordinates)

func initialize():
	cells = []
	
# warning-ignore:unused_variable
	for y in range(0, dimensions.y):
		var row = []
		
# warning-ignore:unused_variable
		for x in range(0, dimensions.x):
			var newBoardCell = BoardCell.new()
			
			row.append(newBoardCell)
		
		cells.append(row)
	
	clear()

func clear():
	for row in cells:
		for x in range(0, row.size()):
			var cell: BoardCell = row[x]
			cell.clear()

func getAllCellContents():
	var cellContents = []
	
	for row in cells:
		for x in range(0, row.size()):
			var cell: BoardCell = row[x]
			if cell.content != null:
				cellContents.append(cell.content)
	
	return cellContents

func getCellContent(cellCoordinates: Vector2):
	# TODO: Do bound checking.
	
	return cells[cellCoordinates.y][cellCoordinates.x].content

func clearCell(cellCoordinates):
	var cell: BoardCell = cells[cellCoordinates.y][cellCoordinates.x]
	cell.clear()

func insertPiece(piece: Piece, cellCoordinates = null):
	if cellCoordinates == null:
		cellCoordinates = getCellCoordinatesFromPiecePosition(piece)
	
	if cellCoordinates == null:
		return false
	
	cells[cellCoordinates.y][cellCoordinates.x].content = piece.boardCellContent
	
	return true

func removePiece(piece: Piece):
	var cellCoordinates = getCellCoordinatesFromPiece(piece)
	if cellCoordinates != null:
		clearCell(cellCoordinates)

func getCellPosition(cellCoordinates: Vector2):
	return global_position + $Cells.position + (cellCoordinates * $Cells.cell_size) - Vector2(1.0, 1.0)

func getCellCoordinatesFromPosition(position: Vector2):
	var cellCoordinates = Vector2()
	
	var cellFirstPosition = global_position + $Cells.position
	
	cellCoordinates.x = int((position.x - cellFirstPosition.x) / $Cells.cell_size.x)
	cellCoordinates.y = int((position.y - cellFirstPosition.y) / $Cells.cell_size.y)
	
	if areCellCoordinatesOutOfBounds(cellCoordinates):
		return null
	
	return cellCoordinates

func getCellCoordinatesFromPiecePosition(piece: Piece):
	return getCellCoordinatesFromPosition(piece.global_position)

func getCellCoordinatesFromPiece(piece: Piece):
	for y in range(0, cells.size()):
		var row = cells[y]
		for x in range(0, row.size()):
			if row[x].content == piece.boardCellContent:
				return Vector2(x, y)
	
	return null

func getCellCoordinatesFromCellOffset(cellCoordinates: Vector2, cellOffset: Vector2):
	var offsetCellCoordinates = cellCoordinates + cellOffset
	
	if areCellCoordinatesOutOfBounds(offsetCellCoordinates):
		return null
	
	return offsetCellCoordinates
	
func areCellCoordinatesOutOfBounds(cellCoordinates: Vector2):
	# TODO: Make upper bounds actually use board dimensions.
	if cellCoordinates.x < 0 || cellCoordinates.x >= dimensions.x:
		return true
	
	if cellCoordinates.y < 0 || cellCoordinates.y >= dimensions.y:
		return true
	
	return false

func getCellOffsetFromDirection(direction: int) -> Vector2:
	var cellOffset = Vector2()
	
	if direction & Direction.FLAG_LEFT:
		cellOffset.x = cellOffset.x - 1
		
	if direction & Direction.FLAG_RIGHT:
		cellOffset.x = cellOffset.x + 1
	
	if direction & Direction.FLAG_UP:
		cellOffset.y = cellOffset.y - 1
	
	if direction & Direction.FLAG_DOWN:
		cellOffset.y = cellOffset.y + 1
	
	return cellOffset

func getCellAction(cellCoordinates: Vector2) -> int:
	return cells[cellCoordinates.y][cellCoordinates.x].action

func setCellAction(cellCoordinates: Vector2, cellAction: int):
	cells[cellCoordinates.y][cellCoordinates.x].action = cellAction

func clearCellActions():
	for y in range(0, cells.size()):
		var row = cells[y]
		for x in range(0, row.size()):
			row[x].action = BoardCell.CellAction.NONE

func overlayCellActions():
	for y in range(0, cells.size()):
		var row = cells[y]
		for x in range(0, row.size()):
			var tileIndex = -1
			var cellAction = row[x].action
			if cellAction != BoardCell.CellAction.NONE:
				if !cellActionOverlayTileNameTable.has(cellAction):
					printerr("No tile name for cell action: " + str(cellAction))
				else:
					tileIndex = $CellsOverlay.tile_set.find_tile_by_name(cellActionOverlayTileNameTable[cellAction])
					if tileIndex == -1:
						printerr("No tile name for cell action: " + str(cellAction))
			
			$CellsOverlay.set_cell(x, y, tileIndex)

func print():
	print("--------")
	
	for y in range(0, cells.size()):
		var line: String = ""
		var row = cells[y]
		for x in range(0, row.size()):
			var content = row[x].content
			if content == null:
				line += "."
			elif content is Wizard:
				if content.teamIndex == 0:
					line += "0"
				else:
					line += "1"
			elif content is Pawn:
				if content.teamIndex == 0:
					line += "o"
				else:
					line += "x"
		
		print(line)
	
	print("--------")
