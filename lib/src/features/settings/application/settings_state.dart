/// Immutable state class holding global application settings.
class SettingsState {
  final double fontSizeFactor;
  final String gameThemePreset;

  const SettingsState({
    this.fontSizeFactor = 1.0,
    this.gameThemePreset = 'blue',
  });

  SettingsState copyWith({double? fontSizeFactor, String? gameThemePreset}) {
    return SettingsState(
      fontSizeFactor: fontSizeFactor ?? this.fontSizeFactor,
      gameThemePreset: gameThemePreset ?? this.gameThemePreset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.fontSizeFactor == fontSizeFactor &&
        other.gameThemePreset == gameThemePreset;
  }

  @override
  int get hashCode => fontSizeFactor.hashCode ^ gameThemePreset.hashCode;
}
