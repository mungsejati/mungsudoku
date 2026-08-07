/// Defines the available difficulty levels for a Sudoku puzzle.
///
/// [givenCellCount] represents the number of pre-filled cells on a standard
/// 9x9 board. The minimum for a uniquely-solvable puzzle is 17 (Hard).
enum Difficulty {
  fast,
  easy,
  medium,
  hard,
  expert,
  extreme;

  String get displayName => switch (this) {
        Difficulty.fast => 'Fast',
        Difficulty.easy => 'Easy',
        Difficulty.medium => 'Medium',
        Difficulty.hard => 'Hard',
        Difficulty.expert => 'Expert',
        Difficulty.extreme => 'Extreme',
      };

  /// Number of pre-filled (given) cells for a standard 9x9 board.
  int get givenCellCount => switch (this) {
        Difficulty.extreme => 17,
        Difficulty.expert => 22,
        Difficulty.hard => 36,
        Difficulty.medium => 38,
        Difficulty.easy => 50,
        Difficulty.fast => 20,
      };
}
