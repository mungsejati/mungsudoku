import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Entity representing the player's profile and productivity metrics.
class ProfileEntity {
  final String userName;
  final String avatarAsset;
  final String title;
  final int gamesPlayed;
  final double winRate;
  final int dailyFocusStreak;
  final int deepWorkSessions;
  final int silentProductivityTimeInMinutes;

  const ProfileEntity({
    required this.userName,
    required this.avatarAsset,
    required this.title,
    required this.gamesPlayed,
    required this.winRate,
    required this.dailyFocusStreak,
    required this.deepWorkSessions,
    required this.silentProductivityTimeInMinutes,
  });
}

/// A mock repository that provides hardcoded profile data for UI testing.
class MockProfileRepository {
  /// The hardcoded data that developers can easily modify to test different UI states.
  final ProfileEntity mockData = const ProfileEntity(
    userName: 'Sudoku Ninja',
    avatarAsset:
        'assets/person.svg', // Reusing an existing icon for dummy avatar
    title: 'Sudoku Master',
    gamesPlayed: 142,
    winRate: 85.5,
    dailyFocusStreak: 12,
    deepWorkSessions: 34,
    silentProductivityTimeInMinutes: 450, // 7.5 hours
  );

  ProfileEntity getProfile() {
    return mockData;
  }
}

/// Provider to expose the MockProfileRepository
final profileRepositoryProvider = Provider<MockProfileRepository>((ref) {
  return MockProfileRepository();
});

/// Provider to expose the ProfileEntity data directly to the UI
final profileDataProvider = Provider<ProfileEntity>((ref) {
  return ref.watch(profileRepositoryProvider).getProfile();
});
