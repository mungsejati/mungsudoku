import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mungsudoku/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsPage Global State Propagation Full Flow', (tester) async {
    // We run all scenarios in a single test to avoid static GoRouter conflicts.
    await tester.pumpWidget(const ProviderScope(child: MungSudokuApp()));
    await tester.pumpAndSettle();

    // ------------------------------------------------------------------------
    // Scenario 1: Initial State Verification
    // ------------------------------------------------------------------------
    await tester.tap(find.text('settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    
    final mediumButton = tester.widget<SegmentedButton<double>>(
      find.byType(SegmentedButton<double>).first,
    );
    expect(mediumButton.selected.contains(1.0), isTrue);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, isNotNull);

    // ------------------------------------------------------------------------
    // Scenario 2: Theme Propagation & Routing
    // ------------------------------------------------------------------------
    await tester.tap(find.text('Red'));
    await tester.pumpAndSettle();
    
    // Navigate Back to home
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    // Go to Custom Sudoku
    await tester.tap(find.text('create'));
    await tester.pumpAndSettle();
    
    // Verify no overflow and it renders
    expect(find.text('My Sudoku'), findsOneWidget);

    // Go back to home
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();

    // Go to Settings again
    await tester.tap(find.text('settings'));
    await tester.pumpAndSettle();
    
    // Tap 'Black'
    await tester.tap(find.text('Black'));
    await tester.pumpAndSettle();
    
    expect(tester.takeException(), isNull);

    // ------------------------------------------------------------------------
    // Scenario 3: Font Size Propagation
    // ------------------------------------------------------------------------
    // Check current scale
    BuildContext context = tester.element(find.text('Settings').first);
    var scale = MediaQuery.of(context).textScaler;
    expect(scale.scale(10), equals(10.0)); // 1.0 scale

    // Tap 'Big'
    await tester.tap(find.text('Big'));
    await tester.pumpAndSettle();

    // Re-evaluate scale
    context = tester.element(find.text('Settings').first);
    scale = MediaQuery.of(context).textScaler;
    expect(scale.scale(10) > 10, isTrue); // > 1.0 scale

    // Tap 'Small'
    await tester.tap(find.text('Small'));
    await tester.pumpAndSettle();
    
    context = tester.element(find.text('Settings').first);
    scale = MediaQuery.of(context).textScaler;
    expect(scale.scale(10) < 10, isTrue); // < 1.0 scale
    
    expect(tester.takeException(), isNull);

    // ------------------------------------------------------------------------
    // Scenario 4: Live Preview Reaction
    // ------------------------------------------------------------------------
    expect(find.text('Board Preview'), findsOneWidget);

    await tester.tap(find.text('Green'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Small'));
    await tester.pumpAndSettle();
    
    expect(find.text('5'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
