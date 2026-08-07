import re

with open('lib/src/features/game/data/services/sudoku_generator.dart', 'r') as f:
    content = f.read()

new_extreme_expert = """
    // Fast path for expert (22 clues) and extreme (17 clues) on 9x9
    if (size == 9 && (difficulty == Difficulty.extreme || difficulty == Difficulty.expert)) {
      final seed = difficulty == Difficulty.extreme 
          ? SudokuSeedBank.getExtremeSeed() 
          : SudokuSeedBank.getExpertSeed();
      final given = _transformSeed(seed, size);
      
      // We need the full solution for the board. We can solve the generated seed.
      final solution = solveGrid(
        List.generate(size, (r) => List.generate(size, (c) => given[r * size + c])), 
        size, subGridRows, subGridCols
      )!;
      
      return SudokuBoard.fromValues(
        given: given, 
        solution: solution, 
        subGridRows: subGridRows,
        subGridCols: subGridCols,
      );
    }
"""

content = re.sub(
    r"    // Fast path for extreme.*?    }",
    new_extreme_expert.strip(),
    content,
    flags=re.DOTALL
)

with open('lib/src/features/game/data/services/sudoku_generator.dart', 'w') as f:
    f.write(content)
