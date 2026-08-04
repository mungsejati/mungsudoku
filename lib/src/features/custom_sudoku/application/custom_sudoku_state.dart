import 'package:flutter/foundation.dart';
import '../../game/domain/entities/sudoku_board.dart';
import '../../game/domain/entities/sudoku_cell.dart';

@immutable
class CustomSudokuState {
  const CustomSudokuState({
    required this.board,
    this.selectedRow = -1,
    this.selectedCol = -1,
    this.conflictPositions = const <(int, int)>{},
    this.isValidating = false,
  });

  final SudokuBoard board;
  final int selectedRow;
  final int selectedCol;
  
  /// Cells that conflict with the rules (duplicate in row/col/subgrid)
  final Set<(int, int)> conflictPositions;
  
  /// True if currently running validation/solving
  final bool isValidating;

  bool get hasSelection => selectedRow >= 0 && selectedCol >= 0;

  CustomSudokuState copyWith({
    SudokuBoard? board,
    int? selectedRow,
    int? selectedCol,
    Set<(int, int)>? conflictPositions,
    bool? isValidating,
    bool clearSelection = false,
  }) {
    return CustomSudokuState(
      board: board ?? this.board,
      selectedRow: clearSelection ? -1 : (selectedRow ?? this.selectedRow),
      selectedCol: clearSelection ? -1 : (selectedCol ?? this.selectedCol),
      conflictPositions: conflictPositions ?? this.conflictPositions,
      isValidating: isValidating ?? this.isValidating,
    );
  }

  factory CustomSudokuState.initial({int gridSize = 9, int subGridSize = 3}) {
    final cells = List.generate(
      gridSize,
      (r) => List.generate(
        gridSize,
        (c) => SudokuCell(
          row: r,
          col: c,
          value: null,
          solutionValue: 1, // Placeholder since it's required to be >= 1
          isOriginal: false, // Initially empty
        ),
      ),
    );
    return CustomSudokuState(
      board: SudokuBoard(
        cells: cells,
        subGridSize: subGridSize,
        rowNumbers: {for (var i = 0; i < gridSize; i++) i: <int>{}},
        colNumbers: {for (var i = 0; i < gridSize; i++) i: <int>{}},
        subGridNumbers: {for (var i = 0; i < gridSize; i++) i: <int>{}},
      ),
      selectedRow: 0,
      selectedCol: 0,
    );
  }
}
