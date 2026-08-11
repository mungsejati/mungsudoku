
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_state.dart';

/// Notifier to manage global application settings (theme and font size).
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // Initial state: System theme and medium font size (1.0).
    // In the future, we can load these from SharedPreferences here.
    return const SettingsState();
  }

  /// Updates the global font size factor (e.g., 0.8 for small, 1.2 for big).
  void setFontSizeFactor(double factor) {
    state = state.copyWith(fontSizeFactor: factor);
  }

  /// Updates the global game theme preset.
  void setGameThemePreset(String preset) {
    state = state.copyWith(gameThemePreset: preset);
  }
}

/// Provider to expose the SettingsNotifier and its state.
final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
