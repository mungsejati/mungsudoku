import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mungsudoku/src/features/profile/data/mock_profile_repository.dart';
import 'package:mungsudoku/src/features/profile/presentation/profile_page.dart';

void main() {
  testWidgets('ProfilePage renders mock data correctly', (
    WidgetTester tester,
  ) async {
    final mockRepo = MockProfileRepository();
    final profile = mockRepo.getProfile();

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ProfilePage())),
    );

    // Verify header information
    expect(find.text(profile.userName), findsOneWidget);
    expect(find.text(profile.title), findsOneWidget);

    // Verify metrics are displayed
    expect(find.text('Games Played'), findsOneWidget);
    expect(find.text(profile.gamesPlayed.toString()), findsOneWidget);
    expect(find.text('${profile.winRate}% Win Rate'), findsOneWidget);

    expect(find.text('Focus Streak'), findsOneWidget);
    expect(find.text('${profile.dailyFocusStreak}'), findsOneWidget);

    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.text('${profile.deepWorkSessions}'), findsOneWidget);

    expect(find.text('Silent Time'), findsOneWidget);

    // There shouldn't be any layout overflows ideally, test will pass if it renders.
    // By finding all these widgets, we verify it rendered successfully.
  });
}
