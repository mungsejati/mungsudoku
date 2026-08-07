with open('lib/src/features/game/data/services/sudoku_seed_bank.dart', 'r') as f:
    content = f.read()

import re
content = re.sub(
    r"  static const List<String> _seeds17 = \[.*?\];",
    """  static const List<String> _seeds17 = [
    '000000010400000000020000000000050407008000300001090000300400200050100000000806000',
  ];""",
    content,
    flags=re.DOTALL
)

with open('lib/src/features/game/data/services/sudoku_seed_bank.dart', 'w') as f:
    f.write(content)
