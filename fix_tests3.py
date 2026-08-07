import re

with open('test/features/game/application/game_notifier_test.dart', 'r') as f:
    content = f.read()

# For Test 2: make it so the board has exactly 9 empty cells before triggering auto complete.
# Wait, Test 2 is testing victory and save clearing.
# The easiest way is to mock a 9x9 board with exactly 9 empty cells?
# Or just change `canAutoComplete` to not be checked in tests, or we can just populate the board to 9 empty cells in the test.
# Actually, the 9 empty cells condition is hardcoded. 
# In Test 2, it's 9x9 board. Total cells = 81.
# emptyPos loop currently just makes 1 move. 
test2_part = """    for (int r = 0; r < board.gridSize; r++) {
      for (int c = 0; c < board.gridSize; c++) {
        if (!board.cellAt(r, c).isFilled) {
          emptyPos = (r, c);
          break;
        }
      }
    }
    notifier.inputNumber(emptyPos.$1, emptyPos.$2, board.cellAt(emptyPos.$1, emptyPos.$2).solutionValue);
    
    await Future.delayed(const Duration(milliseconds: 100)); // wait for auto save
    expect(prefs.containsKey('current_game'), isTrue, reason: 'Save should exist after a move');
    
    // Now autocomplete to victory
    await notifier.triggerAutoComplete();"""

test2_replacement = """    // Fill board until exactly 9 empty cells remain
    int emptyCount = 0;
    for (int r = 0; r < board.gridSize; r++) {
      for (int c = 0; c < board.gridSize; c++) {
        if (!board.cellAt(r, c).isFilled) {
          emptyCount++;
        }
      }
    }
    
    for (int r = 0; r < board.gridSize && emptyCount > 9; r++) {
      for (int c = 0; c < board.gridSize && emptyCount > 9; c++) {
        if (!board.cellAt(r, c).isFilled) {
          notifier.inputNumber(r, c, board.cellAt(r, c).solutionValue);
          emptyCount--;
        }
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 100)); // wait for auto save
    expect(prefs.containsKey('current_game'), isTrue, reason: 'Save should exist after moves');
    
    // Now autocomplete to victory
    await notifier.triggerAutoComplete();"""

content = content.replace(test2_part, test2_replacement)


# For Test 4:
test4_part = """    await notifier.initNewGame(Difficulty.easy);
    
    final states = <GameState>[];"""

test4_replacement = """    await notifier.initNewGame(Difficulty.easy);
    
    // Fill board until exactly 9 empty cells remain
    int emptyCount = 0;
    for (int r = 0; r < notifier.state.board.gridSize; r++) {
      for (int c = 0; c < notifier.state.board.gridSize; c++) {
        if (!notifier.state.board.cellAt(r, c).isFilled) {
          emptyCount++;
        }
      }
    }
    
    for (int r = 0; r < notifier.state.board.gridSize && emptyCount > 9; r++) {
      for (int c = 0; c < notifier.state.board.gridSize && emptyCount > 9; c++) {
        if (!notifier.state.board.cellAt(r, c).isFilled) {
          notifier.inputNumber(r, c, notifier.state.board.cellAt(r, c).solutionValue);
          emptyCount--;
        }
      }
    }
    
    final states = <GameState>[];"""

content = content.replace(test4_part, test4_replacement)

with open('test/features/game/application/game_notifier_test.dart', 'w') as f:
    f.write(content)
