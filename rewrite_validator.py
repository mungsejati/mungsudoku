import re

with open('lib/src/features/game/domain/services/sudoku_validator.dart', 'r') as f:
    content = f.read()

content = content.replace(
    "final startRow = (row ~/ board.subGridSize) * board.subGridSize;",
    "final startRow = (row ~/ board.subGridRows) * board.subGridRows;"
)
content = content.replace(
    "final startCol = (col ~/ board.subGridSize) * board.subGridSize;",
    "final startCol = (col ~/ board.subGridCols) * board.subGridCols;"
)
content = content.replace(
    "for (var r = startRow; r < startRow + board.subGridSize; r++) {",
    "for (var r = startRow; r < startRow + board.subGridRows; r++) {"
)
content = content.replace(
    "for (var c = startCol; c < startCol + board.subGridSize; c++) {",
    "for (var c = startCol; c < startCol + board.subGridCols; c++) {"
)
content = content.replace(
    "final sgIndex = (row ~/ board.subGridSize) * board.subGridSize + (col ~/ board.subGridSize);",
    "final sgIndex = (row ~/ board.subGridRows) * (board.gridSize ~/ board.subGridCols) + (col ~/ board.subGridCols);"
)

with open('lib/src/features/game/domain/services/sudoku_validator.dart', 'w') as f:
    f.write(content)
