import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mungsudoku/src/features/shop/presentation/shop_page.dart';

void main() {
  // Standard phone viewport used across all tests.
  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget createWidgetUnderTest() {
    return const ProviderScope(child: MaterialApp(home: ShopPage()));
  }

  testWidgets('ShopPage renders top-area cards in 2-column layout',
      (WidgetTester tester) async {
    setPhoneViewport(tester);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // App bar title
    expect(find.text('Shop'), findsOneWidget);

    // Both compact cards visible without scrolling
    expect(find.text('Daily Focus'), findsOneWidget);
    // 'Pro Upgrade' also appears as a benefit in the Gold tier card
    expect(find.text('Pro Upgrade'), findsAtLeastNWidgets(1));
    expect(find.text('Claim'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
  });

  testWidgets(
      'ShopPage renders scarcity header and all 3 tier cards simultaneously',
      (WidgetTester tester) async {
    setPhoneViewport(tester);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Scroll a bit to bring the Founders section into view
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Scarcity header
    expect(find.text('THE FOUNDERS EDITION'), findsOneWidget);
    expect(
      find.text('Global Founder Slots: 1,452 / 2,000 Tersisa'),
      findsOneWidget,
    );

    // All 3 tier cards must be visible at the same time (no horizontal scroll)
    expect(find.text('Silver'), findsOneWidget);
    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('Diamond'), findsOneWidget);
  });

  testWidgets('Gold tier shows Best Value badge', (WidgetTester tester) async {
    setPhoneViewport(tester);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('Best Value'), findsOneWidget);
  });

  testWidgets('All 3 tiers show Pilih Paket buttons',
      (WidgetTester tester) async {
    setPhoneViewport(tester);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Three "Pilih Paket" buttons — one per tier
    expect(find.text('Pilih Paket'), findsNWidgets(3));
  });

  testWidgets('Claim button shows SnackBar', (WidgetTester tester) async {
    setPhoneViewport(tester);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Claim'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Berhasil mengklaim paket Daily Focus Allowance!'),
      findsOneWidget,
    );
  });

  testWidgets('Silver Pilih Paket button shows SnackBar',
      (WidgetTester tester) async {
    setPhoneViewport(tester);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // First "Pilih Paket" corresponds to Silver (leftmost column)
    await tester.tap(find.text('Pilih Paket').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Berhasil mengklaim paket Silver Investor!'),
      findsOneWidget,
    );
  });

  testWidgets('Gold Pilih Paket button shows SnackBar',
      (WidgetTester tester) async {
    setPhoneViewport(tester);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Second "Pilih Paket" corresponds to Gold (center column)
    final pilihPaketButtons = find.text('Pilih Paket');
    await tester.tap(pilihPaketButtons.at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Berhasil mengklaim paket Gold Investor!'),
      findsOneWidget,
    );
  });
}
