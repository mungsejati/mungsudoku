import re

with open('lib/src/features/game/data/services/sudoku_generator.dart', 'r') as f:
    lines = f.readlines()

new_content = """import 'dart:math';

import '../../domain/entities/sudoku_board.dart';
import '../../domain/enums/difficulty.dart';

/// Generates valid Sudoku puzzles dynamically sized by `subGridRows` and `subGridCols`
/// using a randomised backtracking solver.
abstract final class SudokuGenerator {
  static final Random _random = Random();

  /// Returns a fully initialised [SudokuBoard] at the requested [difficulty].
  static SudokuBoard generate(Difficulty difficulty, {int subGridRows = 3, int subGridCols = 3}) {
    final size = subGridRows * subGridCols;
    final totalCells = size * size;
    
    final solution = _generateSolution(size, subGridRows, subGridCols);
    
    // Scale given cell count based on grid size if necessary.
    final ratio = difficulty.givenCellCount / 81.0;
    final targetGivenCount = (totalCells * ratio).round();

    List<int> given = _maskCells(solution, targetGivenCount, totalCells, size, subGridRows, subGridCols);
    
    // Evaluator: For expert and extreme, ensure puzzle requires advanced logic
    if (difficulty == Difficulty.expert || difficulty == Difficulty.extreme) {
      int attempts = 0;
      while (_isSolvableWithBasicLogic(given, size, subGridRows, subGridCols) && attempts < 5) {
        // Regenerate completely or re-mask
        final newSolution = _generateSolution(size, subGridRows, subGridCols);
        given = _maskCells(newSolution, targetGivenCount, totalCells, size, subGridRows, subGridCols);
        attempts++;
      }
    }

    return SudokuBoard.fromValues(
      given: given, 
      solution: solution, 
      subGridRows: subGridRows,
      subGridCols: subGridCols,
    );
  }

  // ---------------------------------------------------------------------------
  // Private: solution generation
  // ---------------------------------------------------------------------------

  static List<int> _generateSolution(int size, int subGridRows, int subGridCols) {
    final grid = List.generate(size, (_) => List.filled(size, 0));
    _solve(grid, size, subGridRows, subGridCols);
    return [for (final row in grid) ...row];
  }

  static bool _solve(List<List<int>> grid, int size, int subGridRows, int subGridCols) {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (grid[row][col] != 0) continue;

        final candidates = List.generate(size, (i) => i + 1)..shuffle(_random);
        for (final digit in candidates) {
          if (!_isValidPlacement(grid, row, col, digit, size, subGridRows, subGridCols)) continue;
          grid[row][col] = digit;
          if (_solve(grid, size, subGridRows, subGridCols)) return true;
          grid[row][col] = 0; // backtrack
        }
        return false; // no digit fits → trigger backtrack in caller
      }
    }
    return true; // all cells filled
  }

  static bool _isValidPlacement(
    List<List<int>> grid,
    int row,
    int col,
    int value,
    int size,
    int subGridRows,
    int subGridCols,
  ) {
    // Row constraint
    if (grid[row].contains(value)) return false;

    // Column constraint
    for (var r = 0; r < size; r++) {
      if (grid[r][col] == value) return false;
    }

    // Sub-grid constraint
    final startRow = (row ~/ subGridRows) * subGridRows;
    final startCol = (col ~/ subGridCols) * subGridCols;
    for (var r = startRow; r < startRow + subGridRows; r++) {
      for (var c = startCol; c < startCol + subGridCols; c++) {
        if (grid[r][c] == value) return false;
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Private: masking
  // ---------------------------------------------------------------------------

  static List<int> _maskCells(List<int> solution, int givenCount, int totalCells, int size, int subGridRows, int subGridCols) {
    final given = List<int>.from(solution);
    final positions = List.generate(totalCells, (i) => i)..shuffle(_random);
    int currentGivenCount = totalCells;

    for (final pos in positions) {
      if (currentGivenCount <= givenCount) break;

      final backup = given[pos];
      given[pos] = 0;

      // Convert 1D list to 2D grid for solver
      final grid = List.generate(size, (r) {
        return List.generate(size, (c) => given[r * size + c]);
      });

      final solutionCount = _countSolutions(grid, size, subGridRows, subGridCols, limit: 2);
      if (solutionCount > 1) {
        // Multiple solutions found, this removal breaks uniqueness. Revert.
        given[pos] = backup;
      } else {
        currentGivenCount--;
      }
    }
    return given;
  }

  static int _countSolutions(List<List<int>> grid, int size, int subGridRows, int subGridCols, {int limit = 2}) {
    int count = 0;

    bool solve(int row, int col) {
      if (row == size) {
        count++;
        return count >= limit; // Stop if we reached the limit
      }

      int nextRow = col == size - 1 ? row + 1 : row;
      int nextCol = col == size - 1 ? 0 : col + 1;

      if (grid[row][col] != 0) {
        return solve(nextRow, nextCol);
      }

      for (int digit = 1; digit <= size; digit++) {
        if (_isValidPlacement(grid, row, col, digit, size, subGridRows, subGridCols)) {
          grid[row][col] = digit;
          if (solve(nextRow, nextCol)) {
            grid[row][col] = 0; // backtrack to leave grid clean, though we return true
            return true;
          }
          grid[row][col] = 0;
        }
      }
      return false;
    }

    solve(0, 0);
    return count;
  }

  /// Checks if the given grid has exactly one unique solution.
  static bool hasUniqueSolution(List<List<int>> grid, int size, int subGridRows, int subGridCols) {
    return _countSolutions(grid, size, subGridRows, subGridCols, limit: 2) == 1;
  }

  /// Attempts to solve the grid and returns the flat 1D solution list.
  /// Returns null if no solution exists.
  static List<int>? solveGrid(List<List<int>> grid, int size, int subGridRows, int subGridCols) {
    // Create a deep copy to avoid mutating the input
    final gridCopy = List.generate(size, (r) => List<int>.from(grid[r]));
    if (_solve(gridCopy, size, subGridRows, subGridCols)) {
      return [for (final row in gridCopy) ...row];
    }
    return null;
  }

  /// Evaluator logic: tries to solve the grid using ONLY basic naked/hidden singles.
  /// If it succeeds completely, the puzzle is "too easy" for expert/extreme.
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

with open('lib/src/features/game/data/services/sudoku_generator.dart', 'w') as f:
    f.write(new_content)
