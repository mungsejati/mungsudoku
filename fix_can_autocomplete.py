import re

with open('lib/src/features/game/application/game_state.dart', 'r') as f:
    content = f.read()

content = content.replace(
"""  bool get canAutoComplete =>
      !isVictory &&
      !isGameOver &&
      conflictPositions.isEmpty &&
      board.filledCellCount < board.totalCells &&
      (board.totalCells - board.filledCellCount <= 10);""",
"""  bool get canAutoComplete =>
      difficulty != Difficulty.fast &&
      !isVictory &&
      !isGameOver &&
      conflictPositions.isEmpty &&
      board.filledCellCount < board.totalCells &&
      (board.totalCells - board.filledCellCount <= 9);"""
)

# In case the exact formatting doesn't match, let's use regex
content = re.sub(
    r"bool get canAutoComplete =>\s*!isVictory &&",
    "bool get canAutoComplete =>\n      difficulty != Difficulty.fast &&\n      !isVictory &&",
    content
)

# Oh wait, we had it as `== 9` in a previous session, maybe? Let's check what it currently says.
