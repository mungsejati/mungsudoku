import 'dart:async';

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/sudoku_generator.dart';
import '../domain/entities/sudoku_board.dart';
import '../domain/enums/difficulty.dart';
import '../domain/enums/symbol_type.dart';
import '../domain/services/sudoku_validator.dart';
import 'game_state.dart';

/// Riverpod [Notifier] that owns the complete lifecycle of a Sudoku session.
///
/// ## Responsibilities
///
/// - Starting and managing a new game session via [initNewGame].
/// - Routing player input for both Standard Mode (Method A) and Fast Mode
///   (Method B) via [selectCell], [activateValue], and [inputNumber].
/// - Maintaining the undo/redo board-snapshot stack.
/// - Managing hint quota and triggering the mock ad prompt.
/// - Running the per-second game timer.
/// - Triggering local auto-save after every state mutation (mock in Phase 1).
///
/// ## Input Modes
///
/// | Mode     | Flow                                                            |
/// |----------|-----------------------------------------------------------------|
/// | Standard | `selectCell(r,c)` → player taps numpad → `inputNumber(r,c,v)` |
/// | Fast     | `activateValue(v)` (long-press) → player taps cells           |
///
/// The notifier is mode-agnostic: the UI drives behaviour by calling the
/// appropriate selection method before [inputNumber].
///
/// ## Auto-Save (Mock)
///
/// [_autoSave] is called after every mutation. In Phase 1 it only logs.
/// In Phase 3, replace it with a Hive write + Supabase sync.
class GameNotifier extends Notifier<GameState> {
  static final _log = Logger('GameNotifier');

  Timer? _timer;

  bool _mounted = true;

  @override
  GameState build() {
    _mounted = true;
    ref.onDispose(() {
      _mounted = false;
      _cancelTimer();
    });
    return GameState.initial();
  }

  // ---------------------------------------------------------------------------
  // Game lifecycle
  // ---------------------------------------------------------------------------

  /// Initialises a new puzzle at the given [difficulty] and starts the timer.
  ///
  /// Puzzle generation is offloaded to a separate isolate via [compute] so
  /// that the UI thread is never blocked (backtracking can take several ms).
  Future<void> initNewGame(
    Difficulty difficulty, {
    int subGridSize = 3,
    SymbolType symbolType = SymbolType.standard,
  }) async {
    _log.info(
      'Starting new game — difficulty: ${difficulty.displayName}, size: $subGridSize, symbol: ${symbolType.name}',
    );
    _cancelTimer();

    state = state.copyWith(
      board: SudokuBoard.empty(subGridSize: subGridSize),
      difficulty: difficulty,
      selectedSubGridSize: subGridSize,
      symbolType: symbolType,
      gameDuration: Duration.zero,
      isPaused: false,
      isGameOver: false,
      isVictory: false,
      cumulativeMistakeCount: 0,
      undoStack: const [],
      redoStack: const [],
      conflictPositions: const <(int, int)>{},
      superHighlightPositions: const <(int, int)>{},
      isAutoCompleteRunning: false,
      isLoading: true,
      clearSelectedCell: true,
      clearActiveValue: true,
    );
    await Future.delayed(Duration.zero);

    final board = await compute(_generatePuzzle, (difficulty, subGridSize));

    state = GameState(
      board: board,
      difficulty: difficulty,
      selectedSubGridSize: subGridSize,
      symbolType: symbolType,
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
      superHighlightPositions: const <(int, int)>{},
      isLoading: false,
    );

    _startTimer();
    _log.info('Game ready. $board');
  }

  /// Pauses the game: stops the timer. Board is hidden in the UI.
  void pauseGame() {
    if (state.isPaused || state.isGameOver || state.isVictory) return;
    _cancelTimer();
    state = state.copyWith(isPaused: true);
    _log.fine('Game paused at ${state.gameDuration}');
  }

  /// Resumes a paused game: restarts the timer.
  void resumeGame() {
    if (!state.isPaused) return;
    state = state.copyWith(isPaused: false);
    _startTimer();
    _log.fine('Game resumed');
  }

  // ---------------------------------------------------------------------------
  // Cell & value selection
  // ---------------------------------------------------------------------------

  /// Selects a cell for Standard Input Mode (Method A).
  ///
  /// Tapping the same cell again deselects it.
  void selectCell(int row, int col) {
    if (_isBlocked) return;
    final alreadySelected =
        state.selectedRow == row && state.selectedCol == col;
    if (alreadySelected) {
      state = state.copyWith(clearSelectedCell: true);
    } else {
      state = state.copyWith(selectedRow: row, selectedCol: col);
    }
  }

  /// Activates (or deactivates) a numpad digit for Fast Input Mode (Method B).
  ///
  /// While a value is active, tapping any editable cell writes it immediately.
  /// Activating the same value again deactivates Fast Mode.
  void activateValue(int value) {
    if (_isBlocked) return;
    if (state.activeValue == value) {
      state = state.copyWith(clearActiveValue: true);
    } else {
      state = state.copyWith(activeValue: value);
    }
  }

  // ---------------------------------------------------------------------------
  // Input
  // ---------------------------------------------------------------------------

  /// Places [value] in the cell at ([row], [col]).
  ///
  /// Supports both input modes — the UI decides which cell and value to pass
  /// based on the active selection state.
  ///
  /// **Note mode:** writes [value] as a pencil mark (toggled).
  /// **Fill mode:** writes [value] as the definitive answer, clears notes,
  /// pushes the previous board onto [GameState.undoStack], and clears
  /// [GameState.redoStack].
  ///
  /// After every input, conflict detection is re-run and the board is checked
  /// for victory. Auto-save is triggered.
  void inputNumber(int row, int col, int value, {bool isAuto = false}) {
    if (!isAuto && _isBlocked) return;

    final cell = state.board.cellAt(row, col);
    if (!cell.isEditable) return;

    final SudokuBoard updatedBoard;
    int newMistakeCount = state.cumulativeMistakeCount;
    final Set<(int, int)> superHighlights = {};

    if (state.isNoteMode) {
      updatedBoard = state.board.updateCell(row, col, cell.toggleNote(value));
    } else {
      final newValue = cell.value == value ? null : value;
      final updatedCell = newValue == null
          ? cell.copyWith(clearValue: true)
          : cell.copyWith(value: newValue, notes: const {});
      var newBoard = state.board.updateCell(row, col, updatedCell);

      // Auto-Prune: remove the placed value from peer cells' notes
      if (newValue != null) {
        newBoard = newBoard.pruneNotesForPlacement(row, col, newValue);
      }
      updatedBoard = newBoard;

      // Count as a mistake only when placing a wrong answer (not when toggling off)
      if (newValue != null && newValue != cell.solutionValue) {
        newMistakeCount++;
        _log.warning('Mistake at ($row,$col): entered $newValue, expected ${cell.solutionValue}.');
      }

      // Check for sweep animation
      if (newValue != null && newValue == cell.solutionValue) {
        final int gridSize = state.board.gridSize;
        final int sgSize = state.board.subGridSize;
        final int sgIndex = (row ~/ sgSize) * sgSize + (col ~/ sgSize);
        
        if (updatedBoard.rowNumbers[row]!.length == gridSize) {
          for (int c = 0; c < gridSize; c++) {
            superHighlights.add((row, c));
          }
        }
        if (updatedBoard.colNumbers[col]!.length == gridSize) {
          for (int r = 0; r < gridSize; r++) {
            superHighlights.add((r, col));
          }
        }
        if (updatedBoard.subGridNumbers[sgIndex]!.length == gridSize) {
          final int startRow = (sgIndex ~/ sgSize) * sgSize;
          final int startCol = (sgIndex % sgSize) * sgSize;
          for (int r = startRow; r < startRow + sgSize; r++) {
            for (int c = startCol; c < startCol + sgSize; c++) {
              superHighlights.add((r, c));
            }
          }
        }
      }
    }

    _applyBoardUpdate(
      updatedBoard,
      cumulativeMistakeCount: newMistakeCount,
      newSuperHighlights: superHighlights,
      isAuto: isAuto,
    );
  }

  /// Clears the value (and notes) from the cell at ([row], [col]).
  ///
  /// Does nothing if the cell is original or already empty.
  void clearCell(int row, int col) {
    if (_isBlocked) return;
    final cell = state.board.cellAt(row, col);
    if (!cell.isEditable || cell.isEmpty) return;

    final updatedBoard = state.board.updateCell(
      row,
      col,
      cell.copyWith(clearValue: true),
    );
    _applyBoardUpdate(updatedBoard);
  }

  // ---------------------------------------------------------------------------
  // Note mode & Fast Note
  // ---------------------------------------------------------------------------

  /// Toggles pencil/notes input mode on or off.
  void toggleNoteMode() {
    if (state.isGameOver || state.isVictory) return;
    state = state.copyWith(isNoteMode: !state.isNoteMode);
    _log.fine('Note mode: ${state.isNoteMode}');
  }

  /// Auto-fills all empty editable cells with their valid note candidates.
  ///
  /// For each empty cell, every digit that does not already appear in the
  /// same row, column, or sub-grid is inserted as a pencil mark.
  /// Existing notes and filled cells are left untouched.
  void fastFillNotes() {
    if (_isBlocked) return;
    
    if (state.fastNoteQuota <= 0) {
      _log.info('[MOCK] Fast Notes exhausted — show "Watch Ad" dialog.');
      // TODO(phase1-ui): emit event / trigger dialog
      return;
    }

    var board = state.board;
    final size = board.gridSize;
    final allCandidates = {for (var i = 1; i <= size; i++) i};

    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final cell = board.cellAt(r, c);
        if (!cell.isEditable || cell.isFilled) continue;

        final sgIndex = (r ~/ board.subGridSize) * board.subGridSize + (c ~/ board.subGridSize);
        final used = <int>{
          ...board.rowNumbers[r]!,
          ...board.colNumbers[c]!,
          ...board.subGridNumbers[sgIndex]!,
        };

        final candidates = allCandidates.difference(used);

        if (candidates.isNotEmpty) {
          board = board.updateCell(r, c, cell.copyWith(notes: candidates));
        }
      }
    }

    _log.fine('Fast Note: filled candidates on all empty cells.');
    state = state.copyWith(
      board: board,
      fastNoteQuota: state.fastNoteQuota - 1,
      undoStack: [...state.undoStack, state.board],
      redoStack: const [],
    );
    _autoSave();
  }

  // ---------------------------------------------------------------------------
  // Hint system
  // ---------------------------------------------------------------------------

  /// Fills the currently selected cell with its [SudokuCell.solutionValue].
  ///
  /// **Preconditions (all must pass):**
  /// - A cell is selected ([GameState.hasSelection] == `true`).
  /// - The selected cell is editable and not already correct.
  /// - [GameState.remainingHints] > 0.
  ///
  /// When hints run out, the ad-prompt mock is triggered instead.
  /// Hint usage is recorded in the undo stack so it can be undone.
  void useHint() {
    if (_isBlocked) return;
    if (!state.hasSelection) return;

    final row = state.selectedRow!;
    final col = state.selectedCol!;
    final cell = state.board.cellAt(row, col);

    if (!cell.isEditable || cell.isCorrect) return;

    if (state.hintQuota <= 0) {
      _log.info('[MOCK] Hints exhausted — show "Watch Ad for +1 Hint" dialog.');
      // TODO(phase1-ui): emit an event / use a separate provider to trigger dialog.
      return;
    }

    final hintedCell = cell.copyWith(
      value: cell.solutionValue,
      notes: const {},
    );
    final updatedBoard = state.board.updateCell(row, col, hintedCell);
    final conflicts = SudokuValidator.findConflicts(updatedBoard);
    final isVictory = updatedBoard.isCompleted;

    state = state.copyWith(
      board: updatedBoard,
      hintQuota: state.hintQuota - 1,
      undoStack: [...state.undoStack, state.board],
      redoStack: const [],
      conflictPositions: conflicts,
      isVictory: isVictory,
    );

    _log.fine('Hint used at ($row,$col). Remaining: ${state.hintQuota}');
    _autoSave();
  }

  // ---------------------------------------------------------------------------
  // Auto-Complete
  // ---------------------------------------------------------------------------

  Future<void> triggerAutoComplete() async {
    if (_isBlocked || !state.canAutoComplete) return;

    _cancelTimer();
    state = state.copyWith(isAutoCompleteRunning: true);

    final board = state.board;
    final gridSize = board.gridSize;

    final emptyCells = <(int, int)>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (!board.cellAt(r, c).isFilled) {
          emptyCells.add((r, c));
        }
      }
    }

    for (final pos in emptyCells) {
      if (!_mounted) return;
      final cell = state.board.cellAt(pos.$1, pos.$2);
      if (!cell.isFilled) {
        inputNumber(pos.$1, pos.$2, cell.solutionValue, isAuto: true);
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }

    if (!_mounted) return;

    // Allow time for the final sweep animation to complete its 500ms cycle
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mounted) {
      state = state.copyWith(
        isAutoCompleteRunning: false,
        isVictory: true,
      );
      _clearSave();
    }
  }

  // ---------------------------------------------------------------------------
  // Undo / Redo
  // ---------------------------------------------------------------------------

  /// Reverts the board to the state before the last player action.
  void undo() {
    if (!state.canUndo || state.isPaused) return;

    final previousBoard = state.undoStack.last;
    final newUndo = state.undoStack.sublist(0, state.undoStack.length - 1);
    final newRedo = [...state.redoStack, state.board];
    final conflicts = SudokuValidator.findConflicts(previousBoard);

    state = state.copyWith(
      board: previousBoard,
      undoStack: newUndo,
      redoStack: newRedo,
      conflictPositions: conflicts,
      isVictory: false,
    );
    _autoSave();
  }

  /// Re-applies the last undone action.
  void redo() {
    if (!state.canRedo || state.isPaused) return;

    final nextBoard = state.redoStack.last;
    final newRedo = state.redoStack.sublist(0, state.redoStack.length - 1);
    final newUndo = [...state.undoStack, state.board];
    final conflicts = SudokuValidator.findConflicts(nextBoard);

    state = state.copyWith(
      board: nextBoard,
      undoStack: newUndo,
      redoStack: newRedo,
      conflictPositions: conflicts,
      isVictory: nextBoard.isCompleted,
    );
    _autoSave();
  }

  // ---------------------------------------------------------------------------
  // Theme Switching
  // ---------------------------------------------------------------------------

  void changeTheme(String themePreset) {
    state = state.copyWith(activeThemePreset: themePreset);
    _autoSave();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Determines if user input should be ignored (e.g. paused, game over, or auto-complete running).
  bool get _isBlocked =>
      state.isPaused || state.isGameOver || state.isVictory || state.isAutoCompleteRunning;

  // ---------------------------------------------------------------------------
  // Timer (private)
  // ---------------------------------------------------------------------------

  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    if (state.isPaused || state.isGameOver || state.isVictory) return;
    state = state.copyWith(
      gameDuration: state.gameDuration + const Duration(seconds: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  /// Pushes [updatedBoard] as the new game state, updating conflicts,
  /// undo stack, redo stack, and checking for victory. Triggers auto-save.
  void _applyBoardUpdate(
    SudokuBoard updatedBoard, {
    int? cumulativeMistakeCount,
    Set<(int, int)>? newSuperHighlights,
    bool isAuto = false,
  }) {
    final conflicts = SudokuValidator.findConflicts(updatedBoard);
    final isVictory = updatedBoard.isCompleted;
    final newMistakeCount =
        cumulativeMistakeCount ?? state.cumulativeMistakeCount;
    final isGameOver = newMistakeCount >= GameState.maxMistakes;

    state = state.copyWith(
      board: updatedBoard,
      undoStack: [...state.undoStack, state.board],
      redoStack: const [],
      conflictPositions: conflicts,
      superHighlightPositions: newSuperHighlights ?? const <(int, int)>{},
      cumulativeMistakeCount: newMistakeCount,
      isVictory: isAuto ? false : isVictory,
      isGameOver: isGameOver,
      isPaused: isGameOver ? false : state.isPaused,
    );

    if (newSuperHighlights != null && newSuperHighlights.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_mounted) {
          state = state.copyWith(superHighlightPositions: const <(int, int)>{});
        }
      });
    }

    if (isVictory || isGameOver) {
      _cancelTimer();
      _clearSave();
    }
    _autoSave();
  }

  // ---------------------------------------------------------------------------
  // Auto-save
  // ---------------------------------------------------------------------------

  /// Clears the saved game state from local storage.
  Future<void> _clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_game');
      _log.fine('Auto-save — game finished, save cleared.');
    } catch (e, stack) {
      _log.warning('Failed to clear save', e, stack);
    }
  }

  /// Persists the current game state to local storage.
  Future<void> _autoSave() async {
    if (state.isVictory || state.isGameOver || state.isLoading) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('current_game', jsonEncode(state.toJson()));
      _log.fine(
        'Auto-save — filled: ${state.board.filledCellCount}/'
        '${state.board.totalCells}, '
        'duration: ${state.gameDuration}',
      );
    } catch (e, stack) {
      _log.warning('Failed to auto-save game', e, stack);
    }
  }

  /// Loads the saved game state from local storage.
  Future<void> loadSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('current_game');
      if (savedData != null) {
        final Map<String, dynamic> json = jsonDecode(savedData);
        state = GameState.fromJson(json);
        _startTimer();
        _log.info('Game loaded successfully.');
      } else {
        _log.info('No saved game found.');
      }
    } catch (e, stack) {
      _log.warning('Failed to load saved game', e, stack);
      // Fallback to a new game if loading fails
      await initNewGame(Difficulty.easy);
    }
  }
}

// ---------------------------------------------------------------------------
// Isolate entry point
// ---------------------------------------------------------------------------

/// Top-level free function required by [compute].
///
/// Must NOT be a lambda or an instance method — [compute] serialises the
/// function reference to pass it to a background isolate.
SudokuBoard _generatePuzzle((Difficulty, int) args) =>
    SudokuGenerator.generate(args.$1, subGridSize: args.$2);

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Global [NotifierProvider] for [GameNotifier].
///
/// ```dart
/// // Read state:
/// final gameState = ref.watch(gameNotifierProvider);
///
/// // Call methods:
/// ref.read(gameNotifierProvider.notifier).inputNumber(row, col, value);
/// ```
final gameNotifierProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
);
