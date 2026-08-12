import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mungsudoku/src/features/home/presentation/home_page.dart';
import 'package:mungsudoku/src/core/router/app_router.dart';
import 'package:mungsudoku/src/features/game/application/game_state.dart';
import 'package:mungsudoku/src/features/game/domain/enums/difficulty.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GoRouter router;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    router = GoRouter(
      initialLocation: AppRouter.homePath,
      routes: [
        GoRoute(
          path: AppRouter.homePath,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRouter.gamePath,
          builder: (context, state) => const Scaffold(body: Text('Game Page')),
        ),
        GoRoute(
          path: AppRouter.profilePath,
          builder: (context, state) =>
              const Scaffold(body: Text('Profile Page')),
        ),
        GoRoute(
          path: AppRouter.customSudokuListPath,
          builder: (context, state) =>
              const Scaffold(body: Text('Custom Sudoku List Page')),
        ),
        GoRoute(
          path: AppRouter.shopPath,
          builder: (context, state) => const Scaffold(body: Text('Shop Page')),
        ),
        GoRoute(
          path: AppRouter.settingsPath,
          builder: (context, state) =>
              const Scaffold(body: Text('Settings Page')),
        ),
      ],
    );
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(child: MaterialApp.router(routerConfig: router));
  }

  group('HomePage Tests', () {
    testWidgets(
      'a. Renders "New Game" and 4 bottom menus. No "Continue" when no save game',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('Continue'), findsNothing);
        expect(find.text('me'), findsOneWidget);
        expect(find.text('create'), findsOneWidget);
        expect(find.text('shop'), findsOneWidget);
        expect(find.text('settings'), findsOneWidget);
      },
    );

    testWidgets(
      'b. Renders "Continue" with dynamic text when save game exists',
      (tester) async {
        final mockState = GameState.initial().copyWith(
          difficulty: Difficulty.medium,
          gameDuration: const Duration(minutes: 2, seconds: 30),
        );

        SharedPreferences.setMockInitialValues({
          'current_game': jsonEncode(mockState.toJson()),
        });

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('New Game'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
        expect(find.text('Medium • 02:30'), findsOneWidget);
      },
    );

    testWidgets('c. Tapping "New Game" opens bottom sheet', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();

      // Check if difficulties are shown in bottom sheet
      expect(find.text('Fast'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Expert'), findsOneWidget);
      expect(find.text('Extreme'), findsOneWidget);
    });

    testWidgets('d. Tapping 4 ActionItem icons triggers correct navigation', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // me -> profile
      await tester.tap(find.text('me'));
      await tester.pumpAndSettle();
      expect(find.text('Profile Page'), findsOneWidget);
      router.go(AppRouter.homePath);
      await tester.pumpAndSettle();

      // create -> custom sudoku
      await tester.tap(find.text('create'));
      await tester.pumpAndSettle();
      expect(find.text('Custom Sudoku List Page'), findsOneWidget);
      router.go(AppRouter.homePath);
      await tester.pumpAndSettle();

      // shop -> shop
      await tester.tap(find.text('shop'));
      await tester.pumpAndSettle();
      expect(find.text('Shop Page'), findsOneWidget);
      router.go(AppRouter.homePath);
      await tester.pumpAndSettle();

      // settings -> settings
      await tester.tap(find.text('settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings Page'), findsOneWidget);
    });

    testWidgets(
      'e. Simulates back button press, verifies PopScope intercepts and shows Exit Dialog',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Simulate back button press using dynamic route pop
        final dynamic widgetsBinding = WidgetsBinding.instance;
        await widgetsBinding.handlePopRoute();
        await tester.pumpAndSettle();

        // Verify Dialog appears
        expect(find.text('Keluar dari MungSudoku?'), findsOneWidget);
        expect(find.text('Batal'), findsOneWidget);
        expect(find.text('Keluar'), findsOneWidget);

        // Tap Batal
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();

        // Verify Dialog dismissed
        expect(find.text('Keluar dari MungSudoku?'), findsNothing);
      },
    );
  });
}
