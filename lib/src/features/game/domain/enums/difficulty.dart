/// Defines the available difficulty levels for a Sudoku puzzle.
///
/// [givenCellCount] represents the number of pre-filled cells on a standard
/// 9x9 board. The minimum for a uniquely-solvable puzzle is 17 (Hard).
enum Difficulty {
  easy,
  medium,
  hard;

  String get displayName => switch (this) {
        Difficulty.easy => 'Easy',
        Difficulty.medium => 'Medium',
        Difficulty.hard => 'Hard',
      };

  /// Number of pre-filled (given) cells for a standard 9x9 board.
  int get givenCellCount => switch (this) {
        Difficulty.easy => 36,
        Difficulty.medium => 27,
        Difficulty.hard => 17,
      };
}
