import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mungsudoku/src/features/shop/presentation/shop_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const ProviderScope(child: MaterialApp(home: ShopPage()));
  }

  testWidgets('ShopPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verifikasi app bar
    expect(find.text('Shop'), findsOneWidget);

    // Verifikasi item pembelian ada
    expect(find.text('Remove Ads'), findsOneWidget);
    expect(find.text('Skins / Themes'), findsOneWidget);
    expect(find.text('+5 Hints'), findsOneWidget);
    expect(find.text('+20 Hints'), findsOneWidget);
    expect(find.text('Fast Notes Pack'), findsOneWidget);
  });

  testWidgets('Clicking item shows SnackBar', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap on an item
    await tester.tap(find.text('Remove Ads'));
    await tester.pump(); // Start animation
    await tester.pump(
      const Duration(milliseconds: 100),
    ); // Advance animation a bit

    // Verify snackbar is displayed
    expect(
      find.text('Pembelian Remove Ads berhasil ditambahkan ke akun (Mock)'),
      findsOneWidget,
    );
  });
}
