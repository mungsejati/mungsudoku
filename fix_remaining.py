import re

# sudoku_board_widget.dart
with open('lib/src/features/game/presentation/widgets/sudoku_board_widget.dart', 'r') as f:
    content = f.read()

content = content.replace("crossAxisCount: board.subGridSize,", "crossAxisCount: board.subGridCols,")
content = content.replace("itemCount: board.subGridSize * board.subGridSize,", "itemCount: board.subGridRows * board.subGridCols,")
content = content.replace("final sgRow = sgIndex ~/ board.subGridSize;", "final sgRow = sgIndex ~/ board.subGridCols;")
content = content.replace("final sgCol = sgIndex % board.subGridSize;", "final sgCol = sgIndex % board.subGridCols;")
content = content.replace("final s = board.subGridSize;", "final sRows = board.subGridRows;\n      final sCols = board.subGridCols;")
content = content.replace(
"""      // Determine border thickness
      final bool isTop = r == 0 || r % s == 0;
      final bool isLeft = c == 0 || c % s == 0;
      final bool isBottom = r == gridSize - 1;
      final bool isRight = c == gridSize - 1;""",
"""      // Determine border thickness
      final bool isTop = r == 0 || r % sRows == 0;
      final bool isLeft = c == 0 || c % sCols == 0;
      final bool isBottom = r == gridSize - 1;
      final bool isRight = c == gridSize - 1;"""
)
content = content.replace("final row = (sgRow * board.subGridSize) + (index ~/ board.subGridSize);", "final row = (sgRow * board.subGridRows) + (index ~/ board.subGridCols);")
content = content.replace("final col = (sgCol * board.subGridSize) + (index % board.subGridSize);", "final col = (sgCol * board.subGridCols) + (index % board.subGridCols);")


with open('lib/src/features/game/presentation/widgets/sudoku_board_widget.dart', 'w') as f:
    f.write(content)

# custom_sudoku_notifier.dart
with open('lib/src/features/custom_sudoku/application/custom_sudoku_notifier.dart', 'r') as f:
    content = f.read()
content = content.replace("state.board.subGridSize", "state.board.subGridRows, state.board.subGridCols")
with open('lib/src/features/custom_sudoku/application/custom_sudoku_notifier.dart', 'w') as f:
    f.write(content)

# custom_sudoku_state.dart
with open('lib/src/features/custom_sudoku/application/custom_sudoku_state.dart', 'r') as f:
    content = f.read()
content = content.replace("subGridSize: subGridSize,", "subGridRows: 3, subGridCols: 3,")
with open('lib/src/features/custom_sudoku/application/custom_sudoku_state.dart', 'w') as f:
    f.write(content)
