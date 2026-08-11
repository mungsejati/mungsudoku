import 'package:flutter/material.dart';
import 'game_theme.dart';

/// Defines the global application theme.
///
/// The theme uses the [GameTheme]'s accent color as the seed, but does NOT
/// override background or text colors globally — each page manages those.
abstract final class AppTheme {
  static ThemeData build(GameTheme gameTheme) {
    // Derive light/dark brightness from the game background luminance.
    final isDark = gameTheme.background.computeLuminance() < 0.5;
    final isWhiteTheme = gameTheme.background.computeLuminance() > 0.8;

    // Use background as accent seed.
    // If the game theme is white, it will be invisible on a white menu background,
    // so we fall back to the brand blue. Black and other colors work perfectly.
    final seed = isWhiteTheme
        ? const Color(0xFF0092DF)
        : gameTheme.background;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: seed, // Ensures the exact solid color is used instead of a faded variant
      ),
    );
  }
}
