import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mungsudoku/src/features/custom_sudoku/application/custom_sudoku_list_notifier.dart';
import 'package:mungsudoku/src/features/custom_sudoku/data/custom_sudoku_repository.dart';
import 'package:mungsudoku/src/features/game/domain/entities/sudoku_board.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('CustomSudokuListNotifier', () {
    test('initial state is loaded from repository', () async {
      final container = makeProviderContainer();
      final repo = container.read(customSudokuRepositoryProvider);
      
      final board = SudokuBoard.empty();
      await repo.saveCustomPuzzle(board);

      final notifier = container.read(customSudokuListNotifierProvider.notifier);
      final list = await notifier.future;
      expect(list.length, 1);
    });

    test('deletePuzzle removes item and updates state', () async {
      final container = makeProviderContainer();
      final repo = container.read(customSudokuRepositoryProvider);
      
      final board1 = SudokuBoard.empty().copyWith(id: 'delete-1');
      await repo.saveCustomPuzzle(board1);
      
      final notifier = container.read(customSudokuListNotifierProvider.notifier);
      var list = await notifier.future;
      expect(list.length, 1);
      
      await notifier.deletePuzzle('delete-1');
      list = await notifier.future;
      expect(list, isEmpty);
    });
  });
}
