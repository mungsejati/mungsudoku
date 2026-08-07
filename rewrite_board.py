import re

with open('lib/src/features/game/domain/entities/sudoku_board.dart', 'r') as f:
    content = f.read()

# Replace subGridSize with subGridRows and subGridCols
content = content.replace(
    "this.subGridSize = 3,", 
    "this.subGridRows = 3,\n    this.subGridCols = 3,"
)

content = content.replace(
    "assert(subGridSize >= 2, 'subGridSize must be at least 2.'),",
    "assert(subGridRows >= 2 && subGridCols >= 2, 'subGridRows and subGridCols must be at least 2.'),"
)

content = content.replace(
    "cells.length == subGridSize * subGridSize",
    "cells.length == subGridRows * subGridCols"
)

content = content.replace(
    "row.length == subGridSize * subGridSize",
    "row.length == subGridRows * subGridCols"
)

content = content.replace(
    "'cells must be a ${subGridSize * subGridSize}x${subGridSize * subGridSize} '\n          'grid for subGridSize=$subGridSize.',",
    "'cells must be a ${subGridRows * subGridCols}x${subGridRows * subGridCols} '\n          'grid for subGrid: ${subGridRows}x${subGridCols}.',"
)

content = content.replace(
    "final int subGridSize;",
    "final int subGridRows;\n  final int subGridCols;"
)

content = content.replace(
    "int get gridSize => subGridSize * subGridSize;",
    "int get gridSize => subGridRows * subGridCols;"
)

content = content.replace(
    "factory SudokuBoard.empty({int subGridSize = 3}) {",
    "factory SudokuBoard.empty({int subGridRows = 3, int subGridCols = 3}) {"
)

content = content.replace(
    "final size = subGridSize * subGridSize;",
    "final size = subGridRows * subGridCols;"
)

content = content.replace(
    "subGridSize: subGridSize,",
    "subGridRows: subGridRows,\n      subGridCols: subGridCols,"
)

content = content.replace(
    "final sgIndex = (r ~/ subGridSize) * subGridSize + (c ~/ subGridSize);",
    "final sgIndex = (r ~/ subGridRows) * (gridSize ~/ subGridCols) + (c ~/ subGridCols);"
)
content = content.replace(
    "final sgIndex = (row ~/ subGridSize) * subGridSize + (col ~/ subGridSize);",
    "final sgIndex = (row ~/ subGridRows) * (gridSize ~/ subGridCols) + (col ~/ subGridCols);"
)
content = content.replace(
    "final sgIndex = (cell.row ~/ subGridSize) * subGridSize + (cell.col ~/ subGridSize);",
    "final sgIndex = (cell.row ~/ subGridRows) * (size ~/ subGridCols) + (cell.col ~/ subGridCols);"
)


content = content.replace(
    "int subGridSize = 3,",
    "int subGridRows = 3,\n    int subGridCols = 3,"
)

content = content.replace(
    "final startRow = (row ~/ subGridSize) * subGridSize;",
    "final startRow = (row ~/ subGridRows) * subGridRows;"
)
content = content.replace(
    "final startCol = (col ~/ subGridSize) * subGridSize;",
    "final startCol = (col ~/ subGridCols) * subGridCols;"
)
content = content.replace(
    "for (var r = startRow; r < startRow + subGridSize; r++)",
    "for (var r = startRow; r < startRow + subGridRows; r++)"
)
content = content.replace(
    "for (var c = startCol; c < startCol + subGridSize; c++)",
    "for (var c = startCol; c < startCol + subGridCols; c++)"
)

content = content.replace(
    "int? subGridSize,",
    "int? subGridRows,\n    int? subGridCols,"
)

content = content.replace(
    "if (other is! SudokuBoard || other.subGridSize != subGridSize) return false;",
    "if (other is! SudokuBoard || other.subGridRows != subGridRows || other.subGridCols != subGridCols) return false;"
)

content = content.replace(
    "Object.hash(\n        subGridSize,",
    "Object.hash(\n        subGridRows,\n        subGridCols,"
)

content = content.replace(
    "'SudokuBoard(subGridSize: $subGridSize",
    "'SudokuBoard(subGrid: ${subGridRows}x$subGridCols"
)

content = content.replace(
    "'subGridSize': subGridSize,",
    "'subGridRows': subGridRows,\n        'subGridCols': subGridCols,"
)

content = content.replace(
    "final subGridSize = json['subGridSize'] as int;",
    "final subGridRows = json['subGridRows'] as int? ?? json['subGridSize'] as int;\n    final subGridCols = json['subGridCols'] as int? ?? json['subGridSize'] as int;"
)

with open('lib/src/features/game/domain/entities/sudoku_board.dart', 'w') as f:
    f.write(content)

