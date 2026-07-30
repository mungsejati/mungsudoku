import 'package:flutter/foundation.dart';

import 'sudoku_cell.dart';

/// The aggregate root for a Sudoku puzzle.
///
/// Holds a deeply immutable two-dimensional grid of [SudokuCell]s and
/// provides helper methods to access rows, columns, and sub-grid regions.
///
/// ## Immutability Contract
///
/// Every mutation method ([updateCell], [copyWith]) returns a **new**
/// [SudokuBoard] — the original is never modified. This aligns naturally
/// with Riverpod's state model and makes undo/redo trivially easy:
/// maintain a `List<SudokuBoard>` stack of snapshots.
///
/// ## Grid Dimensions
///
/// [subGridSize] defines the side-length of each square sub-grid region.
/// The full board is [gridSize] × [gridSize], where `gridSize = subGridSize²`.
///
/// | [subGridSize] | Sub-grid shape | Full board  | Valid values |
/// |---------------|----------------|-------------|--------------|
/// | `3` (default) | 3 × 3          | 9 × 9      | 1 – 9       |
/// | `2`           | 2 × 2          | 4 × 4      | 1 – 4       |
/// | `4`           | 4 × 4          | 16 × 16    | 1 – 16      |
/// | `5`           | 5 × 5          | 25 × 25    | 1 – 25      |
///
/// ## Coordinate System
///
/// `(row, col)` — both zero-indexed, top-left origin.
@immutable
class SudokuBoard {
  /// Creates a [SudokuBoard] from a pre-built [cells] matrix.
  ///
  /// [cells] must be a square grid of side [gridSize] = [subGridSize]².
  /// The outer list and each inner list are made deeply unmodifiable.
  SudokuBoard({
    required List<List<SudokuCell>> cells,
    this.subGridSize = 3,
    required this.rowNumbers,
    required this.colNumbers,
    required this.subGridNumbers,
  })  : assert(subGridSize >= 2, 'subGridSize must be at least 2.'),
        assert(
          cells.length == subGridSize * subGridSize &&
              cells.every((row) => row.length == subGridSize * subGridSize),
          'cells must be a ${subGridSize * subGridSize}x${subGridSize * subGridSize} '
          'grid for subGridSize=$subGridSize.',
        ),
        cells = List.unmodifiable(
          cells.map((row) => List<SudokuCell>.unmodifiable(row)).toList(),
        );

  /// Deeply unmodifiable two-dimensional grid of cells.
  ///
  /// Access via [cellAt], [rowAt], [columnAt], or [subGridAt] rather than
  /// indexing directly.
  final List<List<SudokuCell>> cells;

  /// Side-length of each square sub-grid region (default `3` for Phase 1).
  ///
  /// Increasing this value in Phase 2 is the only change needed to support
  /// larger or smaller board configurations.
  final int subGridSize;

  /// O(1) lookup: values currently present in each row.
  final Map<int, Set<int>> rowNumbers;

  /// O(1) lookup: values currently present in each column.
  final Map<int, Set<int>> colNumbers;

  /// O(1) lookup: values currently present in each sub-grid.
  final Map<int, Set<int>> subGridNumbers;

  // --- Derived dimensions ---

  /// Total rows (and columns) on the full board (`subGridSize²`).
  int get gridSize => subGridSize * subGridSize;

  /// Total cells on the board (`gridSize²`).
  int get totalCells => gridSize * gridSize;

  // --- Factory constructors ---

  /// Creates a completely empty board.
  ///
  /// Every cell has [SudokuCell.isOriginal] = `false`, [SudokuCell.value] =
  /// `null`, and a placeholder [SudokuCell.solutionValue] of `1`.
  /// The puzzle generator is responsible for setting real solution values
  /// before exposing the board to the player.
  factory SudokuBoard.empty({int subGridSize = 3}) {
    final size = subGridSize * subGridSize;
    final emptySets = Map<int, Set<int>>.unmodifiable(
      <int, Set<int>>{for (var i = 0; i < size; i++) i: const <int>{}},
    );
    return SudokuBoard(
      subGridSize: subGridSize,
      cells: List.generate(
        size,
        (row) => List.generate(
          size,
          (col) => SudokuCell(
            row: row,
            col: col,
            solutionValue: 1, // placeholder; replaced by the generator
          ),
        ),
      ),
      rowNumbers: emptySets,
      colNumbers: emptySets,
      subGridNumbers: emptySets,
    );
  }

  /// Creates a board from two flat integer lists in row-major order.
  ///
  /// - [given]: The puzzle's initial state. Use `0` for empty (player-fillable)
  ///   cells. Non-zero values become [SudokuCell.isOriginal] = `true`.
  /// - [solution]: The complete, correct solution. Must not contain zeros.
  ///
  /// This is the primary constructor used by the puzzle generator after it
  /// has produced both a full solution and a masked puzzle.
  factory SudokuBoard.fromValues({
    required List<int> given,
    required List<int> solution,
    int subGridSize = 3,
  }) {
    final size = subGridSize * subGridSize;
    assert(
      given.length == size * size && solution.length == size * size,
      'given and solution must each have ${size * size} elements.',
    );

    final rowNums = <int, Set<int>>{for (var i = 0; i < size; i++) i: {}};
    final colNums = <int, Set<int>>{for (var i = 0; i < size; i++) i: {}};
    final sgNums = <int, Set<int>>{for (var i = 0; i < size; i++) i: {}};

    final cells = List.generate(size, (row) {
      return List.generate(size, (col) {
        final index = row * size + col;
        final givenValue = given[index];
        if (givenValue != 0) {
          rowNums[row]!.add(givenValue);
          colNums[col]!.add(givenValue);
          final sgIndex = (row ~/ subGridSize) * subGridSize + (col ~/ subGridSize);
          sgNums[sgIndex]!.add(givenValue);
        }
        return SudokuCell(
          row: row,
          col: col,
          solutionValue: solution[index],
          value: givenValue == 0 ? null : givenValue,
          isOriginal: givenValue != 0,
        );
      });
    });

    return SudokuBoard(
      subGridSize: subGridSize,
      cells: cells,
      rowNumbers: Map.unmodifiable(rowNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      colNumbers: Map.unmodifiable(colNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      subGridNumbers: Map.unmodifiable(sgNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
    );
  }

  // --- Cell access ---

  /// Returns the cell at ([row], [col]).
  SudokuCell cellAt(int row, int col) => cells[row][col];

  /// Returns all cells in the given [row] (left to right).
  List<SudokuCell> rowAt(int row) => List.unmodifiable(cells[row]);

  /// Returns all cells in the given [col] (top to bottom).
  List<SudokuCell> columnAt(int col) =>
      List.generate(gridSize, (row) => cells[row][col]);

  /// Returns all cells in the sub-grid region that contains ([row], [col]).
  ///
  /// Correct for any [subGridSize], making this Phase 2-ready automatically.
  List<SudokuCell> subGridAt(int row, int col) {
    final startRow = (row ~/ subGridSize) * subGridSize;
    final startCol = (col ~/ subGridSize) * subGridSize;
    return [
      for (var r = startRow; r < startRow + subGridSize; r++)
        for (var c = startCol; c < startCol + subGridSize; c++)
          cells[r][c],
    ];
  }

  // --- Non-destructive mutations ---

  /// Returns a new board with the cell at ([row], [col]) replaced by [cell].
  ///
  /// All other cells are preserved. This is the primary way for the
  /// Riverpod notifier to advance the board state after player input.
  SudokuBoard updateCell(int row, int col, SudokuCell cell) {
    final newCells = [
      for (var r = 0; r < gridSize; r++)
        [
          for (var c = 0; c < gridSize; c++)
            (r == row && c == col) ? cell : cells[r][c],
        ],
    ];

    final oldCell = cells[row][col];
    Map<int, Set<int>> newRowNums = rowNumbers;
    Map<int, Set<int>> newColNums = colNumbers;
    Map<int, Set<int>> newSgNums = subGridNumbers;

    if (oldCell.value != cell.value) {
      final sgIndex = (row ~/ subGridSize) * subGridSize + (col ~/ subGridSize);

      newRowNums = Map.of(rowNumbers);
      newRowNums[row] = Set.of(newRowNums[row]!);

      newColNums = Map.of(colNumbers);
      newColNums[col] = Set.of(newColNums[col]!);

      newSgNums = Map.of(subGridNumbers);
      newSgNums[sgIndex] = Set.of(newSgNums[sgIndex]!);

      if (oldCell.value != null) {
        newRowNums[row]!.remove(oldCell.value);
        newColNums[col]!.remove(oldCell.value);
        newSgNums[sgIndex]!.remove(oldCell.value);
      }
      if (cell.value != null) {
        newRowNums[row]!.add(cell.value!);
        newColNums[col]!.add(cell.value!);
        newSgNums[sgIndex]!.add(cell.value!);
      }

      newRowNums[row] = Set.unmodifiable(newRowNums[row]!);
      newColNums[col] = Set.unmodifiable(newColNums[col]!);
      newSgNums[sgIndex] = Set.unmodifiable(newSgNums[sgIndex]!);
      
      newRowNums = Map.unmodifiable(newRowNums);
      newColNums = Map.unmodifiable(newColNums);
      newSgNums = Map.unmodifiable(newSgNums);
    }

    return SudokuBoard(
      cells: newCells,
      subGridSize: subGridSize,
      rowNumbers: newRowNums,
      colNumbers: newColNums,
      subGridNumbers: newSgNums,
    );
  }

  /// Returns a new board with the specified top-level fields replaced.
  SudokuBoard copyWith({
    List<List<SudokuCell>>? cells,
    int? subGridSize,
    Map<int, Set<int>>? rowNumbers,
    Map<int, Set<int>>? colNumbers,
    Map<int, Set<int>>? subGridNumbers,
  }) =>
      SudokuBoard(
        cells: cells ?? this.cells,
        subGridSize: subGridSize ?? this.subGridSize,
        rowNumbers: rowNumbers ?? this.rowNumbers,
        colNumbers: colNumbers ?? this.colNumbers,
        subGridNumbers: subGridNumbers ?? this.subGridNumbers,
      );

  /// Returns a new board with [value] removed from the [SudokuCell.notes] of
  /// every peer cell at ([row], [col]).
  ///
  /// "Peer" means any cell that shares the same row, column, or sub-grid.
  /// The cell at ([row], [col]) itself is never modified here — the caller is
  /// responsible for having already placed the value there.
  ///
  /// This is the **Auto-Prune** step: after filling a cell the caller should
  /// immediately call this to keep pencil marks consistent.
  SudokuBoard pruneNotesForPlacement(int row, int col, int value) {
    var board = this;

    // Same row
    for (var c = 0; c < gridSize; c++) {
      if (c == col) continue;
      final peer = board.cellAt(row, c);
      if (peer.notes.contains(value)) {
        board = board.updateCell(row, c, peer.toggleNote(value));
      }
    }

    // Same column
    for (var r = 0; r < gridSize; r++) {
      if (r == row) continue;
      final peer = board.cellAt(r, col);
      if (peer.notes.contains(value)) {
        board = board.updateCell(r, col, peer.toggleNote(value));
      }
    }

    // Same sub-grid
    final startRow = (row ~/ subGridSize) * subGridSize;
    final startCol = (col ~/ subGridSize) * subGridSize;
    for (var r = startRow; r < startRow + subGridSize; r++) {
      for (var c = startCol; c < startCol + subGridSize; c++) {
        if (r == row && c == col) continue;
        final peer = board.cellAt(r, c);
        if (peer.notes.contains(value)) {
          board = board.updateCell(r, c, peer.toggleNote(value));
        }
      }
    }

    return board;
  }


  // --- Board state queries ---

  /// `true` when every cell's [SudokuCell.value] equals its
  /// [SudokuCell.solutionValue] — the puzzle has been solved correctly.
  ///
  /// Both [isOriginal] and player-filled cells must satisfy this condition.
  bool get isCompleted =>
      cells.every((row) => row.every((cell) => cell.isCorrect));

  /// The total number of cells where [SudokuCell.isIncorrect] is `true`.
  ///
  /// An incorrect cell is one the player has filled with a value that does
  /// not match [SudokuCell.solutionValue].
  int get mistakeCount =>
      cells.fold(0, (sum, row) => sum + row.where((c) => c.isIncorrect).length);

  /// Number of cells that currently have any value (original + user-entered).
  int get filledCellCount => cells.fold(
        0,
        (sum, row) => sum + row.where((c) => c.isFilled).length,
      );

  /// Number of cells the player has filled in (excludes original cells).
  int get userFilledCellCount => cells.fold(
        0,
        (sum, row) =>
            sum + row.where((c) => c.isFilled && !c.isOriginal).length,
      );

  // --- Equality & hashing ---

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SudokuBoard || other.subGridSize != subGridSize) return false;
    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        if (other.cells[r][c] != cells[r][c]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        subGridSize,
        Object.hashAll([for (final row in cells) Object.hashAll(row)]),
      );

  @override
  String toString() =>
      'SudokuBoard(subGridSize: $subGridSize, gridSize: $gridSize, '
      'filled: $filledCellCount/$totalCells, mistakes: $mistakeCount, '
      'completed: $isCompleted)';

  // --- Serialization ---

  Map<String, dynamic> toJson() => {
        'subGridSize': subGridSize,
        'cells': cells.expand((row) => row).map((c) => c.toJson()).toList(),
      };

  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    final subGridSize = json['subGridSize'] as int;
    final flatCells = (json['cells'] as List<dynamic>)
        .map((e) => SudokuCell.fromJson(e as Map<String, dynamic>))
        .toList();

    final size = subGridSize * subGridSize;
    assert(flatCells.length == size * size, 'Invalid cell count');

    final rowNums = <int, Set<int>>{for (var i = 0; i < size; i++) i: {}};
    final colNums = <int, Set<int>>{for (var i = 0; i < size; i++) i: {}};
    final sgNums = <int, Set<int>>{for (var i = 0; i < size; i++) i: {}};

    final grid = List.generate(size, (r) => <SudokuCell>[]);
    for (var i = 0; i < flatCells.length; i++) {
      final cell = flatCells[i];
      grid[cell.row].add(cell);
      if (cell.value != null) {
        rowNums[cell.row]!.add(cell.value!);
        colNums[cell.col]!.add(cell.value!);
        final sgIndex = (cell.row ~/ subGridSize) * subGridSize + (cell.col ~/ subGridSize);
        sgNums[sgIndex]!.add(cell.value!);
      }
    }

    return SudokuBoard(
      subGridSize: subGridSize,
      cells: grid,
      rowNumbers: Map.unmodifiable(rowNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      colNumbers: Map.unmodifiable(colNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      subGridNumbers: Map.unmodifiable(sgNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
    );
  }
}
