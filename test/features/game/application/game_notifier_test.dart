import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mungsudoku/src/features/game/application/game_notifier.dart';
import 'package:mungsudoku/src/features/game/application/game_state.dart';
import 'package:mungsudoku/src/features/game/domain/enums/difficulty.dart';
import 'package:mungsudoku/src/features/game/domain/entities/sudoku_board.dart';
import 'package:mungsudoku/src/features/game/domain/entities/sudoku_cell.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer makeProviderContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('Test 1: initNewGame sets isLoading to true then false', () async {
    final container = makeProviderContainer();
    final notifier = container.read(gameNotifierProvider.notifier);

    final states = <GameState>[];
    container.listen<GameState>(
      gameNotifierProvider,
      (previous, next) => states.add(next),
      fireImmediately: false,
    );

    await notifier.initNewGame(Difficulty.easy, subGridSize: 2);
    
    final loadingStates = states.map((s) => s.isLoading).toList();
    expect(loadingStates.contains(true), isTrue, reason: 'Should have emitted isLoading: true');
    expect(states.last.isLoading, isFalse, reason: 'Final state should have isLoading: false');
  });

  test('Test 2: local save is cleared when isVictory is true', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = makeProviderContainer();
    final notifier = container.read(gameNotifierProvider.notifier);
    
    await notifier.initNewGame(Difficulty.easy, subGridSize: 2);
    
    // Simulate a move to create a save
    final board = notifier.state.board;
    var emptyPos = (0, 0);
    for (int r = 0; r < board.gridSize; r++) {
      for (int c = 0; c < board.gridSize; c++) {
        if (!board.cellAt(r, c).isFilled) {
          emptyPos = (r, c);
          break;
        }
      }
    }
    notifier.inputNumber(emptyPos.$1, emptyPos.$2, board.cellAt(emptyPos.$1, emptyPos.$2).solutionValue);
    
    await Future.delayed(const Duration(milliseconds: 100)); // wait for auto save
    expect(prefs.containsKey('current_game'), isTrue, reason: 'Save should exist after a move');
    
    // Now autocomplete to victory
    await notifier.triggerAutoComplete();
    
    await Future.delayed(const Duration(milliseconds: 100)); // wait for clear save
    expect(prefs.containsKey('current_game'), isFalse, reason: 'Save should be cleared on victory');
  });

  test('Test 3: wrong input triggers conflict', () async {
    final container = makeProviderContainer();
    final notifier = container.read(gameNotifierProvider.notifier);
    
    // Deterministic 2x2 board
    // Solution:
    // 1 2 | 3 4
    // 3 4 | 1 2
    // ---------
    // 2 1 | 4 3
    // 4 3 | 2 1
    //
    // Masked (given):
    // 1 2 | 3 0 (missing 4)
    // 0 0 | 0 0
    // ---------
    // 0 0 | 0 0
    // 0 0 | 0 0
    
    final size = 4;
    final cells = List.generate(size, (r) => List.generate(size, (c) => SudokuCell(row: r, col: c, solutionValue: 1, value: 0)));
    cells[0][0] = const SudokuCell(row: 0, col: 0, value: 1, solutionValue: 1, isOriginal: true);
    cells[0][1] = const SudokuCell(row: 0, col: 1, value: 2, solutionValue: 2, isOriginal: true);
    cells[0][2] = const SudokuCell(row: 0, col: 2, value: 3, solutionValue: 3, isOriginal: true);
    cells[0][3] = const SudokuCell(row: 0, col: 3, value: 0, solutionValue: 4, isOriginal: false); // empty

    final board = SudokuBoard(
      cells: cells, 
      subGridSize: 2, 
      rowNumbers: {0: {1, 2, 3}, 1: {}, 2: {}, 3: {}}, 
      colNumbers: {0: {1}, 1: {2}, 2: {3}, 3: {}}, 
      subGridNumbers: {0: {1, 2}, 1: {3}, 2: {}, 3: {}}
    );
    
    await notifier.initNewGame(Difficulty.easy, subGridSize: 2);
    notifier.state = notifier.state.copyWith(board: board);
    
    // Input WRONG number (2) in (0,3). 2 is already in row 0.
    notifier.inputNumber(0, 3, 2);
    
    expect(notifier.state.conflictPositions.isNotEmpty, isTrue, reason: 'Should flag conflict');
    expect(notifier.state.cumulativeMistakeCount, equals(1), reason: 'Mistake count should increase');
  });

  test('Test 4: Auto-Complete sets isAutoCompleteRunning to true', () async {
    final container = makeProviderContainer();
    final notifier = container.read(gameNotifierProvider.notifier);
    
    await notifier.initNewGame(Difficulty.easy, subGridSize: 2);
    
    final states = <GameState>[];
    container.listen<GameState>(
      gameNotifierProvider,
      (previous, next) => states.add(next),
      fireImmediately: false,
    );
    
    final future = notifier.triggerAutoComplete();
    
    // State should immediately show isAutoCompleteRunning = true
    expect(notifier.state.isAutoCompleteRunning, isTrue);
    
    await future; // wait for it to finish
    
    expect(notifier.state.isAutoCompleteRunning, isFalse);
    expect(notifier.state.isVictory, isTrue);
  });

  test('Test 5: restartPuzzle restores initial board and resets mistakes', () async {
    final container = makeProviderContainer();
    final notifier = container.read(gameNotifierProvider.notifier);
    
    await notifier.initNewGame(Difficulty.easy, subGridSize: 2);
    final initialBoard = notifier.state.board;
    
    // Simulate some moves and mistakes
    final board = notifier.state.board;
    var emptyPos = (0, 0);
    for (int r = 0; r < board.gridSize; r++) {
      for (int c = 0; c < board.gridSize; c++) {
        if (!board.cellAt(r, c).isFilled) {
          emptyPos = (r, c);
          break;
        }
      }
    }
    
    // Input something to increase mistakes
    final correctVal = board.cellAt(emptyPos.$1, emptyPos.$2).solutionValue;
    final wrongVal = correctVal == 1 ? 2 : 1; 
    notifier.inputNumber(emptyPos.$1, emptyPos.$2, wrongVal);
    
    expect(notifier.state.cumulativeMistakeCount, equals(1));
    expect(notifier.state.board.filledCellCount, greaterThan(initialBoard.filledCellCount));
    
    // Now restart
    notifier.restartPuzzle();
    
    expect(notifier.state.cumulativeMistakeCount, equals(0));
    expect(notifier.state.board.filledCellCount, equals(initialBoard.filledCellCount));
    expect(notifier.state.gameDuration, equals(Duration.zero));
  });

  test('Test 6: useHint auto-prunes notes from peers', () async {
    final container = makeProviderContainer();
    final notifier = container.read(gameNotifierProvider.notifier);
    
    await notifier.initNewGame(Difficulty.easy, subGridSize: 2);
    
    // Find two empty cells in the same row
    final board = notifier.state.board;
    var empty1 = (-1, -1);
    var empty2 = (-1, -1);
    for (int r = 0; r < board.gridSize; r++) {
      for (int c = 0; c < board.gridSize; c++) {
        if (!board.cellAt(r, c).isFilled) {
          if (empty1.$1 == -1) {
            empty1 = (r, c);
          } else if (empty1.$1 == r) {
            empty2 = (r, c);
            break;
          }
        }
      }
      if (empty2.$1 != -1) break;
    }
    
    // If not found in same row, just use any two empty cells, but ideally we want peers
    // For a generated board with 2x2, there should be some empty peers.
    if (empty2.$1 == -1) return; // skip if no two empty cells in same row
    
    final correctVal = board.cellAt(empty1.$1, empty1.$2).solutionValue;
    
    // Add notes to both empty cells
    // Turn on note mode
    notifier.toggleNoteMode();
    
    // Add correctVal as a note to empty2
    notifier.inputNumber(empty2.$1, empty2.$2, correctVal);
    expect(notifier.state.board.cellAt(empty2.$1, empty2.$2).notes, contains(correctVal));
    
    // Turn off note mode
    notifier.toggleNoteMode();
    
    // Use hint on empty1
    notifier.selectCell(empty1.$1, empty1.$2);
    notifier.useHint();
    
    // Verify empty1 is filled with correctVal
    final filledCell = notifier.state.board.cellAt(empty1.$1, empty1.$2);
    expect(filledCell.value, equals(correctVal));
    expect(filledCell.notes, isEmpty, reason: 'Hint should clear notes on target cell');
    
    // Verify empty2 note was auto-pruned
    final peerCell = notifier.state.board.cellAt(empty2.$1, empty2.$2);
    expect(peerCell.notes, isNot(contains(correctVal)), reason: 'Hint should auto-prune notes from peers');
  });
}
