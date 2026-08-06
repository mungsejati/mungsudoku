import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mungsudoku/main.dart';

import 'dart:convert';
import 'package:mungsudoku/src/features/game/application/game_state.dart';
import 'package:mungsudoku/src/features/game/domain/enums/difficulty.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches and shows Home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: MungSudokuApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('me'), findsOneWidget);
    expect(find.text('create'), findsOneWidget);
  });

  testWidgets('App shows Continue button with dynamic text when save exists', (WidgetTester tester) async {
    final state = GameState.initial().copyWith(
      difficulty: Difficulty.medium,
      gameDuration: const Duration(minutes: 2, seconds: 30),
    );
    final savedGameJson = jsonEncode(state.toJson());
    
    SharedPreferences.setMockInitialValues({
      'current_game': savedGameJson,
    });
    
    await tester.pumpWidget(
      const ProviderScope(child: MungSudokuApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Medium • 02:30'), findsOneWidget);
  });
}
