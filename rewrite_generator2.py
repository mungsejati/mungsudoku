import re

with open('lib/src/features/game/data/services/sudoku_generator.dart', 'r') as f:
    content = f.read()

evaluator_logic = """
  /// Evaluator logic: tries to solve the grid using ONLY basic naked/hidden singles.
  /// If it succeeds, the puzzle is "too easy" for expert/extreme.
  static bool _isSolvableWithBasicLogic(List<int> given, int size, int subGridRows, int subGridCols) {
    final grid = List.generate(size, (r) => List.generate(size, (c) => given[r * size + c]));
    bool changed = true;
    while (changed) {
      changed = false;
      for (int r = 0; r < size; r++) {
        for (int c = 0; c < size; c++) {
          if (grid[r][c] != 0) continue;
          
          int possibleCount = 0;
          int lastPossible = 0;
          for (int digit = 1; digit <= size; digit++) {
            if (_isValidPlacement(grid, r, c, digit, size, subGridRows, subGridCols)) {
              possibleCount++;
              lastPossible = digit;
            }
          }
          if (possibleCount == 1) {
            grid[r][c] = lastPossible;
            changed = true;
          }
        }
      }
    }
    
    // Check if fully solved
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) return false;
      }
    }
    return true;
  }
}
"""
content = content.replace("}\n", evaluator_logic)

# Replace the masking loop to retry if it's too easy for expert/extreme
content = content.replace("""    if (difficulty == Difficulty.expert || difficulty == Difficulty.extreme) {
      if (_isSolvableWithBasicLogic(given, size, subGridRows, subGridCols)) {
         // Logically too easy, but to avoid infinite loops in this simple generator, 
         // we just pass it for now, or we could loop until we find a hard one.
         // Let's loop a few times if we want.
      }
    }""", "")

# Actually we should put the retry in generate()
gen_func_old = """    final given = _maskCells(solution, targetGivenCount, totalCells, size, subGridRows, subGridCols, difficulty);
    return SudokuBoard.fromValues(
      given: given, 
      solution: solution, 
      subGridRows: subGridRows,
      subGridCols: subGridCols,
    );"""

gen_func_new = """    List<int> given = _maskCells(solution, targetGivenCount, totalCells, size, subGridRows, subGridCols, difficulty);
    
    if (difficulty == Difficulty.expert || difficulty == Difficulty.extreme) {
      int attempts = 0;
      while (_isSolvableWithBasicLogic(given, size, subGridRows, subGridCols) && attempts < 5) {
         given = _maskCells(solution, targetGivenCount, totalCells, size, subGridRows, subGridCols, difficulty);
         attempts++;
      }
    }

    return SudokuBoard.fromValues(
      given: given, 
      solution: solution, 
      subGridRows: subGridRows,
      subGridCols: subGridCols,
    );"""
content = content.replace(gen_func_old, gen_func_new)

with open('lib/src/features/game/data/services/sudoku_generator.dart', 'w') as f:
    f.write(content)
