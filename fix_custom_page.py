import re

with open('lib/src/features/custom_sudoku/presentation/custom_sudoku_page.dart', 'r') as f:
    content = f.read()

content = content.replace("final sgRow = sgIndex ~/ board.subGridSize;", "final sgRow = sgIndex ~/ board.subGridCols;")
content = content.replace("final sgCol = sgIndex % board.subGridSize;", "final sgCol = sgIndex % board.subGridCols;")
content = content.replace("crossAxisCount: board.subGridSize,", "crossAxisCount: board.subGridCols,")
content = content.replace("itemCount: board.subGridSize * board.subGridSize,", "itemCount: board.subGridRows * board.subGridCols,")
content = content.replace("final localRow = index ~/ board.subGridSize;", "final localRow = index ~/ board.subGridCols;")
content = content.replace("final localCol = index % board.subGridSize;", "final localCol = index % board.subGridCols;")
content = content.replace("final row = sgRow * board.subGridSize + localRow;", "final row = sgRow * board.subGridRows + localRow;")
content = content.replace("final col = sgCol * board.subGridSize + localCol;", "final col = sgCol * board.subGridCols + localCol;")

content = content.replace(
"""                        final sameSg = (row ~/ board.subGridSize) == (state.selectedRow ~/ board.subGridSize) &&
                                       (col ~/ board.subGridSize) == (state.selectedCol ~/ board.subGridSize);""",
"""                        final sameSg = (row ~/ board.subGridRows) == (state.selectedRow ~/ board.subGridRows) &&
                                       (col ~/ board.subGridCols) == (state.selectedCol ~/ board.subGridCols);"""
)

# And in SudokuCellTile we need to pass subGridRows and subGridCols instead of subGridSize
content = content.replace("subGridSize: board.subGridSize,", "subGridRows: board.subGridRows,\n                          subGridCols: board.subGridCols,")


with open('lib/src/features/custom_sudoku/presentation/custom_sudoku_page.dart', 'w') as f:
    f.write(content)
