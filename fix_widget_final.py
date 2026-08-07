import re

with open('lib/src/features/game/presentation/widgets/sudoku_board_widget.dart', 'r') as f:
    content = f.read()

content = content.replace("crossAxisCount: s,", "crossAxisCount: sCols,")
content = content.replace("itemCount: s * s,", "itemCount: sRows * sCols,")
content = content.replace("final localRow = index ~/ s;", "final localRow = index ~/ sCols;")
content = content.replace("final localCol = index % s;", "final localCol = index % sCols;")
content = content.replace("final row = sgRow * s + localRow;", "final row = sgRow * sRows + localRow;")
content = content.replace("final col = sgCol * s + localCol;", "final col = sgCol * sCols + localCol;")

content = content.replace(
"""                final sameSg =
                    (row ~/ s) == (state.selectedRow! ~/ s) &&
                    (col ~/ s) == (state.selectedCol! ~/ s);""",
"""                final sameSg =
                    (row ~/ sRows) == (state.selectedRow! ~/ sRows) &&
                    (col ~/ sCols) == (state.selectedCol! ~/ sCols);"""
)

# SudokuCellTile updates
content = content.replace(
    "subGridSize: s,", 
    "subGridRows: sRows,\n                subGridCols: sCols,"
)

# SudokuCellTile definition
content = content.replace("required this.subGridSize,", "required this.subGridRows,\n    required this.subGridCols,")
content = content.replace("final int subGridSize;", "final int subGridRows;\n  final int subGridCols;")

# _NotesGrid call
content = content.replace(
    "subGridSize: subGridSize,",
    "subGridRows: subGridRows,\n          subGridCols: subGridCols,"
)

# _NotesGrid definition
content = content.replace("required this.subGridSize,", "required this.subGridRows,\n    required this.subGridCols,")
content = content.replace("final int subGridSize;", "final int subGridRows;\n  final int subGridCols;")
content = content.replace("crossAxisCount: subGridSize,", "crossAxisCount: subGridCols,")

# Dashboard sizes and borders
content = content.replace(
"""      // Determine border thickness
      final bool isTop = r == 0 || r % sRows == 0;
      final bool isLeft = c == 0 || c % sCols == 0;
      final bool isBottom = r == gridSize - 1;
      final bool isRight = c == gridSize - 1;""",
""
)
# That part is not in there anymore.

with open('lib/src/features/game/presentation/widgets/sudoku_board_widget.dart', 'w') as f:
    f.write(content)
