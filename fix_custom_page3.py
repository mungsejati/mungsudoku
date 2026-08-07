import re

with open('lib/src/features/custom_sudoku/presentation/custom_sudoku_page.dart', 'r') as f:
    content = f.read()

content = content.replace("subGridSize: boardState.subGridSize,", "subGridRows: boardState.subGridRows,\n                          subGridCols: boardState.subGridCols,")
content = content.replace(
"""                      final sameSg = (row ~/ board.subGridSize) == (state.selectedRow ~/ board.subGridSize) &&
                                     (col ~/ board.subGridSize) == (state.selectedCol ~/ board.subGridSize);""",
"""                      final sameSg = (row ~/ board.subGridRows) == (state.selectedRow! ~/ board.subGridRows) &&
                                     (col ~/ board.subGridCols) == (state.selectedCol! ~/ board.subGridCols);"""
)
# Note state.selectedRow has ! here because it's int? but we checked state.hasSelection
# Wait, actually in the current code it doesn't have !. Let's look at what we grabbed.
#                       final sameSg = (row ~/ board.subGridSize) == (state.selectedRow ~/ board.subGridSize) &&
#                                      (col ~/ board.subGridSize) == (state.selectedCol ~/ board.subGridSize);
# But the compiler would complain about `~/` on int?.
# Wait, custom_sudoku_state's `selectedRow` might be non-nullable? No, it's `int?`.
# Oh, in Dart 3, maybe it complains about `state.selectedRow ~/`. Let's add `!`.

content = content.replace(
"""                      final sameSg = (row ~/ board.subGridSize) == (state.selectedRow ~/ board.subGridSize) &&
                                     (col ~/ board.subGridSize) == (state.selectedCol ~/ board.subGridSize);""",
"""                      final sameSg = (row ~/ board.subGridRows) == (state.selectedRow! ~/ board.subGridRows) &&
                                     (col ~/ board.subGridCols) == (state.selectedCol! ~/ board.subGridCols);"""
)

with open('lib/src/features/custom_sudoku/presentation/custom_sudoku_page.dart', 'w') as f:
    f.write(content)
