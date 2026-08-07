import 'lib/src/features/game/data/services/sudoku_seed_bank.dart';

void main() {
  final seed = SudokuSeedBank.getExtremeSeed();
  print('Non zero: ${seed.where((e) => e != 0).length}');
}
