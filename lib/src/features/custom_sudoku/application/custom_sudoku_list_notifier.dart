import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../game/domain/entities/sudoku_board.dart';
import '../data/custom_sudoku_repository.dart';

final customSudokuListNotifierProvider =
    AsyncNotifierProvider<CustomSudokuListNotifier, List<SudokuBoard>>(() {
      return CustomSudokuListNotifier();
    });

class CustomSudokuListNotifier extends AsyncNotifier<List<SudokuBoard>> {
  @override
  Future<List<SudokuBoard>> build() async {
    return _loadPuzzles();
  }

  Future<List<SudokuBoard>> _loadPuzzles() async {
    final repository = ref.read(customSudokuRepositoryProvider);
    return repository.getCustomPuzzles();
  }

  Future<void> savePuzzle(SudokuBoard board) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(customSudokuRepositoryProvider);
      await repository.saveCustomPuzzle(board);
      state = AsyncValue.data(await _loadPuzzles());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deletePuzzle(String id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(customSudokuRepositoryProvider);
      await repository.deleteCustomPuzzle(id);
      state = AsyncValue.data(await _loadPuzzles());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
