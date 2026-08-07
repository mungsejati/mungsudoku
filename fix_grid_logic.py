import re
import os

def fix_sudoku_board_widget():
    path = 'lib/src/features/game/presentation/widgets/sudoku_board_widget.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Outer GridView replacements
    content = content.replace(
        "crossAxisCount: board.subGridCols,",
        "crossAxisCount: board.gridSize ~/ board.subGridCols,\n              childAspectRatio: board.subGridCols / board.subGridRows,"
    )
    content = content.replace(
        "itemCount: board.subGridRows * board.subGridCols,",
        "itemCount: (board.gridSize ~/ board.subGridRows) * (board.gridSize ~/ board.subGridCols),"
    )
    content = content.replace(
        "final sgRow = sgIndex ~/ board.subGridCols;",
        "final int numCols = board.gridSize ~/ board.subGridCols;\n              final sgRow = sgIndex ~/ numCols;"
    )
    content = content.replace(
        "final sgCol = sgIndex % board.subGridCols;",
        "final sgCol = sgIndex % numCols;"
    )

    with open(path, 'w') as f:
        f.write(content)

def fix_custom_sudoku_page():
    path = 'lib/src/features/custom_sudoku/presentation/custom_sudoku_page.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Outer GridView replacements
    content = content.replace(
        "crossAxisCount: board.subGridCols,",
        "crossAxisCount: board.gridSize ~/ board.subGridCols,\n                      childAspectRatio: board.subGridCols / board.subGridRows,"
    )
    content = content.replace(
        "itemCount: board.subGridRows * board.subGridCols,",
        "itemCount: (board.gridSize ~/ board.subGridRows) * (board.gridSize ~/ board.subGridCols),"
    )
    content = content.replace(
        "final sgRow = sgIndex ~/ board.subGridCols;",
        "final int numCols = board.gridSize ~/ board.subGridCols;\n                      final sgRow = sgIndex ~/ numCols;"
    )
    content = content.replace(
        "final sgCol = sgIndex % board.subGridCols;",
        "final sgCol = sgIndex % numCols;"
    )

    with open(path, 'w') as f:
        f.write(content)

fix_sudoku_board_widget()
fix_custom_sudoku_page()
