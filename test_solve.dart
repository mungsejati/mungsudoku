import 'lib/src/features/game/data/services/sudoku_generator.dart';
void main() {
  final s = '000000010400000000020000000000050407008000300001090000300400200050100000000806000';
  final grid = List.generate(9, (r) => List.generate(9, (c) => int.parse(s[r*9+c])));
  final valid = SudokuGenerator.hasUniqueSolution(grid, 9, 3, 3);
  print('Has unique solution: $valid');
}
