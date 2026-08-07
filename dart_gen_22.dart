import 'dart:math';

void main() {
  final seed_str = '000000010400000000020000000000050407008000300001090000300400200050100000000806000';
  final grid = List.generate(9, (r) => List.generate(9, (c) => int.parse(seed_str[r * 9 + c])));
  final solved = List.generate(9, (r) => List.generate(9, (c) => int.parse(seed_str[r * 9 + c])));

  bool isValid(int r, int c, int val) {
    for (int i = 0; i < 9; i++) {
      if (solved[r][i] == val || solved[i][c] == val) return false;
      if (solved[3 * (r ~/ 3) + i ~/ 3][3 * (c ~/ 3) + i % 3] == val) return false;
    }
    return true;
  }

  bool backtrack(int r, int c) {
    if (r == 9) return true;
    if (c == 9) return backtrack(r + 1, 0);
    if (solved[r][c] != 0) return backtrack(r, c + 1);

    for (int val = 1; val <= 9; val++) {
      if (isValid(r, c, val)) {
        solved[r][c] = val;
        if (backtrack(r, c + 1)) return true;
        solved[r][c] = 0;
      }
    }
    return false;
  }

  backtrack(0, 0);

  final random = Random(42);
  final positions = List.generate(81, (i) => i)..shuffle(random);
  int added = 0;

  for (final p in positions) {
    final r = p ~/ 9;
    final c = p % 9;
    if (grid[r][c] == 0) {
      grid[r][c] = solved[r][c];
      added++;
      if (added == 5) break;
    }
  }

  final newStr = StringBuffer();
  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      newStr.write(grid[r][c]);
    }
  }

  print("22 CLUE SEED:");
  print(newStr.toString());
}
