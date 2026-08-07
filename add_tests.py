import re

with open('test/features/game/sudoku_game_logic_test.dart', 'r') as f:
    content = f.read()

new_tests = """
    test('Generated boards use rotational symmetry', () {
      final easyBoard = SudokuGenerator.generate(Difficulty.easy);
      final size = easyBoard.gridSize;
      
      for (var r = 0; r < size; r++) {
        for (var c = 0; c < size; c++) {
          final isGiven = easyBoard.cellAt(r, c).isOriginal;
          final symIsGiven = easyBoard.cellAt(size - 1 - r, size - 1 - c).isOriginal;
          expect(isGiven, equals(symIsGiven), 
            reason: 'Cells at ($r, $c) and symmetric counterpart should both be given or both empty');
        }
      }
    });

    test('Expert yields exactly 22 clues and Extreme yields exactly 17 clues', () {
      final expertBoard = SudokuGenerator.generate(Difficulty.expert);
      expect(expertBoard.filledCellCount, equals(22), 
        reason: 'Expert mode must enforce strictly 22 clues');

      final extremeBoard = SudokuGenerator.generate(Difficulty.extreme);
      expect(extremeBoard.filledCellCount, equals(17), 
        reason: 'Extreme mode must enforce strictly 17 clues from seed bank');
    });
  });"""

content = content.replace("    });\n  });", "    });\n" + new_tests)

with open('test/features/game/sudoku_game_logic_test.dart', 'w') as f:
    f.write(content)
