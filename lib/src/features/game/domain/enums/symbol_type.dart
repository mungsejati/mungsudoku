/// Defines the visual representation of numbers on the Sudoku board.
enum SymbolType {
  standard('Angka / Huruf Standard'),
  roman('Angka Romawi');

  const SymbolType(this.displayName);

  /// Human-readable label for the UI selector.
  final String displayName;
}
