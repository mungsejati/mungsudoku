import re

with open('test/features/game/application/game_notifier_test.dart', 'r') as f:
    content = f.read()

content = content.replace(", subGridRows: 2, subGridCols: 2", "")

with open('test/features/game/application/game_notifier_test.dart', 'w') as f:
    f.write(content)
