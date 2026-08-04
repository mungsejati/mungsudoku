import 'package:flutter/foundation.dart';

/// An immutable value object representing a single cell in the Sudoku grid.
///
/// ## Symbol-Agnostic Design (Phase 2 Future-Proofing)
///
/// All values — [value], [solutionValue], and [notes] — are stored as plain
/// [int]s (1 to `gridSize`). The domain layer is completely decoupled from
/// visual symbols. The presentation layer maps each integer to the appropriate
/// display symbol (digit, Roman numeral, letter, color swatch) via a
/// `SymbolMapper`, so the entire game engine works identically regardless of
/// the active symbol set chosen by the player.
///
/// ## Fields
///
/// | Field           | Description                                          |
/// |-----------------|------------------------------------------------------|
/// | [row]           | Zero-indexed row coordinate on the board             |
/// | [col]           | Zero-indexed column coordinate on the board          |
/// | [value]         | Player's current entry; `null` when the cell is empty|
/// | [solutionValue] | The provably correct answer for this cell            |
/// | [isOriginal]    | `true` when pre-filled by the puzzle; not editable   |
/// | [notes]         | Set of pencil-mark candidates chosen by the player   |
///
/// ## Constraints
/// - An [isOriginal] cell must have a non-null [value].
/// - [solutionValue] must be ≥ 1.
@immutable
class SudokuCell {
  const SudokuCell({
    required this.row,
    required this.col,
    required this.solutionValue,
    this.value,
    this.isOriginal = false,
    this.notes = const {},
  })  : assert(row >= 0, 'row must be non-negative.'),
        assert(col >= 0, 'col must be non-negative.'),
        assert(solutionValue >= 1, 'solutionValue must be at least 1.'),
        assert(
          !isOriginal || value != null,
          'An original (pre-filled) cell must have a non-null value.',
        );

  /// Zero-indexed row position of this cell on the board.
  final int row;

  /// Zero-indexed column position of this cell on the board.
  final int col;

  /// The player's current entry. `null` when the cell has not been filled yet.
  ///
  /// For [isOriginal] cells this always equals [solutionValue].
  final int? value;

  /// The provably correct answer for this cell, as determined by the puzzle
  /// generator. Never changes after the puzzle is created.
  ///
  /// Used by [isIncorrect], [isCorrect], and the Hint system.
  final int solutionValue;

  /// `true` if this cell was pre-filled by the puzzle generator.
  ///
  /// Original cells are not editable by the player; the UI should enforce
  /// this by ignoring input events on [isOriginal] cells.
  final bool isOriginal;

  /// Pencil-mark candidates the player has noted in this cell.
  ///
  /// Uses the same [int] representation as [value] and [solutionValue], so
  /// Phase 2 symbol mapping applies to notes automatically.
  ///
  /// Placing a final [value] should clear all notes via [copyWith].
  final Set<int> notes;

  // --- Derived state ---

  /// `true` when [value] is `null` (no entry yet).
  bool get isEmpty => value == null;

  /// `true` when [value] is non-null.
  bool get isFilled => value != null;

  /// `true` when this cell can be edited by the player.
  bool get isEditable => !isOriginal;

  /// `true` when the player has at least one pencil mark in this cell.
  bool get hasNotes => notes.isNotEmpty;

  /// `true` when [value] is non-null AND does not equal [solutionValue].
  ///
  /// Referenced by [SudokuBoard.mistakeCount] and the error-highlight overlay.
  bool get isIncorrect => value != null && value != solutionValue;

  /// `true` when [value] equals [solutionValue].
  bool get isCorrect => value != null && value == solutionValue;

  // --- Immutable mutation helpers ---

  /// Returns a new [SudokuCell] with only the specified fields replaced.
  ///
  /// To explicitly clear [value], set `clearValue: true` instead of passing
  /// `value: null` — this avoids the ambiguity between "no change" and an
  /// intentional clear. Setting `clearValue: true` also wipes all [notes].
  SudokuCell copyWith({
    int? value,
    bool clearValue = false,
    Set<int>? notes,
    bool? isOriginal,
    int? solutionValue,
  }) {
    final newValue = clearValue ? null : (value ?? this.value);
    return SudokuCell(
      row: row,
      col: col,
      solutionValue: solutionValue ?? this.solutionValue,
      value: newValue,
      isOriginal: isOriginal ?? this.isOriginal,
      notes: clearValue ? const {} : (notes ?? this.notes),
    );
  }

  /// Returns a new cell with [digit] toggled in [notes].
  ///
  /// If [digit] is already present it is removed; otherwise it is added.
  /// To clear all notes, use [clearNotes] or pass `clearValue: true` to
  /// [copyWith] when placing a definitive value.
  SudokuCell toggleNote(int digit) {
    final updated = Set<int>.from(notes);
    if (updated.contains(digit)) {
      updated.remove(digit);
    } else {
      updated.add(digit);
    }
    return copyWith(notes: Set.unmodifiable(updated));
  }

  /// Returns a new cell with all pencil marks removed.
  SudokuCell clearNotes() => copyWith(notes: const {});

  // --- Equality & hashing ---

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SudokuCell &&
        other.row == row &&
        other.col == col &&
        other.value == value &&
        other.solutionValue == solutionValue &&
        other.isOriginal == isOriginal &&
        _setsEqual(other.notes, notes);
  }

  @override
  int get hashCode {
    final sortedNotes = notes.toList()..sort();
    return Object.hash(
      row,
      col,
      value,
      solutionValue,
      isOriginal,
      Object.hashAll(sortedNotes),
    );
  }

  @override
  String toString() =>
      'SudokuCell($row,$col: value=$value, solution=$solutionValue, '
      'original=$isOriginal, notes=$notes)';

  static bool _setsEqual(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  // --- Serialization ---

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'value': value,
        'solutionValue': solutionValue,
        'isOriginal': isOriginal,
        'notes': notes.toList(),
      };

  factory SudokuCell.fromJson(Map<String, dynamic> json) {
    return SudokuCell(
      row: json['row'] as int,
      col: json['col'] as int,
      solutionValue: json['solutionValue'] as int,
      value: json['value'] as int?,
      isOriginal: json['isOriginal'] as bool? ?? false,
      notes: (json['notes'] as List<dynamic>?)?.map((e) => e as int).toSet() ?? const {},
    );
  }
}
