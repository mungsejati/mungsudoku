import re

with open('README.md', 'r') as f:
    content = f.read()

content = content.replace("- **New Difficulty Levels:** Added `fast`, `expert`, and `extreme` modes.",
"""- **New Difficulty Levels:** Added `fast`, `expert`, and `extreme` modes.
- **Fast Mode (6x6):** Specially crafted for the `fast` difficulty, utilizing a 6x6 grid with 2x3 subgrids for quick play sessions.
- **Advanced Puzzle Evaluator:** The generator now uses a specialized logical solver to ensure `expert` and `extreme` puzzles cannot be solved with basic singles alone, guaranteeing true difficulty.
- **Automatic Auto-Complete:** Replaced the manual button with an intelligent auto-complete sequence that automatically triggers when exactly 9 empty cells remain, offering a seamless user experience.""")

with open('README.md', 'w') as f:
    f.write(content)
