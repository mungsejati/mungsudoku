import 'package:flutter/foundation.dart';

/// Defines the structural dimensions of a Sudoku grid.
///
/// The total [gridSize] equals [subGridRows] × [subGridCols], and valid cell
/// values range from 1 to [gridSize] inclusive.
///
/// This class is the Phase 2 future-proofing anchor: the entire engine
/// (board, validator, generator, UI) reads its dimensions from here, so
/// swapping to a different grid shape requires changing only the config.
///
/// | Preset    | Sub-grid | Board   | Values  |
/// |-----------|----------|---------|---------|
/// | `standard`| 3 × 3   | 9 × 9  | 1 – 9  |
/// | `mini`    | 2 × 2   | 4 × 4  | 1 – 4  |
/// | `large`   | 4 × 4   | 16 × 16| 1 – 16 |
@immutable
class BoardConfig {
  const BoardConfig({required this.subGridRows, required this.subGridCols})
    : assert(subGridRows > 1, 'subGridRows must be greater than 1.'),
      assert(subGridCols > 1, 'subGridCols must be greater than 1.');

  /// Number of rows inside a single sub-grid region.
  final int subGridRows;

  /// Number of columns inside a single sub-grid region.
  final int subGridCols;

  /// Total number of rows (and columns) on the full board.
  /// Also the maximum valid cell value.
  int get gridSize => subGridRows * subGridCols;

  /// Total number of cells on the board.
  int get totalCells => gridSize * gridSize;

  // --- Pre-defined presets ---

  /// Standard 9×9 Sudoku with 3×3 sub-grids (Phase 1 default).
  static const BoardConfig standard = BoardConfig(
    subGridRows: 3,
    subGridCols: 3,
  );

  /// Fast 6x6 Sudoku with 2x3 sub-grids.
  static const BoardConfig fast = BoardConfig(subGridRows: 2, subGridCols: 3);

  /// Mini 4×4 Sudoku with 2×2 sub-grids (Phase 2).
  static const BoardConfig mini = BoardConfig(subGridRows: 2, subGridCols: 2);

  /// Large 16×16 Sudoku with 4×4 sub-grids (Phase 2).
  static const BoardConfig large = BoardConfig(subGridRows: 4, subGridCols: 4);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardConfig &&
          runtimeType == other.runtimeType &&
          subGridRows == other.subGridRows &&
          subGridCols == other.subGridCols;

  @override
  int get hashCode => Object.hash(subGridRows, subGridCols);

  @override
  String toString() =>
      'BoardConfig(subGrid: ${subGridRows}x$subGridCols, board: ${gridSize}x$gridSize)';
}
