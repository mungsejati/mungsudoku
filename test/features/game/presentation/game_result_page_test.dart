import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mungsudoku/src/features/game/domain/enums/difficulty.dart';
import 'package:mungsudoku/src/features/game/presentation/game_result_args.dart';
import 'package:mungsudoku/src/features/game/presentation/game_result_page.dart';

void main() {
  Widget createWidgetUnderTest(GameResultArgs args) {
    return ProviderScope(
      child: MaterialApp(
        home: GameResultPage(args: args),
      ),
    );
  }

  testWidgets('renders Victory page with correct stats', (WidgetTester tester) async {
    const args = GameResultArgs(
      isVictory: true,
      difficulty: Difficulty.medium,
      time: Duration(minutes: 5, seconds: 30),
      mistakes: 1,
      maxMistakes: 3,
    );

    await tester.pumpWidget(createWidgetUnderTest(args));

    // Verify title and message
    expect(find.text('Victory!'), findsOneWidget);
    expect(find.text('Congratulations on solving the puzzle!'), findsOneWidget);

    // Verify stats
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('05:30'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    // Verify buttons
    expect(find.text('Play Again'), findsOneWidget);
    expect(find.text('Main Menu'), findsOneWidget);
  });

  testWidgets('renders Game Over page with correct message', (WidgetTester tester) async {
    const args = GameResultArgs(
      isVictory: false,
      difficulty: Difficulty.hard,
      time: Duration(minutes: 10, seconds: 45),
      mistakes: 3,
      maxMistakes: 3,
    );

    await tester.pumpWidget(createWidgetUnderTest(args));

    // Verify title and message
    expect(find.text('Game Over'), findsOneWidget);
    expect(find.text('You have reached the maximum number of mistakes.'), findsOneWidget);

    // Verify stats
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('10:45'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);

    // Verify buttons
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.text('Main Menu'), findsOneWidget);
  });
}
