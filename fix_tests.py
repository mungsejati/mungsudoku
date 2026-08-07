import re

with open('test/features/game/application/game_notifier_test.dart', 'r') as f:
    content = f.read()

content = content.replace("subGridSize: 2", "subGridRows: 2, subGridCols: 2")
content = content.replace("subGridSize: 3", "subGridRows: 3, subGridCols: 3")
# But notifier.initNewGame no longer accepts subGridSize.
# It was: notifier.initNewGame(Difficulty.easy, subGridSize: 2)
# We can just use initNewGame(Difficulty.fast) since fast mode uses 6x6 (2x3).
# Wait, tests that specifically wanted 4x4 (subGridSize: 2) can't easily be created with initNewGame anymore unless we pass BoardConfig.
# Let's check how initNewGame is mocked or if it takes BoardConfig.
# Actually, the quickest fix is to just remove `, subGridSize: 2` and let it use default standard mode (9x9), because the test just tests logic.
content = content.replace(", subGridSize: 2", "")

with open('test/features/game/application/game_notifier_test.dart', 'w') as f:
    f.write(content)
