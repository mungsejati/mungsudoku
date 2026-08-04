import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mungsudoku/src/features/game/application/game_notifier.dart';
import 'package:mungsudoku/src/features/game/application/game_state.dart';
import 'package:mungsudoku/src/features/game/data/services/sudoku_generator.dart';
import 'package:mungsudoku/src/features/game/domain/entities/sudoku_board.dart';
import 'package:mungsudoku/src/features/game/domain/entities/sudoku_cell.dart';
import 'package:mungsudoku/src/features/game/domain/enums/difficulty.dart';
import 'package:mungsudoku/src/features/game/domain/services/sudoku_validator.dart';

void main() {
  group('SudokuValidator Tests', () {
    test('Empty board has no conflicts', () {
      final board = SudokuBoard.empty();
      final conflicts = SudokuValidator.findConflicts(board);
      expect(conflicts, isEmpty);
    });

    test('Detects conflict in the same row', () {
      var board = SudokuBoard.empty();
      // Place two 5s in the first row
      board = board.updateCell(
          0, 0, const SudokuCell(row: 0, col: 0, solutionValue: 5, value: 5));
      board = board.updateCell(
          0, 8, const SudokuCell(row: 0, col: 8, solutionValue: 5, value: 5));

      final conflicts = SudokuValidator.findConflicts(board);
      expect(conflicts, containsAll([(0, 0), (0, 8)]));
    });

    test('Detects conflict in the same column', () {
      var board = SudokuBoard.empty();
      // Place two 7s in the first column
      board = board.updateCell(
          0, 0, const SudokuCell(row: 0, col: 0, solutionValue: 7, value: 7));
      board = board.updateCell(
          8, 0, const SudokuCell(row: 8, col: 0, solutionValue: 7, value: 7));

      final conflicts = SudokuValidator.findConflicts(board);
      expect(conflicts, containsAll([(0, 0), (8, 0)]));
    });

    test('Detects conflict in the same 3x3 sub-grid', () {
      var board = SudokuBoard.empty();
      // Place two 9s in the top-left sub-grid (rows 0-2, cols 0-2)
      board = board.updateCell(
          0, 0, const SudokuCell(row: 0, col: 0, solutionValue: 9, value: 9));
      board = board.updateCell(
          2, 2, const SudokuCell(row: 2, col: 2, solutionValue: 9, value: 9));

      final conflicts = SudokuValidator.findConflicts(board);
      expect(conflicts, containsAll([(0, 0), (2, 2)]));
    });
  });

  group('SudokuGenerator Tests', () {
    test('Generated full solution board is valid (0 conflicts)', () {
      // Generate a board. A newly generated board might have empty cells based on difficulty.
      // We'll fill it with its solution values to test the full solution validity.
      final board = SudokuGenerator.generate(Difficulty.easy);
      var fullBoard = board;

      for (var r = 0; r < board.gridSize; r++) {
        for (var c = 0; c < board.gridSize; c++) {
          final cell = board.cellAt(r, c);
          if (cell.isEmpty) {
             fullBoard = fullBoard.updateCell(r, c, cell.copyWith(value: cell.solutionValue));
          }
        }
      }

      final conflicts = SudokuValidator.findConflicts(fullBoard);
      expect(conflicts, isEmpty, reason: 'Full solution board should have no conflicts.');
      expect(fullBoard.isCompleted, isTrue, reason: 'Board should be marked as completed.');
    });

    test('Given cells count matches difficulty (Easy, Medium, Hard)', () {
      final easyBoard = SudokuGenerator.generate(Difficulty.easy);
      final mediumBoard = SudokuGenerator.generate(Difficulty.medium);
      final hardBoard = SudokuGenerator.generate(Difficulty.hard);

      expect(easyBoard.filledCellCount, greaterThanOrEqualTo(Difficulty.easy.givenCellCount));
      expect(mediumBoard.filledCellCount, greaterThanOrEqualTo(Difficulty.medium.givenCellCount));
      expect(hardBoard.filledCellCount, greaterThanOrEqualTo(Difficulty.hard.givenCellCount));
    });
  });

  group('GameNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('selectCell updates selected row and col', () {
      final notifier = container.read(gameNotifierProvider.notifier);
      
      notifier.selectCell(3, 4);
      var state = container.read(gameNotifierProvider);
      
      expect(state.selectedRow, equals(3));
      expect(state.selectedCol, equals(4));

      // Tapping same cell deselects
      notifier.selectCell(3, 4);
      state = container.read(gameNotifierProvider);
      expect(state.selectedRow, isNull);
      expect(state.selectedCol, isNull);
    });

    test('inputNumber updates board immutably and handles notes correctly', () async {
      final notifier = container.read(gameNotifierProvider.notifier);
      await notifier.initNewGame(Difficulty.easy);
      
      var state = container.read(gameNotifierProvider);
      // Find an empty, editable cell
      int? targetRow;
      int? targetCol;
      for (var r = 0; r < state.board.gridSize; r++) {
        for (var c = 0; c < state.board.gridSize; c++) {
          if (state.board.cellAt(r, c).isEditable) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
        if (targetRow != null) break;
      }
      
      expect(targetRow, isNotNull);
      final initialBoard = state.board;

      // Input value 5
      notifier.inputNumber(targetRow!, targetCol!, 5);
      state = container.read(gameNotifierProvider);
      
      expect(state.board, isNot(equals(initialBoard)), reason: 'Board should be a new instance');
      expect(state.board.cellAt(targetRow, targetCol).value, equals(5));

      // Toggle Note Mode and input a note (e.g., 7)
      notifier.toggleNoteMode();
      notifier.inputNumber(targetRow, targetCol, 7);
      state = container.read(gameNotifierProvider);
      
      // Since cell had value 5, writing a note doesn't work if value is present according to current impl?
      // Wait, let's test note on a clear cell.
      notifier.toggleNoteMode(); // Turn off note mode
      notifier.inputNumber(targetRow, targetCol, 5); // Toggles value 5 off (clears it)
      state = container.read(gameNotifierProvider);
      expect(state.board.cellAt(targetRow, targetCol).isEmpty, isTrue);

      notifier.toggleNoteMode(); // Turn note mode ON
      final validNote = state.board.cellAt(targetRow, targetCol).solutionValue;
      notifier.inputNumber(targetRow, targetCol, validNote); // add valid note
      state = container.read(gameNotifierProvider);
      expect(state.board.cellAt(targetRow, targetCol).notes, contains(validNote));
    });

    test('undo and redo restore board states accurately', () async {
      final notifier = container.read(gameNotifierProvider.notifier);
      await notifier.initNewGame(Difficulty.easy);
      
      var state = container.read(gameNotifierProvider);
      
      // Find an empty cell
      int? tr, tc;
      for (var r = 0; r < state.board.gridSize; r++) {
        for (var c = 0; c < state.board.gridSize; c++) {
          if (state.board.cellAt(r, c).isEditable) {
            tr = r;
            tc = c;
            break;
          }
        }
        if (tr != null) break;
      }
      
      final boardState1 = state.board;
      
      // Action 1: input 1
      notifier.inputNumber(tr!, tc!, 1);
      final boardState2 = container.read(gameNotifierProvider).board;
      
      // Undo
      notifier.undo();
      state = container.read(gameNotifierProvider);
      expect(state.board, equals(boardState1));
      
      // Redo
      notifier.redo();
      state = container.read(gameNotifierProvider);
      expect(state.board, equals(boardState2));
    });

    test('useHint decreases hint quota and fills correct cell', () async {
      final notifier = container.read(gameNotifierProvider.notifier);
      await notifier.initNewGame(Difficulty.easy);
      
      var state = container.read(gameNotifierProvider);
      
      // Find an empty cell
      int? tr, tc;
      for (var r = 0; r < state.board.gridSize; r++) {
        for (var c = 0; c < state.board.gridSize; c++) {
          if (state.board.cellAt(r, c).isEditable) {
            tr = r;
            tc = c;
            break;
          }
        }
        if (tr != null) break;
      }
      
      final cellBefore = state.board.cellAt(tr!, tc!);
      final solution = cellBefore.solutionValue;
      final initialHints = state.hintQuota;
      
      notifier.selectCell(tr, tc);
      notifier.useHint();
      
      state = container.read(gameNotifierProvider);
      final cellAfter = state.board.cellAt(tr, tc);
      
      expect(state.hintQuota, equals(initialHints - 1));
      expect(cellAfter.value, equals(solution));
      expect(cellAfter.isCorrect, isTrue);
    });

    test('wrong input increments cumulativeMistakeCount, correct input does not', () async {
      final notifier = container.read(gameNotifierProvider.notifier);
      await notifier.initNewGame(Difficulty.easy);

      var state = container.read(gameNotifierProvider);

      // Find an editable cell and its solution
      int? tr, tc;
      for (var r = 0; r < state.board.gridSize; r++) {
        for (var c = 0; c < state.board.gridSize; c++) {
          if (state.board.cellAt(r, c).isEditable) {
            tr = r;
            tc = c;
            break;
          }
        }
        if (tr != null) break;
      }

      final solution = state.board.cellAt(tr!, tc!).solutionValue;

      // Enter a wrong value (pick something that is definitely not the solution)
      final wrongValue = solution == 1 ? 2 : 1;
      notifier.inputNumber(tr, tc, wrongValue);
      state = container.read(gameNotifierProvider);
      expect(state.cumulativeMistakeCount, equals(1),
          reason: 'One wrong input should increment mistake count to 1.');

      // Erase the wrong value — mistake count must NOT decrease
      notifier.clearCell(tr, tc);
      state = container.read(gameNotifierProvider);
      expect(state.cumulativeMistakeCount, equals(1),
          reason: 'Erasing a wrong answer must not reduce the mistake count.');

      // Enter the correct value — must not increment mistake count
      notifier.inputNumber(tr, tc, solution);
      state = container.read(gameNotifierProvider);
      expect(state.cumulativeMistakeCount, equals(1),
          reason: 'A correct input must not increment the mistake count.');
    });

    test('game over triggers after maxMistakes wrong inputs', () async {
      final notifier = container.read(gameNotifierProvider.notifier);
      await notifier.initNewGame(Difficulty.easy);

      var state = container.read(gameNotifierProvider);

      // Collect up to maxMistakes editable cells with known wrong values
      final targets = <(int, int, int)>[];
      outer:
      for (var r = 0; r < state.board.gridSize; r++) {
        for (var c = 0; c < state.board.gridSize; c++) {
          final cell = state.board.cellAt(r, c);
          if (cell.isEditable) {
            final wrong = cell.solutionValue == 1 ? 2 : 1;
            targets.add((r, c, wrong));
            if (targets.length == GameState.maxMistakes) break outer;
          }
        }
      }

      expect(targets.length, equals(GameState.maxMistakes),
          reason: 'Need at least maxMistakes editable cells.');

      for (final (r, c, wrong) in targets) {
        state = container.read(gameNotifierProvider);
        // Clear cell before entering wrong value so previous value doesn't clash
        notifier.clearCell(r, c);
        notifier.inputNumber(r, c, wrong);
      }

      state = container.read(gameNotifierProvider);
      expect(state.cumulativeMistakeCount, greaterThanOrEqualTo(GameState.maxMistakes));
      expect(state.isGameOver, isTrue, reason: 'Game Over must be triggered after maxMistakes.');
    });

    test('fastFillNotes fills valid candidates on empty cells', () async {
      final notifier = container.read(gameNotifierProvider.notifier);
      await notifier.initNewGame(Difficulty.easy);

      notifier.fastFillNotes();
      final state = container.read(gameNotifierProvider);
      final board = state.board;

      // Every empty editable cell should have at least one note
      for (var r = 0; r < board.gridSize; r++) {
        for (var c = 0; c < board.gridSize; c++) {
          final cell = board.cellAt(r, c);
          if (cell.isEditable && cell.isEmpty) {
            expect(cell.notes.isNotEmpty, isTrue,
                reason: 'Cell ($r,$c) should have candidate notes after fastFillNotes.');
          }
        }
      }

      // All filled notes must be valid placements
      for (var r = 0; r < board.gridSize; r++) {
        for (var c = 0; c < board.gridSize; c++) {
          final cell = board.cellAt(r, c);
          for (final note in cell.notes) {
            expect(
              SudokuValidator.isValidPlacement(board, r, c, note),
              isTrue,
              reason: 'Note $note at ($r,$c) must be a valid candidate.',
            );
          }
        }
      }
    });
  });
}

