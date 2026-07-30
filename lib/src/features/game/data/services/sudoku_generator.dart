import 'dart:math';

import '../../domain/entities/sudoku_board.dart';
import '../../domain/enums/difficulty.dart';

/// Generates valid Sudoku puzzles dynamically sized by `subGridSize`
/// using a randomised backtracking solver.
abstract final class SudokuGenerator {
  static final Random _random = Random();

  /// Returns a fully initialised [SudokuBoard] at the requested [difficulty]
  /// and [subGridSize].
  static SudokuBoard generate(Difficulty difficulty, {int subGridSize = 3}) {
    final size = subGridSize * subGridSize;
    final totalCells = size * size;
    
    final solution = _generateSolution(size, subGridSize);
    
    // Scale given cell count based on grid size if necessary,
    // though for now we use a simple scaling based on proportion.
    // difficulty.givenCellCount is designed for 9x9 (81 cells).
    // Let's calculate the ratio and apply it to totalCells.
    final ratio = difficulty.givenCellCount / 81.0;
    final targetGivenCount = (totalCells * ratio).round();

    final given = _maskCells(solution, targetGivenCount, totalCells, size, subGridSize);
    return SudokuBoard.fromValues(
      given: given, 
      solution: solution, 
      subGridSize: subGridSize,
    );
  }

  // ---------------------------------------------------------------------------
  // Private: solution generation
  // ---------------------------------------------------------------------------

  static List<int> _generateSolution(int size, int subGridSize) {
    final grid = List.generate(size, (_) => List.filled(size, 0));
    _solve(grid, size, subGridSize);
    return [for (final row in grid) ...row];
  }

  static bool _solve(List<List<int>> grid, int size, int subGridSize) {
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        if (grid[row][col] != 0) continue;

        final candidates = List.generate(size, (i) => i + 1)..shuffle(_random);
        for (final digit in candidates) {
          if (!_isValidPlacement(grid, row, col, digit, size, subGridSize)) continue;
          grid[row][col] = digit;
          if (_solve(grid, size, subGridSize)) return true;
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
    int subGridSize,
  ) {
    // Row constraint
    if (grid[row].contains(value)) return false;

    // Column constraint
    for (var r = 0; r < size; r++) {
      if (grid[r][col] == value) return false;
    }

    // Sub-grid constraint
    final startRow = (row ~/ subGridSize) * subGridSize;
    final startCol = (col ~/ subGridSize) * subGridSize;
    for (var r = startRow; r < startRow + subGridSize; r++) {
      for (var c = startCol; c < startCol + subGridSize; c++) {
        if (grid[r][c] == value) return false;
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Private: masking
  // ---------------------------------------------------------------------------

  static List<int> _maskCells(List<int> solution, int givenCount, int totalCells, int size, int subGridSize) {
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

      final solutionCount = _countSolutions(grid, size, subGridSize, limit: 2);
      if (solutionCount > 1) {
        // Multiple solutions found, this removal breaks uniqueness. Revert.
        given[pos] = backup;
      } else {
        currentGivenCount--;
      }
    }
    return given;
  }

  static int _countSolutions(List<List<int>> grid, int size, int subGridSize, {int limit = 2}) {
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
        if (_isValidPlacement(grid, row, col, digit, size, subGridSize)) {
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
}
