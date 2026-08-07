import re

with open('lib/src/features/game/data/services/sudoku_generator.dart', 'r') as f:
    content = f.read()

# 1. Import SudokuSeedBank
if 'sudoku_seed_bank.dart' not in content:
    content = content.replace("import '../../domain/enums/difficulty.dart';", "import '../../domain/enums/difficulty.dart';\nimport 'sudoku_seed_bank.dart';")

# 2. Add transformation functions
transformation_code = """
  // ---------------------------------------------------------------------------
  // Private: Seed Transformations
  // ---------------------------------------------------------------------------

  static List<int> _transformSeed(List<int> seed, int size) {
    List<int> result = List.from(seed);
    
    // 1. Permute values (1-9 mapped to a random permutation)
    final values = List.generate(size, (i) => i + 1)..shuffle(_random);
    final map = <int, int>{};
    for (int i = 0; i < size; i++) {
      map[i + 1] = values[i];
    }
    
    for (int i = 0; i < result.length; i++) {
      if (result[i] != 0) {
        result[i] = map[result[i]]!;
      }
    }
    
    // 2. Rotate grid randomly (0, 90, 180, 270 degrees)
    int rotations = _random.nextInt(4);
    for (int i = 0; i < rotations; i++) {
      result = _rotate90(result, size);
    }
    
    return result;
  }
  
  static List<int> _rotate90(List<int> grid, int size) {
    final result = List.filled(size * size, 0);
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        result[c * size + (size - 1 - r)] = grid[r * size + c];
      }
    }
    return result;
  }
"""

if "_transformSeed" not in content:
    content = content.replace("  // Private: solution generation", transformation_code + "\n  // Private: solution generation")

# 3. Update generate() to use extreme seed bank and strict looping
new_generate = """  static SudokuBoard generate(Difficulty difficulty, {int subGridRows = 3, int subGridCols = 3}) {
    final size = subGridRows * subGridCols;
    final totalCells = size * size;
    
    // Fast path for extreme (17 clues on 9x9 requires immense computation)
    if (difficulty == Difficulty.extreme && size == 9) {
      final seed = SudokuSeedBank.getExtremeSeed();
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

    final ratio = difficulty.givenCellCount / 81.0;
    final targetGivenCount = (totalCells * ratio).round();

    List<int> given = [];
    List<int> solution = [];
    bool targetReached = false;
    
    // For expert/hard, we loop until we hit the exact clue count requested
    while (!targetReached) {
      solution = _generateSolution(size, subGridRows, subGridCols);
      given = _maskCells(solution, targetGivenCount, totalCells, size, subGridRows, subGridCols);
      
      final currentGivenCount = given.where((val) => val != 0).length;
      if (currentGivenCount <= targetGivenCount) {
          targetReached = true;
          
          // Evaluator: For expert, ensure puzzle requires advanced logic
          if (difficulty == Difficulty.expert) {
            if (_isSolvableWithBasicLogic(given, size, subGridRows, subGridCols)) {
              targetReached = false; // "Too easy", try again
            }
          }
      }
    }

    return SudokuBoard.fromValues(
      given: given, 
      solution: solution, 
      subGridRows: subGridRows,
      subGridCols: subGridCols,
    );
  }"""

# regex replace generate function
content = re.sub(
    r"  static SudokuBoard generate\(Difficulty difficulty.*?return SudokuBoard\.fromValues\([^)]*\);\n  }",
    new_generate,
    content,
    flags=re.DOTALL
)

# 4. Update _maskCells for rotational symmetry
new_mask = """  static List<int> _maskCells(List<int> solution, int givenCount, int totalCells, int size, int subGridRows, int subGridCols) {
    final given = List<int>.from(solution);
    final positions = List.generate(totalCells, (i) => i)..shuffle(_random);
    int currentGivenCount = totalCells;

    for (final pos in positions) {
      if (currentGivenCount <= givenCount) break;

      if (given[pos] == 0) continue; // Already removed (by symmetry)

      final r = pos ~/ size;
      final c = pos % size;
      final symR = size - 1 - r;
      final symC = size - 1 - c;
      final symPos = symR * size + symC;

      final backup = given[pos];
      final symBackup = given[symPos];

      given[pos] = 0;
      int removedCount = 1;
      
      if (given[symPos] != 0 && pos != symPos) {
        given[symPos] = 0;
        removedCount = 2;
      }

      // Convert 1D list to 2D grid for solver
      final grid = List.generate(size, (r) {
        return List.generate(size, (c) => given[r * size + c]);
      });

      final solutionCount = _countSolutions(grid, size, subGridRows, subGridCols, limit: 2);
      if (solutionCount > 1) {
        // Multiple solutions found, this removal breaks uniqueness. Revert both.
        given[pos] = backup;
        if (pos != symPos) {
          given[symPos] = symBackup;
        }
      } else {
        currentGivenCount -= removedCount;
      }
    }
    return given;
  }"""

content = re.sub(
    r"  static List<int> _maskCells\(List<int> solution.*?return given;\n  }",
    new_mask,
    content,
    flags=re.DOTALL
)

with open('lib/src/features/game/data/services/sudoku_generator.dart', 'w') as f:
    f.write(content)
