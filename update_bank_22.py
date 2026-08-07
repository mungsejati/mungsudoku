with open('lib/src/features/game/data/services/sudoku_seed_bank.dart', 'r') as f:
    content = f.read()

import re

# Insert _seeds22 array and getExpertSeed method
code_to_insert = """  static const List<String> _seeds22 = [
    '000700012400000000020003000000050407008200300001090000300400200050120000000806000',
  ];

  /// Returns a randomly chosen 22-clue puzzle from the seed bank.
  static List<int> getExpertSeed() {
    final str = _seeds22[_random.nextInt(_seeds22.length)];
    return str.split('').map(int.parse).toList();
  }
"""

content = content.replace("  static List<int> getExtremeSeed() {", code_to_insert + "\n  static List<int> getExtremeSeed() {")

with open('lib/src/features/game/data/services/sudoku_seed_bank.dart', 'w') as f:
    f.write(content)
