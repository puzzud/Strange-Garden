extends Node2D
class_name Board

signal cellHover(cellCoordinates)
signal cellPress(cellCoordinates)

const CellDimensions := Vector2(16.0, 16.0)

const TileMapOffset := Vector2(8.0, 8.0)

var cellContents = [
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null],
	[null, null, null, null, null, null, null, null]
]

var cellOverlays = [
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1],
	[-1, -1, -1, -1, -1, -1, -1, -1]
]

var lightBlueTileIndex: int

func _ready():
	var cellsOverlayTileMap = $CellsOverlay
	var cellsOverlayTileSet = cellsOverlayTileMap.tile_set
	lightBlueTileIndex = cellsOverlayTileSet.find_tile_by_name("GroundLightBlue")
	
	clearOverlayData()
	refreshOverlay()

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

func clear():
	for row in cellContents:
		for x in range(0, row.size()):
			row[x] = null

func getCellContent(cellCoordinates: Vector2):
	# TODO: Do bound checking.
	
	return cellContents[cellCoordinates.y][cellCoordinates.x]

func clearCell(cellCoordinates):
	cellContents[cellCoordinates.y][cellCoordinates.x] = null

func insertPiece(piece: Piece, cellCoordinates = null):
	if cellCoordinates == null:
		cellCoordinates = getCellCoordinatesFromPiecePosition(piece)
	
	if cellCoordinates == null:
		return false
	
	cellContents[cellCoordinates.y][cellCoordinates.x] = piece
	
	return true

func removePiece(piece: Piece):
	var cellCoordinates = getCellCoordinatesFromPiece(piece)
	if cellCoordinates != null:
		clearCell(cellCoordinates)

func getCellPosition(cellCoordinates: Vector2):
	return global_position + TileMapOffset + (cellCoordinates * CellDimensions) - Vector2(1.0, 1.0)

func getCellCoordinatesFromPosition(position: Vector2):
	var cellCoordinates = Vector2()
	
	var cellFirstPosition = global_position + TileMapOffset
	
	cellCoordinates.x = int((position.x - cellFirstPosition.x) / CellDimensions.x)
	if cellCoordinates.x < 0 || cellCoordinates.x >= 8:
		return null
	
	cellCoordinates.y = int((position.y - cellFirstPosition.y) / CellDimensions.y)
	if cellCoordinates.y < 0 || cellCoordinates.y >= 8:
		return null
	
	return cellCoordinates

func getCellCoordinatesFromPiecePosition(piece: Piece):
	return getCellCoordinatesFromPosition(piece.global_position)

func getCellCoordinatesFromPiece(piece: Piece):
	for y in range(0, cellContents.size()):
		var row = cellContents[y]
		for x in range(0, row.size()):
			if row[x] == piece:
				return Vector2(x, y)
	
	return null

func clearOverlayData():
	for y in range(0, cellOverlays.size()):
		var row = cellOverlays[y]
		for x in range(0, row.size()):
			row[x] = -1

func refreshOverlay():
	for y in range(0, cellOverlays.size()):
		var row = cellOverlays[y]
		for x in range(0, row.size()):
			$CellsOverlay.set_cell(x, y, row[x])

func overlayActivatablePieces(teamIndex):
	#clearOverlayData()
	
	for y in range(0, cellContents.size()):
		var row = cellContents[y]
		for x in range(0, row.size()):
			var piece: Piece = row[x]
			if piece == null:
				cellOverlays[y][x] = -1
			else:
				if piece.teamIndex == teamIndex:
					cellOverlays[y][x] = lightBlueTileIndex
				else:
					cellOverlays[y][x] = -1
	
	refreshOverlay()
