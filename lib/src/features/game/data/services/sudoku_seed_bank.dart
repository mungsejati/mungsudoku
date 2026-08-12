import 'dart:math';

/// Provides a collection of pre-computed Sudoku seeds (e.g. 17-clue puzzles).
///
/// Generating a 17-clue puzzle dynamically requires immense computation that
/// freezes mobile devices. This class provides a fast-path for Extreme mode by
/// returning one of these pre-computed valid seeds.
///
/// The returned seed should be passed through transformations (rotations,
/// value permutations) to yield millions of variations from a small seed list.
abstract final class SudokuSeedBank {
  static final Random _random = Random();

  /// A small collection of known unique 17-clue 9x9 puzzles (as 81-character strings).
  static const List<String> _seeds17 = [
    '000000010400000000020000000000050407008000300001090000300400200050100000000806000',
  ];

  /// Returns a randomly chosen 17-clue puzzle from the seed bank.
  static const List<String> _seeds22 = [
    '000700012400000000020003000000050407008200300001090000300400200050120000000806000',
  ];

  /// Returns a randomly chosen 22-clue puzzle from the seed bank.
  static List<int> getExpertSeed() {
    final str = _seeds22[_random.nextInt(_seeds22.length)];
    return str.split('').map(int.parse).toList();
  }

  static List<int> getExtremeSeed() {
    final str = _seeds17[_random.nextInt(_seeds17.length)];
    return str.split('').map(int.parse).toList();
  }
}
