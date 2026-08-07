import re

with open('lib/src/features/game/domain/enums/difficulty.dart', 'r') as f:
    content = f.read()

content = content.replace(
    "Difficulty.fast: 50,",
    "Difficulty.fast: 18, // Based on 6x6 grid where total cells is 36, so half is 18."
)

with open('lib/src/features/game/domain/enums/difficulty.dart', 'w') as f:
    f.write(content)
