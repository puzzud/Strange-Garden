extends Node
class_name BoardCell

enum CellAction {
	NONE = -1,
	ACTIVATE,
	DEACTIVATE,
	MOVE,
	ATTACK,
	USE
}

var content: BoardCellContent = null
var action: int = CellAction.NONE

func _ready():
	pass

func clear():
	content = null
	action = CellAction.NONE
