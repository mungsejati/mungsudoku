import re

with open('lib/src/features/custom_sudoku/presentation/custom_sudoku_page.dart', 'r') as f:
    content = f.read()

content = content.replace("subGridSize: state.board.subGridSize,", "subGridRows: state.board.subGridRows,\n                  subGridCols: state.board.subGridCols,")

content = content.replace(
"""                        final sameSg = (row ~/ board.subGridSize) == (state.selectedRow ~/ board.subGridSize) &&
                                       (col ~/ board.subGridSize) == (state.selectedCol ~/ board.subGridSize);""",
"""                        final sameSg = (row ~/ board.subGridRows) == (state.selectedRow ~/ board.subGridRows) &&
                                       (col ~/ board.subGridCols) == (state.selectedCol ~/ board.subGridCols);"""
)

# And if state.selectedRow has ! after it:
content = content.replace(
"""                        final sameSg = (row ~/ board.subGridSize) == (state.selectedRow! ~/ board.subGridSize) &&
                                       (col ~/ board.subGridSize) == (state.selectedCol! ~/ board.subGridSize);""",
"""                        final sameSg = (row ~/ board.subGridRows) == (state.selectedRow! ~/ board.subGridRows) &&
                                       (col ~/ board.subGridCols) == (state.selectedCol! ~/ board.subGridCols);"""
)

with open('lib/src/features/custom_sudoku/presentation/custom_sudoku_page.dart', 'w') as f:
    f.write(content)
