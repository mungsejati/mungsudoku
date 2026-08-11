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
    final isBlackTheme = gameTheme.background == const Color(0xFF5A5A5A);

    // Use background as accent seed.
    // If the game theme is white, it will be invisible on a white menu background,
    // so we fall back to the brand blue.
    // If the game theme is black, use #5A5A5A so it isn't pure black.
    final seed = isWhiteTheme
        ? const Color(0xFF0092DF)
        : (isBlackTheme ? const Color(0xFF5A5A5A) : gameTheme.background);

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
