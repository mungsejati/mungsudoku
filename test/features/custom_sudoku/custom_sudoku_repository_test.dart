import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mungsudoku/src/features/custom_sudoku/data/custom_sudoku_repository.dart';
import 'package:mungsudoku/src/features/game/domain/entities/sudoku_board.dart';

void main() {
  late CustomSudokuRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = CustomSudokuRepository();
  });

  group('CustomSudokuRepository', () {
    test(
      'saveCustomPuzzle adds a new puzzle and generates id if null',
      () async {
        final emptyBoard = SudokuBoard.empty();
        expect(emptyBoard.id, isNull);

        await repository.saveCustomPuzzle(emptyBoard);

        final puzzles = await repository.getCustomPuzzles();
        expect(puzzles.length, 1);
        expect(puzzles.first.id, isNotNull);
        expect(puzzles.first.createdAt, isNotNull);
      },
    );

    test('deleteCustomPuzzle removes the puzzle with matching id', () async {
      final board1 = SudokuBoard.empty().copyWith(id: 'board-1');
      final board2 = SudokuBoard.empty().copyWith(id: 'board-2');

      await repository.saveCustomPuzzle(board1);
      await repository.saveCustomPuzzle(board2);

      var puzzles = await repository.getCustomPuzzles();
      expect(puzzles.length, 2);

      await repository.deleteCustomPuzzle('board-1');

      puzzles = await repository.getCustomPuzzles();
      expect(puzzles.length, 1);
      expect(puzzles.first.id, 'board-2');
    });
  });
}
