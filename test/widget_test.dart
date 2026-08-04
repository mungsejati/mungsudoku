import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mungsudoku/main.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches and shows Home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: MungSudokuApp()),
    );
    // Use pump instead of pumpAndSettle because of infinite repeating animation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('NEW GAME'), findsOneWidget);
  });
}
