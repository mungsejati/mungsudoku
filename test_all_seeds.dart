import 'lib/src/features/game/data/services/sudoku_seed_bank.dart';
void main() {
  for (int i=0; i<100; i++) {
     final seed = SudokuSeedBank.getExtremeSeed();
     if (seed.where((e) => e != 0).length != 17) {
       print('Found bad seed length: ${seed.where((e) => e != 0).length}');
     }
  }
}
