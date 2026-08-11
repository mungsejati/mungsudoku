import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mungsudoku/src/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets('SettingsPage renders and handles state changes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsPage(),
        ),
      ),
    );

    // Verify initial render
    expect(find.text('Board Preview'), findsOneWidget);
    expect(find.text('Game Theme'), findsOneWidget);
    expect(find.text('Font Size'), findsOneWidget);

    // Initial state check - default should be Medium (1.0)
    final mediumButton = tester.widget<SegmentedButton<double>>(find.byType(SegmentedButton<double>).first);
    expect(mediumButton.selected.contains(1.0), isTrue);

    // Tap on Red Game Theme
    await tester.tap(find.text('Red'));
    await tester.pumpAndSettle();

    // Tap on Big Font
    await tester.tap(find.text('Big'));
    await tester.pumpAndSettle();

    final bigButton = tester.widget<SegmentedButton<double>>(find.byType(SegmentedButton<double>).first);
    expect(bigButton.selected.contains(1.2), isTrue);
  });
}
