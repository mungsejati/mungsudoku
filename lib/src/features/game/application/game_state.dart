import 'package:flutter/foundation.dart';

import '../domain/entities/sudoku_board.dart';
import '../domain/enums/difficulty.dart';
import '../domain/enums/symbol_type.dart';

/// Immutable snapshot of all game-related state for a single Sudoku session.
///
/// [GameNotifier] produces a new [GameState] for every state transition.
/// Riverpod rebuilds only the widgets that depend on the parts of [GameState]
/// that have actually changed.
///
/// ## Undo / Redo Stack
///
/// [undoStack] contains previous [SudokuBoard] snapshots in chronological
/// order (oldest at index 0, most recent at the end). [redoStack] holds
/// boards that were undone and can be re-applied. Any new player input
/// clears [redoStack] entirely.
///
/// ## Input Modes
///
/// | Mode     | Selection fields used                    |
/// |----------|------------------------------------------|
/// | Standard | [selectedRow] + [selectedCol]            |
/// | Fast     | [activeValue] (held numpad digit)        |
///
/// Both modes call [GameNotifier.inputNumber] — the difference is only in
/// which fields are set before the call.
@immutable
class GameState {
  const GameState({
    required this.board,
    required this.difficulty,
    required this.selectedSubGridSize,
    required this.symbolType,
    required this.gameDuration,
    required this.isPaused,
    required this.hintQuota,
    required this.fastNoteQuota,
    required this.activeThemePreset,
    required this.isNoteMode,
    required this.undoStack,
    required this.redoStack,
    required this.conflictPositions,
    this.cumulativeMistakeCount = 0,
    this.selectedRow,
    this.selectedCol,
    this.activeValue,
    this.isGameOver = false,
    this.isVictory = false,
  });

  /// Maximum mistakes before Game Over is triggered.
  static const int maxMistakes = 3;

  // --- Core game data ---

  /// The current visual and logical state of the puzzle grid.
  final SudokuBoard board;

  /// Difficulty level chosen at the start of this session.
  final Difficulty difficulty;

  /// The requested subGridSize for this session (e.g. 2, 3, 4, 5).
  final int selectedSubGridSize;

  /// The visual symbol type used for the game (e.g., standard, roman).
  final SymbolType symbolType;

  /// Elapsed playing time (paused time excluded).
  final Duration gameDuration;

  /// Whether the game is currently paused (timer stopped, board hidden in UI).
  final bool isPaused;

  // --- Mistake tracking ---

  /// Running total of wrong-value inputs during this session.
  ///
  /// Unlike [SudokuBoard.mistakeCount], this counter **never decreases**:
  /// erasing or correcting a wrong answer does not undo a recorded mistake.
  /// Triggers Game Over when it reaches [maxMistakes].
  final int cumulativeMistakeCount;

  // --- Hint system ---

  /// Number of hints the player can still use this session.
  /// Starts at 3; the UI should prompt a mock "Watch Ad" dialog when 0.
  final int hintQuota;

  /// Number of Fast Notes the player can still use this session.
  /// Starts at 3; the UI should prompt a mock "Watch Ad" dialog when 0.
  final int fastNoteQuota;

  /// The active theme preset for the UI (e.g., 'blue', 'dark').
  final String activeThemePreset;

  // --- Input mode ---

  /// Whether pencil/notes mode is active.
  ///
  /// When `true`, tapping a digit writes a pencil mark instead of a final
  /// answer. Placing a final answer clears the cell's notes automatically.
  final bool isNoteMode;

  // --- Selection: Standard Input Mode (Method A) ---

  /// Row of the currently selected cell. `null` when nothing is selected.
  final int? selectedRow;

  /// Column of the currently selected cell. `null` when nothing is selected.
  final int? selectedCol;

  // --- Selection: Fast Input Mode (Method B) ---

  /// The numpad digit currently "held" by the player. `null` when Fast Mode
  /// is not active. While set, tapping any editable cell writes this value.
  final int? activeValue;

  // --- Undo / Redo ---

  /// Board snapshots available for undo (oldest → newest).
  final List<SudokuBoard> undoStack;

  /// Board snapshots available for redo (oldest → newest).
  final List<SudokuBoard> redoStack;

  // --- Real-time conflict detection ---

  /// `(row, col)` positions whose values violate a Sudoku constraint.
  ///
  /// Recomputed by [SudokuValidator.findConflicts] after every player input.
  /// The UI uses this set to render the red conflict-highlight overlay.
  final Set<(int, int)> conflictPositions;

  // --- End-of-game flags ---

  /// `true` after a game-over condition is triggered (e.g. mistake limit).
  final bool isGameOver;

  /// `true` when [SudokuBoard.isCompleted] becomes `true`.
  final bool isVictory;

  // --- Derived helpers ---

  /// `true` when both [selectedRow] and [selectedCol] are non-null.
  bool get hasSelection => selectedRow != null && selectedCol != null;

  /// `true` when Fast Mode is active (a numpad digit is held).
  bool get isFastModeActive => activeValue != null;

  /// `true` when there is at least one action to undo.
  bool get canUndo => undoStack.isNotEmpty;

  /// `true` when there is at least one action to redo.
  bool get canRedo => redoStack.isNotEmpty;

  // --- Factory ---

  /// Creates the default state before any game has been loaded.
  factory GameState.initial() => GameState(
        board: SudokuBoard.empty(),
        difficulty: Difficulty.easy,
        selectedSubGridSize: 3,
        symbolType: SymbolType.standard,
        gameDuration: Duration.zero,
        isPaused: false,
        hintQuota: 3,
        fastNoteQuota: 3,
        activeThemePreset: 'blue',
        isNoteMode: false,
        cumulativeMistakeCount: 0,
        undoStack: const [],
        redoStack: const [],
        conflictPositions: const <(int, int)>{},
      );

  // --- Immutable copy ---

  /// Returns a new [GameState] with only the specified fields replaced.
  ///
  /// Use the `clear*` boolean flags to explicitly set nullable fields to
  /// `null` (passing `null` for a nullable field means "no change").
  GameState copyWith({
    SudokuBoard? board,
    Difficulty? difficulty,
    int? selectedSubGridSize,
    SymbolType? symbolType,
    Duration? gameDuration,
    bool? isPaused,
    int? hintQuota,
    int? fastNoteQuota,
    String? activeThemePreset,
    bool? isNoteMode,
    int? cumulativeMistakeCount,
    int? selectedRow,
    int? selectedCol,
    bool clearSelectedCell = false,
    int? activeValue,
    bool clearActiveValue = false,
    List<SudokuBoard>? undoStack,
    List<SudokuBoard>? redoStack,
    Set<(int, int)>? conflictPositions,
    bool? isGameOver,
    bool? isVictory,
  }) =>
      GameState(
        board: board ?? this.board,
        difficulty: difficulty ?? this.difficulty,
        selectedSubGridSize: selectedSubGridSize ?? this.selectedSubGridSize,
        symbolType: symbolType ?? this.symbolType,
        gameDuration: gameDuration ?? this.gameDuration,
        isPaused: isPaused ?? this.isPaused,
        hintQuota: hintQuota ?? this.hintQuota,
        fastNoteQuota: fastNoteQuota ?? this.fastNoteQuota,
        activeThemePreset: activeThemePreset ?? this.activeThemePreset,
        isNoteMode: isNoteMode ?? this.isNoteMode,
        cumulativeMistakeCount: cumulativeMistakeCount ?? this.cumulativeMistakeCount,
        selectedRow:
            clearSelectedCell ? null : (selectedRow ?? this.selectedRow),
        selectedCol:
            clearSelectedCell ? null : (selectedCol ?? this.selectedCol),
        activeValue:
            clearActiveValue ? null : (activeValue ?? this.activeValue),
        undoStack: undoStack ?? this.undoStack,
        redoStack: redoStack ?? this.redoStack,
        conflictPositions: conflictPositions ?? this.conflictPositions,
        isGameOver: isGameOver ?? this.isGameOver,
        isVictory: isVictory ?? this.isVictory,
      );

  // --- Serialization ---

  Map<String, dynamic> toJson() => {
        'board': board.toJson(),
        'difficulty': difficulty.name,
        'selectedSubGridSize': selectedSubGridSize,
        'symbolType': symbolType.name,
        'gameDurationSeconds': gameDuration.inSeconds,
        'isPaused': isPaused,
        'hintQuota': hintQuota,
        'fastNoteQuota': fastNoteQuota,
        'activeThemePreset': activeThemePreset,
        'isNoteMode': isNoteMode,
        'cumulativeMistakeCount': cumulativeMistakeCount,
        'selectedRow': selectedRow,
        'selectedCol': selectedCol,
        'activeValue': activeValue,
        'undoStack': undoStack.map((b) => b.toJson()).toList(),
        'redoStack': redoStack.map((b) => b.toJson()).toList(),
        'conflictPositions': conflictPositions.map((p) => {'row': p.$1, 'col': p.$2}).toList(),
        'isGameOver': isGameOver,
        'isVictory': isVictory,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: SudokuBoard.fromJson(json['board'] as Map<String, dynamic>),
      difficulty: Difficulty.values.firstWhere((e) => e.name == json['difficulty']),
      selectedSubGridSize: json['selectedSubGridSize'] as int,
      symbolType: SymbolType.values.firstWhere((e) => e.name == json['symbolType']),
      gameDuration: Duration(seconds: json['gameDurationSeconds'] as int),
      isPaused: json['isPaused'] as bool,
      hintQuota: json['hintQuota'] as int,
      fastNoteQuota: json['fastNoteQuota'] as int? ?? 3,
      activeThemePreset: json['activeThemePreset'] as String? ?? 'blue',
      isNoteMode: json['isNoteMode'] as bool,
      cumulativeMistakeCount: json['cumulativeMistakeCount'] as int,
      selectedRow: json['selectedRow'] as int?,
      selectedCol: json['selectedCol'] as int?,
      activeValue: json['activeValue'] as int?,
      undoStack: (json['undoStack'] as List<dynamic>)
          .map((e) => SudokuBoard.fromJson(e as Map<String, dynamic>))
          .toList(),
      redoStack: (json['redoStack'] as List<dynamic>)
          .map((e) => SudokuBoard.fromJson(e as Map<String, dynamic>))
          .toList(),
      conflictPositions: (json['conflictPositions'] as List<dynamic>)
          .map((e) => (e['row'] as int, e['col'] as int))
          .toSet(),
      isGameOver: json['isGameOver'] as bool,
      isVictory: json['isVictory'] as bool,
    );
  }
}
