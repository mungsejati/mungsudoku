import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/application/settings_notifier.dart';

/// Defines the visual style of the Sudoku game board and its surrounding UI.
///
/// All colors and dimensions that make up the board's look-and-feel are
/// collected here so they can be swapped in one place without touching
/// individual widget code.
@immutable
class GameTheme {
  const GameTheme({
    required this.background,
    required this.subGridBackground,
    required this.subGridBorderRadius,
    required this.subGridSpacing,
    required this.subGridShadow,
    required this.cellBorderColor,
    required this.selectedCellColor,
    required this.selectedCellBorderColor,
    required this.identicalValueCellColor,
    required this.originalCellColor,
    required this.conflictCellColor,
    required this.crosshairColor,
    required this.originalTextColor,
    required this.inputTextColor,
    required this.conflictTextColor,
    required this.controlPadBackground,
    required this.controlPadShadow,
    required this.numpadBackground,
    required this.numpadButtonBackground,
    required this.numpadButtonShadow,
    required this.arcColor,
    required this.topBarTextColor,
    required this.topBarMistakeColor,
  });

  // ---- Board background ----
  final Color background;

  // ---- Sub-grid card ----
  final Color subGridBackground;
  final double subGridBorderRadius;
  final double subGridSpacing;
  final List<BoxShadow> subGridShadow;

  // ---- Cell separators (dashed lines inside sub-grids) ----
  final Color cellBorderColor;

  // ---- Cell highlight states ----
  final Color selectedCellColor;
  final Color selectedCellBorderColor;
  final Color identicalValueCellColor;
  final Color originalCellColor; // given / pre-filled cells
  final Color conflictCellColor;
  final Color crosshairColor;

  // ---- Cell text colors ----
  final Color originalTextColor;
  final Color inputTextColor;
  final Color conflictTextColor;

  // ---- Control toolbar (Undo / Erase / Notes / Hint) ----
  final Color controlPadBackground;
  final List<BoxShadow> controlPadShadow;

  // ---- Number pad ----
  final Color numpadBackground;
  final Color numpadButtonBackground;
  final List<BoxShadow> numpadButtonShadow;

  // ---- Decorative arcs (bottom-right corner ornament) ----
  final Color arcColor;

  // ---- Top Bar / Nav Bar (Timer, mistakes, title) ----
  final Color topBarTextColor;
  final Color topBarMistakeColor;

  // ---------------------------------------------------------------------------
  // Built-in themes
  // ---------------------------------------------------------------------------

  /// Classic bright-blue theme matching the reference design.
  static final blue = GameTheme(
    background: const Color(0xFF1E9BED),
    subGridBackground: Colors.white,
    subGridBorderRadius: 12,
    subGridSpacing: 7,
    subGridShadow: [
      BoxShadow(
        color: const Color(0xFF0D5FA0).withValues(alpha: 0.55),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    cellBorderColor: const Color(0xFFADD8F7),
    selectedCellColor: const Color(0xFFFFF59D),
    selectedCellBorderColor: const Color(0xFF1565C0),
    identicalValueCellColor: const Color(0xFFB3E5FC),
    originalCellColor: Colors.transparent,
    conflictCellColor: const Color(0xFFFFCDD2),
    crosshairColor: const Color(0xFFE2EAF3),
    originalTextColor: const Color(0xFF212121),
    inputTextColor: const Color(0xFF1565C0),
    conflictTextColor: const Color(0xFFD32F2F),
    controlPadBackground: Colors.white,
    controlPadShadow: [
      BoxShadow(
        color: const Color(0xFF0D5FA0).withValues(alpha: 0.50),
        blurRadius: 0,
        offset: const Offset(0, 5),
      ),
    ],
    numpadBackground: const Color(0xFFB3E5FC),
    numpadButtonBackground: Colors.white,
    numpadButtonShadow: [
      BoxShadow(
        color: const Color(0xFF0D5FA0).withValues(alpha: 0.50),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    arcColor: const Color(0xFF0D7EC4),
    topBarTextColor: Colors.white,
    topBarMistakeColor: const Color(0xFFFFB74D),
  );

  /// Red theme.
  static final red = GameTheme(
    background: const Color(0xFFE53935),
    subGridBackground: Colors.white,
    subGridBorderRadius: 12,
    subGridSpacing: 7,
    subGridShadow: [
      BoxShadow(
        color: const Color(0xFFB71C1C).withValues(alpha: 0.55),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    cellBorderColor: const Color(0xFFFFCDD2),
    selectedCellColor: const Color(0xFFFFF59D),
    selectedCellBorderColor: const Color(0xFFC62828),
    identicalValueCellColor: const Color(0xFFFFCDD2),
    originalCellColor: Colors.transparent,
    conflictCellColor: const Color(0xFFE57373),
    crosshairColor: const Color(0xFFFFEBEE),
    originalTextColor: const Color(0xFF212121),
    inputTextColor: const Color(0xFFC62828),
    conflictTextColor: const Color(0xFFD32F2F),
    controlPadBackground: Colors.white,
    controlPadShadow: [
      BoxShadow(
        color: const Color(0xFFB71C1C).withValues(alpha: 0.50),
        blurRadius: 0,
        offset: const Offset(0, 5),
      ),
    ],
    numpadBackground: const Color(0xFFFFCDD2),
    numpadButtonBackground: Colors.white,
    numpadButtonShadow: [
      BoxShadow(
        color: const Color(0xFFB71C1C).withValues(alpha: 0.50),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    arcColor: const Color(0xFFC62828),
    topBarTextColor: Colors.white,
    topBarMistakeColor: const Color(0xFFFFE082),
  );

  /// Green theme.
  static final green = GameTheme(
    background: const Color(0xFF43A047),
    subGridBackground: Colors.white,
    subGridBorderRadius: 12,
    subGridSpacing: 7,
    subGridShadow: [
      BoxShadow(
        color: const Color(0xFF1B5E20).withValues(alpha: 0.55),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    cellBorderColor: const Color(0xFFC8E6C9),
    selectedCellColor: const Color(0xFFFFF59D),
    selectedCellBorderColor: const Color(0xFF2E7D32),
    identicalValueCellColor: const Color(0xFFC8E6C9),
    originalCellColor: Colors.transparent,
    conflictCellColor: const Color(0xFFFFCDD2),
    crosshairColor: const Color(0xFFE8F5E9),
    originalTextColor: const Color(0xFF212121),
    inputTextColor: const Color(0xFF2E7D32),
    conflictTextColor: const Color(0xFFD32F2F),
    controlPadBackground: Colors.white,
    controlPadShadow: [
      BoxShadow(
        color: const Color(0xFF1B5E20).withValues(alpha: 0.50),
        blurRadius: 0,
        offset: const Offset(0, 5),
      ),
    ],
    numpadBackground: const Color(0xFFC8E6C9),
    numpadButtonBackground: Colors.white,
    numpadButtonShadow: [
      BoxShadow(
        color: const Color(0xFF1B5E20).withValues(alpha: 0.50),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    arcColor: const Color(0xFF2E7D32),
    topBarTextColor: Colors.white,
    topBarMistakeColor: const Color(0xFFFF8A65),
  );

  /// White / Light Minimalist theme.
  static final white = GameTheme(
    background: const Color(0xFFF5F5F5),
    subGridBackground: Colors.white,
    subGridBorderRadius: 12,
    subGridSpacing: 7,
    subGridShadow: [
      BoxShadow(
        color: const Color(0xFFBDBDBD).withValues(alpha: 0.55),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    cellBorderColor: const Color(0xFFE0E0E0),
    selectedCellColor: const Color(0xFFFFF59D),
    selectedCellBorderColor: const Color(0xFF424242),
    identicalValueCellColor: const Color(0xFFE0E0E0),
    originalCellColor: Colors.transparent,
    conflictCellColor: const Color(0xFFFFCDD2),
    crosshairColor: const Color(0xFFEEEEEE),
    originalTextColor: const Color(0xFF212121),
    inputTextColor: const Color(0xFF424242),
    conflictTextColor: const Color(0xFFD32F2F),
    controlPadBackground: Colors.white,
    controlPadShadow: [
      BoxShadow(
        color: const Color(0xFFBDBDBD).withValues(alpha: 0.50),
        blurRadius: 0,
        offset: const Offset(0, 5),
      ),
    ],
    numpadBackground: const Color(0xFFE0E0E0),
    numpadButtonBackground: Colors.white,
    numpadButtonShadow: [
      BoxShadow(
        color: const Color(0xFFBDBDBD).withValues(alpha: 0.50),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    arcColor: const Color(0xFFE0E0E0),
    topBarTextColor: Colors.black87,
    topBarMistakeColor: const Color(0xFFD32F2F),
  );

  /// Black / Dark OLED theme.
  static final black = GameTheme(
    background: const Color(0xFF000000),
    subGridBackground: const Color(0xFF1E1E1E),
    subGridBorderRadius: 12,
    subGridSpacing: 7,
    subGridShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.8),
        blurRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
    cellBorderColor: const Color(0xFF333333),
    selectedCellColor: const Color(0xFF424248),
    selectedCellBorderColor: const Color(0xFFFFD54F),
    identicalValueCellColor: const Color(0xFF65687C),
    originalCellColor: const Color(0xFF242424),
    conflictCellColor: const Color(0xFF4E1A1A),
    crosshairColor: const Color(0xFF33333C),
    originalTextColor: const Color(0xFF90CAF9),
    inputTextColor: const Color(0xFF90CAF9),
    conflictTextColor: const Color(0xFFEF9A9A),
    controlPadBackground: const Color(0xFF1E1E1E),
    controlPadShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.6),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
    numpadBackground: const Color(0xFF151515),
    numpadButtonBackground: const Color(0xFF2A2A2A),
    numpadButtonShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.6),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
    arcColor: const Color(0xFF000000),
    topBarTextColor: const Color(0xFF90CAF9),
    topBarMistakeColor: const Color(0xFFEF9A9A),
  );
}

/// Riverpod provider for the active [GameTheme].
///
/// Watches the SettingsNotifier's state to determine the active theme.
final gameThemeProvider = Provider<GameTheme>((ref) {
  final activeThemePreset = ref.watch(settingsNotifierProvider.select((state) => state.gameThemePreset));
  switch (activeThemePreset) {
    case 'red':
      return GameTheme.red;
    case 'green':
      return GameTheme.green;
    case 'white':
      return GameTheme.white;
    case 'black':
    case 'dark':
      return GameTheme.black;
    case 'blue':
    default:
      return GameTheme.blue;
  }
});
