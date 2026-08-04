import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/domain/services/sudoku_validator.dart';
import '../../game/data/services/sudoku_generator.dart';
import 'custom_sudoku_state.dart';

final customSudokuNotifierProvider = NotifierProvider<CustomSudokuNotifier, CustomSudokuState>(() {
  return CustomSudokuNotifier();
});

class CustomSudokuNotifier extends Notifier<CustomSudokuState> {
  @override
  CustomSudokuState build() {
    return CustomSudokuState.initial();
  }

  void selectCell(int row, int col) {
    state = state.copyWith(selectedRow: row, selectedCol: col);
  }

  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }

  /// Inputs a value (1-9) or clears (0) at the currently selected cell
  void inputNumber(int value) {
    if (!state.hasSelection || state.isValidating) return;

    final r = state.selectedRow;
    final c = state.selectedCol;

    final currentCell = state.board.cellAt(r, c);
    
    // We store the input as value and solutionValue. We treat them as given/original.
    final updatedCell = value == 0 
        ? currentCell.copyWith(clearValue: true, solutionValue: 1, isOriginal: false)
        : currentCell.copyWith(value: value, solutionValue: value, isOriginal: true);

    final updatedBoard = state.board.updateCell(r, c, updatedCell);
    
    // Re-check basic conflicts immediately for visual feedback
    final conflicts = SudokuValidator.findConflicts(updatedBoard);

    // Auto-advance cursor
    int nextRow = r;
    int nextCol = c + 1;
    if (nextCol >= updatedBoard.gridSize) {
      nextCol = 0;
      nextRow++;
    }
    
    if (nextRow >= updatedBoard.gridSize) {
      // Reached the end, wrap to beginning or stay? Let's just clear selection or wrap to 0,0
      nextRow = 0;
      nextCol = 0;
    }

    state = state.copyWith(
      board: updatedBoard,
      conflictPositions: conflicts,
      selectedRow: nextRow,
      selectedCol: nextCol,
    );
  }

  /// Validates if the board has exactly one unique solution
  Future<bool> validateAndPreparePlay() async {
    state = state.copyWith(isValidating: true);

    try {
      // 1. Check basic constraint conflicts
      final conflicts = SudokuValidator.findConflicts(state.board);
      if (conflicts.isNotEmpty) {
        state = state.copyWith(conflictPositions: conflicts, isValidating: false);
        return false;
      }

      // 2. Check if we have at least 17 givens (minimum for unique solution in 9x9)
      int filled = 0;
      for (var r = 0; r < state.board.gridSize; r++) {
        for (var c = 0; c < state.board.gridSize; c++) {
          if (state.board.cellAt(r, c).value != null) filled++;
        }
      }
      
      if (state.board.gridSize == 9 && filled < 17) {
        state = state.copyWith(isValidating: false);
        return false; // Impossible to be unique
      }

      // Extract raw grid for the solver
      final grid = List.generate(state.board.gridSize, (r) {
        return List.generate(state.board.gridSize, (c) => state.board.cellAt(r, c).value ?? 0);
      });

      // 3. Offload to isolate if needed, but for uniqueness limit 2 it might be fast enough
      // To prevent UI freeze, we can use a microtask or compute
      final isUnique = await Future.microtask(() => 
          SudokuGenerator.hasUniqueSolution(grid, state.board.gridSize, state.board.subGridSize));
      
      if (!isUnique) {
        state = state.copyWith(isValidating: false);
        return false;
      }

      return true;
    } catch (e) {
      state = state.copyWith(isValidating: false);
      return false;
    }
  }

  /// Returns the fully solved grid as a flat list if valid, otherwise null.
  List<int>? getSolvedGrid() {
    final grid = List.generate(state.board.gridSize, (r) {
      return List.generate(state.board.gridSize, (c) => state.board.cellAt(r, c).value ?? 0);
    });
    return SudokuGenerator.solveGrid(grid, state.board.gridSize, state.board.subGridSize);
  }
}
