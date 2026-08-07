import re

with open('lib/src/features/game/domain/entities/sudoku_board.dart', 'r') as f:
    content = f.read()

content = content.replace(
    "final sgIndex = (row ~/ subGridRows) * (size ~/ subGridCols) + (col ~/ subGridCols);",
    "final sgIndex = (row ~/ subGridRows) * (gridSize ~/ subGridCols) + (col ~/ subGridCols);"
)
content = content.replace(
    "final sgIndex = (cell.row ~/ subGridRows) * (size ~/ subGridCols) + (cell.col ~/ subGridCols);",
    "final sgIndex = (cell.row ~/ subGridRows) * (size ~/ subGridCols) + (cell.col ~/ subGridCols);"
)

with open('lib/src/features/game/domain/entities/sudoku_board.dart', 'w') as f:
    f.write(content)
