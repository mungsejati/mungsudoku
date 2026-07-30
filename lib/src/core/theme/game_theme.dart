import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/game/application/game_notifier.dart';

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
        offset: const Offset(3, 4),
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
  );

  /// Dark / night theme.
  static final dark = GameTheme(
    background: const Color(0xFF1A1A2E),
    subGridBackground: const Color(0xFF252540),
    subGridBorderRadius: 12,
    subGridSpacing: 7,
    subGridShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    cellBorderColor: const Color(0xFF3A3A5A),
    selectedCellColor: const Color(0xFF5D4037),
    selectedCellBorderColor: const Color(0xFFFFD54F),
    identicalValueCellColor: const Color(0xFF263238),
    originalCellColor: const Color(0xFF37374A),
    conflictCellColor: const Color(0xFF4E1A1A),
    crosshairColor: const Color(0xFF2C2C4A),
    originalTextColor: const Color(0xFFEEEEEE),
    inputTextColor: const Color(0xFF90CAF9),
    conflictTextColor: const Color(0xFFEF9A9A),
    controlPadBackground: const Color(0xFF252540),
    controlPadShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
    numpadBackground: const Color(0xFF1E1E38),
    numpadButtonBackground: const Color(0xFF303050),
    numpadButtonShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
    arcColor: const Color(0xFF0D0D20),
  );
}

/// Riverpod provider for the active [GameTheme].
///
/// Watches the GameNotifier's state to determine the active theme.
final gameThemeProvider = Provider<GameTheme>((ref) {
  final activeThemePreset = ref.watch(gameNotifierProvider.select((state) => state.activeThemePreset));
  if (activeThemePreset == 'dark') return GameTheme.dark;
  return GameTheme.blue;
});
