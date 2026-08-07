with open('README.md', 'r') as f:
    content = f.read()

perf_section = """
### ⚡ Performance Optimizations (UI Jank & Infinite Loading Failsafe)

To guarantee a smooth, jank-free gaming experience on mobile, we've implemented strict performance constraints:
1. **Numpad Re-rendering Optimization (`GameNumberPad`)**:
   Instead of rebuilding the entire numpad (and its buttons) every time the 1-second timer ticks or the board changes, we decoupled `_SmartDigitButton`. Each button now uses Riverpod's `.select()` to precisely watch only the specific conditions it cares about (e.g. `activeValue == digit` and `placedCount`). This guarantees instant response for Fast Input mode without triggering heavy whole-tree widget rebuilds.
2. **Infinite Loading Failsafe (`SudokuGenerator`)**:
   Procedurally generating high-difficulty standard puzzles involves randomized trial-and-error which can sometimes loop indefinitely if the generator enters a difficult configuration space. A hard `maxAttempts = 100` failsafe is now enforced. If the procedural backtracking fails to find a valid masking solution within 100 attempts, the generator gracefully falls back to the current best-effort board, ensuring the UI thread never freezes.
"""

content += perf_section

with open('README.md', 'w') as f:
    f.write(content)
