import '../entities/sudoku_board.dart';

/// A stateless utility for detecting Sudoku constraint violations.
///
/// All methods are pure functions with no side effects. Never instantiate
/// this class — use the static methods directly.
///
/// ## Conflict vs. Incorrect
///
/// | Term       | Definition                                                  |
/// |------------|-------------------------------------------------------------|
/// | *Conflict* | A value appears **more than once** in the same row, column, |
/// |            | or sub-grid (Sudoku constraint violation).                  |
/// | *Incorrect*| A cell's `value` ≠ its `solutionValue`.                    |
///
/// This class handles **conflicts** only. `SudokuCell.isIncorrect` handles
/// *incorrectness*. The distinction matters because:
/// - Conflicts drive real-time duplicate highlighting (red outline).
/// - `isIncorrect` drives mistake counting and the victory condition.
abstract final class SudokuValidator {
  /// Returns the set of `(row, col)` positions whose current values violate
  /// at least one Sudoku constraint (row, column, or sub-grid).
  ///
  /// Empty cells are never included in the result.
  static Set<(int, int)> findConflicts(SudokuBoard board) {
    final conflicts = <(int, int)>{};
    for (var r = 0; r < board.gridSize; r++) {
      for (var c = 0; c < board.gridSize; c++) {
        final cell = board.cellAt(r, c);
        if (cell.isEmpty) continue;
        if (_hasConflict(board, r, c, cell.value!, excludeSelf: true)) {
          conflicts.add((r, c));
        }
      }
    }
    return conflicts;
  }

  /// Returns `true` if placing [value] at ([row], [col]) would **not** violate
  /// any Sudoku constraint.
  ///
  /// The cell at ([row], [col]) is excluded from the check, making this
  /// safe to call when the cell already contains a value being replaced.
  ///
  /// Used internally by the generator to validate each placement during
  /// backtracking.
  static bool isValidPlacement(
    SudokuBoard board,
    int row,
    int col,
    int value,
  ) => !_hasConflict(board, row, col, value, excludeSelf: true);

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns the set of `(row, col)` positions of cells that already contain
  /// [value] in the same row, column, or sub-grid as the cell at ([row], [col]).
  ///
  /// Used for validating Note inputs.
  static Set<(int, int)> findConflictPositionsForValue(
    SudokuBoard board,
    int row,
    int col,
    int value,
  ) {
    final conflicts = <(int, int)>{};

    // Check Row
    for (var c = 0; c < board.gridSize; c++) {
      if (c == col) continue;
      if (board.cellAt(row, c).value == value) conflicts.add((row, c));
    }

    // Check Col
    for (var r = 0; r < board.gridSize; r++) {
      if (r == row) continue;
      if (board.cellAt(r, col).value == value) conflicts.add((r, col));
    }

    // Check Subgrid
    final startRow = (row ~/ board.subGridRows) * board.subGridRows;
    final startCol = (col ~/ board.subGridCols) * board.subGridCols;
    for (var r = startRow; r < startRow + board.subGridRows; r++) {
      for (var c = startCol; c < startCol + board.subGridCols; c++) {
        if (r == row && c == col) continue;
        if (board.cellAt(r, c).value == value) conflicts.add((r, c));
      }
    }

    return conflicts;
  }

  static bool _hasConflict(
    SudokuBoard board,
    int row,
    int col,
    int value, {
    bool excludeSelf = false,
  }) {
    // With O(1) lookup tables, if we exclude self, we check if the value exists
    // and if the count is > 1 (which we can't easily do with a Set unless we know
    // if the cell itself currently has the value).
    // Actually, since excludeSelf is mainly used when the cell ALREADY has the value
    // and we want to see if there's *another* cell with the same value,
    // we can just check if any peer has it by looping, or we can use the Sets but
    // be careful about the current cell's value.
    // Let's optimize isValidPlacement which tests new values.

    // For general conflict finding (findConflicts), the cell HAS the value, so the Set
    // definitely contains it. We must loop to see if there's a *duplicate*.
    // Wait, if the Set has it, we just need to know if there's more than one.
    // Since the Set only stores unique values, it doesn't store counts!
    // So for findConflicts we still have to scan or we could maintain counts.
    // However, since we just need isValidPlacement to be O(1):

    if (!excludeSelf) {
      final sgIndex =
          (row ~/ board.subGridRows) * (board.gridSize ~/ board.subGridCols) +
          (col ~/ board.subGridCols);
      return board.rowNumbers[row]!.contains(value) ||
          board.colNumbers[col]!.contains(value) ||
          board.subGridNumbers[sgIndex]!.contains(value);
    }

    return _conflictsInRow(board, row, col, value, excludeSelf) ||
        _conflictsInColumn(board, row, col, value, excludeSelf) ||
        _conflictsInSubGrid(board, row, col, value, excludeSelf);
  }

  static bool _conflictsInRow(
    SudokuBoard board,
    int row,
    int col,
    int value,
    bool excludeSelf,
  ) {
    if (!excludeSelf) return board.rowNumbers[row]!.contains(value);
    for (var c = 0; c < board.gridSize; c++) {
      if (c == col) continue;
      if (board.cellAt(row, c).value == value) return true;
    }
    return false;
  }

  static bool _conflictsInColumn(
    SudokuBoard board,
    int row,
    int col,
    int value,
    bool excludeSelf,
  ) {
    if (!excludeSelf) return board.colNumbers[col]!.contains(value);
    for (var r = 0; r < board.gridSize; r++) {
      if (r == row) continue;
      if (board.cellAt(r, col).value == value) return true;
    }
    return false;
  }

  static bool _conflictsInSubGrid(
    SudokuBoard board,
    int row,
    int col,
    int value,
    bool excludeSelf,
  ) {
    final sgIndex =
        (row ~/ board.subGridRows) * (board.gridSize ~/ board.subGridCols) +
        (col ~/ board.subGridCols);
    if (!excludeSelf) return board.subGridNumbers[sgIndex]!.contains(value);

    final startRow = (row ~/ board.subGridRows) * board.subGridRows;
    final startCol = (col ~/ board.subGridCols) * board.subGridCols;
    for (var r = startRow; r < startRow + board.subGridRows; r++) {
      for (var c = startCol; c < startCol + board.subGridCols; c++) {
        if (r == row && c == col) continue;
        if (board.cellAt(r, c).value == value) return true;
      }
    }
    return false;
  }
}
