import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mungsudoku/src/features/game/application/game_notifier.dart';
import 'package:mungsudoku/src/features/game/domain/entities/sudoku_board.dart';
import 'package:mungsudoku/src/features/game/domain/entities/sudoku_cell.dart';
import 'package:mungsudoku/src/features/game/presentation/game_page.dart';
import 'package:mungsudoku/src/features/game/presentation/widgets/sudoku_board_widget.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GameNotifier.disableTimerForTest = true;
  });

  ProviderContainer createTestContainer() {
    final container = ProviderContainer();
    addTearDown(() {
      try {
        container.read(gameNotifierProvider.notifier).pauseGame();
      } catch (_) {}
      container.dispose();
    });
    return container;
  }

  SudokuBoard createTestBoard() {
    final size = 9;
    final cells = List.generate(
      size,
      (r) => List.generate(size, (c) {
        int val = ((r * 3 + r ~/ 3 + c) % 9) + 1;
        return SudokuCell(
          row: r,
          col: c,
          solutionValue: val,
          value: null,
          isOriginal: false,
        );
      }),
    );
    // Make (0,0) original
    cells[0][0] = cells[0][0].copyWith(
      value: cells[0][0].solutionValue,
      isOriginal: true,
    );

    return SudokuBoard(
      cells: cells,
      subGridRows: 3,
      subGridCols: 3,
      rowNumbers: {
        for (int i = 0; i < 9; i++)
          i: i == 0 ? {cells[0][0].solutionValue} : {},
      },
      colNumbers: {
        for (int i = 0; i < 9; i++)
          i: i == 0 ? {cells[0][0].solutionValue} : {},
      },
      subGridNumbers: {
        for (int i = 0; i < 9; i++)
          i: i == 0 ? {cells[0][0].solutionValue} : {},
      },
    );
  }

  Widget createWidgetUnderTest(ProviderContainer container) {
    final router = GoRouter(
      initialLocation: '/game',
      routes: [
        GoRoute(path: '/game', builder: (context, state) => const GamePage()),
        GoRoute(
          path: '/result',
          builder: (context, state) =>
              const Scaffold(body: Text('Result Page')),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const Scaffold(body: Text('Settings Page')),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('GamePage Integration & Widget Tests', () {
    testWidgets('Test 1: Top Bar rendering', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      expect(find.text('Sudoku'), findsOneWidget); // Title
      expect(
        find.text('Hard'),
        findsOneWidget,
      ); // Difficulty (Custom game defaults to hard)
      expect(find.text('Mistakes: 0/3'), findsOneWidget); // Mistakes
      expect(find.byIcon(Icons.pause), findsOneWidget); // Timer pause button
    });

    testWidgets('Test 2: Settings navigation', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      // Tap settings button
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      // Should navigate to Settings Page
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets('Test 3: Pause interaction', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Resume Game'), findsOneWidget);
      expect(find.text('Restart Puzzle'), findsOneWidget);
      expect(find.text('Quit to Main Menu'), findsOneWidget);

      await tester.tap(find.text('Resume Game'));
      await tester.pumpAndSettle();

      expect(find.text('Paused'), findsNothing);
    });

    testWidgets('Test 4: Board rendering', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      expect(find.byType(SudokuCellTile), findsNWidgets(81));
    });

    testWidgets('Test 5: Highlight logic', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      // Tap cell (0, 1)
      final cell01 = find.byWidgetPredicate(
        (w) => w is SudokuCellTile && w.cell.row == 0 && w.cell.col == 1,
      );
      await tester.tap(cell01);
      await tester.pumpAndSettle();

      final state = container.read(gameNotifierProvider);
      expect(state.selectedRow, 0);
      expect(state.selectedCol, 1);
    });

    testWidgets('Test 6: Text colors based on state', (tester) async {
      // Verifying actual colors is tricky without inspecting the specific painter or text style.
      // But we can verify that the cell widgets have the correct data (isOriginal, isCorrect, etc).
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final originalCell = tester.widget<SudokuCellTile>(
        find.byWidgetPredicate(
          (w) => w is SudokuCellTile && w.cell.row == 0 && w.cell.col == 0,
        ),
      );
      expect(originalCell.cell.isOriginal, true);
    });

    testWidgets('Test 7: Toggle cell', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final cell01 = find.byWidgetPredicate(
        (w) => w is SudokuCellTile && w.cell.row == 0 && w.cell.col == 1,
      );
      await tester.tap(cell01);
      await tester.pumpAndSettle();

      var state = container.read(gameNotifierProvider);
      expect(state.selectedRow, 0);

      // Tap same cell to deactivate
      await tester.tap(cell01);
      await tester.pumpAndSettle();

      state = container.read(gameNotifierProvider);
      expect(state.selectedRow, null);
    });

    testWidgets('Test 8: Auto-prune', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final notifier = container.read(gameNotifierProvider.notifier);

      // Add note 2 to cell (0, 1)
      notifier.toggleNoteMode();
      notifier.inputNumber(0, 1, 2);

      // Fill cell (0, 2) with 2
      notifier.toggleNoteMode();
      notifier.inputNumber(0, 2, 2);

      final state = container.read(gameNotifierProvider);
      // Note 2 should be pruned from (0, 1)
      expect(state.board.cellAt(0, 1).notes.contains(2), false);
    });

    testWidgets('Test 9: Auto-complete', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);
      final notifier = container.read(gameNotifierProvider.notifier);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      // Fill board until 9 cells left
      int emptyCount = 80; // 1 is original
      for (int r = 0; r < 9 && emptyCount > 9; r++) {
        for (int c = 0; c < 9 && emptyCount > 9; c++) {
          final cell = notifier.state.board.cellAt(r, c);
          if (!cell.isFilled) {
            notifier.inputNumber(r, c, cell.solutionValue);
            emptyCount--;
          }
        }
      }

      // Wait 300ms for auto-complete trigger
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.text('Auto completing...'), findsOneWidget);

      // Flush remaining timers from auto-complete animation
      await tester.pumpAndSettle();
    });

    testWidgets('Test 10: Standard Input Mode', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final cell01 = find.byWidgetPredicate(
        (w) => w is SudokuCellTile && w.cell.row == 0 && w.cell.col == 1,
      );
      await tester.tap(cell01);
      await tester.pumpAndSettle();

      // Find numpad 5
      final num5 = find
          .byWidgetPredicate(
            (w) => w is Text && w.data == '5' && (w.style?.fontSize ?? 0) > 10,
          )
          .first;
      await tester.tap(num5);
      await tester.pumpAndSettle();

      final state = container.read(gameNotifierProvider);
      expect(state.board.cellAt(0, 1).value, 5);
    });

    testWidgets('Test 11: Fast Input Mode', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final num3 = find
          .byWidgetPredicate(
            (w) => w is Text && w.data == '3' && (w.style?.fontSize ?? 0) > 10,
          )
          .first;
      await tester.longPress(num3);
      await tester.pumpAndSettle();

      expect(container.read(gameNotifierProvider).activeValue, 3);

      final cell02 = find.byWidgetPredicate(
        (w) => w is SudokuCellTile && w.cell.row == 0 && w.cell.col == 2,
      );
      await tester.tap(cell02);
      await tester.pumpAndSettle();

      final state = container.read(gameNotifierProvider);
      expect(state.board.cellAt(0, 2).value, 3);
    });

    testWidgets('Test 12: Fast Input changing numpad digit', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final num3 = find
          .byWidgetPredicate(
            (w) => w is Text && w.data == '3' && (w.style?.fontSize ?? 0) > 10,
          )
          .first;
      await tester.longPress(num3);
      await tester.pumpAndSettle();

      final num7 = find
          .byWidgetPredicate(
            (w) => w is Text && w.data == '7' && (w.style?.fontSize ?? 0) > 10,
          )
          .first;
      await tester.longPress(num7);
      await tester.pumpAndSettle();

      expect(container.read(gameNotifierProvider).activeValue, 7);
    });

    testWidgets('Test 13: Mistakes limit', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final notifier = container.read(gameNotifierProvider.notifier);

      // Make 3 mistakes
      notifier.inputNumber(0, 1, 9); // Wrong
      notifier.inputNumber(0, 2, 9); // Wrong
      notifier.inputNumber(0, 3, 9); // Wrong

      await tester.pumpAndSettle();
      // Should navigate to result
      expect(find.text('Result Page'), findsOneWidget);
    });

    testWidgets('Test 14: Win condition', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);
      final notifier = container.read(gameNotifierProvider.notifier);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = notifier.state.board.cellAt(r, c);
          if (!cell.isFilled) {
            notifier.inputNumber(r, c, cell.solutionValue, isAuto: false);
          }
        }
      }

      await tester.pumpAndSettle();
      expect(find.text('Result Page'), findsOneWidget);
    });

    testWidgets('Test 15: Undo', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.inputNumber(0, 1, 5); // Some move

      await tester.pumpAndSettle();
      expect(container.read(gameNotifierProvider).board.cellAt(0, 1).value, 5);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(
        container.read(gameNotifierProvider).board.cellAt(0, 1).value,
        null,
      );
    });

    testWidgets('Test 16: Erase', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.inputNumber(0, 1, 5);

      await tester.pumpAndSettle();

      // Select cell and erase
      final cell01 = find.byWidgetPredicate(
        (w) => w is SudokuCellTile && w.cell.row == 0 && w.cell.col == 1,
      );
      await tester.tap(cell01);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Erase'));
      await tester.pumpAndSettle();

      expect(
        container.read(gameNotifierProvider).board.cellAt(0, 1).value,
        null,
      );
    });

    testWidgets('Test 17: Fast Notes, Notes Toggle, Hint', (tester) async {
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      // Fast Notes
      await tester.tap(find.text('Fast Note'));
      await tester.pumpAndSettle();

      final state = container.read(gameNotifierProvider);
      expect(state.board.cellAt(0, 1).notes.isNotEmpty, true);

      // Notes Toggle
      await tester.tap(find.text('Note'));
      await tester.pumpAndSettle();
      expect(container.read(gameNotifierProvider).isNoteMode, true);

      // Hint
      final cell02 = find.byWidgetPredicate(
        (w) => w is SudokuCellTile && w.cell.row == 0 && w.cell.col == 2,
      );
      await tester.tap(cell02);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hint'));
      await tester.pumpAndSettle();

      expect(
        container.read(gameNotifierProvider).board.cellAt(0, 2).isCorrect,
        true,
      );
      container.read(gameNotifierProvider.notifier).pauseGame();
    });
    testWidgets('Test 18: System back button toggles pause state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = createTestContainer();

      final board = createTestBoard();
      container.read(gameNotifierProvider.notifier).initCustomGame(board);

      await tester.pumpWidget(createWidgetUnderTest(container));
      await tester.pumpAndSettle();

      // State is initially running (not paused)
      expect(container.read(gameNotifierProvider).isPaused, false);

      // Simulate system back button
      final dynamic widgetsBinding = WidgetsBinding.instance;
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      // Verify game is paused
      expect(container.read(gameNotifierProvider).isPaused, true);
      expect(find.text('Resume Game'), findsOneWidget);

      // Simulate system back button again
      await widgetsBinding.handlePopRoute();
      await tester.pumpAndSettle();

      // Verify game is resumed
      expect(container.read(gameNotifierProvider).isPaused, false);
      expect(find.text('Resume Game'), findsNothing);
    });
  });
}
