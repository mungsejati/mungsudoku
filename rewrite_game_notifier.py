import re

with open('lib/src/features/game/application/game_notifier.dart', 'r') as f:
    content = f.read()

# Add BoardConfig import
content = content.replace("import '../domain/enums/difficulty.dart';", "import '../domain/enums/difficulty.dart';\nimport '../domain/entities/board_config.dart';")

# Fix initNewGame signature and body
init_new_old = """  Future<void> initNewGame(
    Difficulty difficulty, {
    int subGridSize = 3,
    SymbolType symbolType = SymbolType.standard,
  }) async {"""

init_new_new = """  Future<void> initNewGame(
    Difficulty difficulty, {
    SymbolType symbolType = SymbolType.standard,
  }) async {
    final boardConfig = difficulty == Difficulty.fast ? BoardConfig.fast : BoardConfig.standard;
    final subGridRows = boardConfig.subGridRows;
    final subGridCols = boardConfig.subGridCols;
"""
content = content.replace(init_new_old, init_new_new)

content = content.replace(
    "'Starting new game — difficulty: ${difficulty.displayName}, size: $subGridSize, symbol: ${symbolType.name}',",
    "'Starting new game — difficulty: ${difficulty.displayName}, size: ${subGridRows}x${subGridCols}, symbol: ${symbolType.name}',"
)

content = content.replace(
    "board: SudokuBoard.empty(subGridSize: subGridSize),",
    "board: SudokuBoard.empty(subGridRows: subGridRows, subGridCols: subGridCols),"
)

content = content.replace(
    "selectedSubGridSize: subGridSize,",
    "selectedBoardConfig: boardConfig,"
)

content = content.replace(
    "final board = await compute(_generatePuzzle, (difficulty, subGridSize));",
    "final board = await compute(_generatePuzzle, (difficulty, boardConfig));"
)

# initCustomGame
content = content.replace(
    "selectedSubGridSize: board.subGridSize,",
    "selectedBoardConfig: BoardConfig(subGridRows: board.subGridRows, subGridCols: board.subGridCols),"
)

# update _generatePuzzle
gen_puz_old = """SudokuBoard _generatePuzzle((Difficulty, int) args) =>
    SudokuGenerator.generate(args.$1, subGridSize: args.$2);"""

gen_puz_new = """SudokuBoard _generatePuzzle((Difficulty, BoardConfig) args) =>
    SudokuGenerator.generate(args.$1, subGridRows: args.$2.subGridRows, subGridCols: args.$2.subGridCols);"""
content = content.replace(gen_puz_old, gen_puz_new)

# Auto-complete trigger in inputNumber
input_number_old = """      // Count as a mistake only when placing a wrong answer (not when toggling off)
      if (newValue != null && newValue != cell.solutionValue) {
        newMistakeCount++;
        _log.warning('Mistake at ($row,$col): entered $newValue, expected ${cell.solutionValue}.');
      }

      // Check for sweep animation
      if (newValue != null && newValue == cell.solutionValue) {
        final int gridSize = state.board.gridSize;
        final int sgSize = state.board.subGridSize;
        final int sgIndex = (row ~/ sgSize) * sgSize + (col ~/ sgSize);"""

# wait, we need to adapt the sweep animation logic in inputNumber to use subGridRows and subGridCols
input_number_new = """      // Count as a mistake only when placing a wrong answer (not when toggling off)
      if (newValue != null && newValue != cell.solutionValue) {
        newMistakeCount++;
        _log.warning('Mistake at ($row,$col): entered $newValue, expected ${cell.solutionValue}.');
      }

      // Check for sweep animation
      if (newValue != null && newValue == cell.solutionValue) {
        final int gridSize = state.board.gridSize;
        final int sgRows = state.board.subGridRows;
        final int sgCols = state.board.subGridCols;
        final int sgIndex = (row ~/ sgRows) * (gridSize ~/ sgCols) + (col ~/ sgCols);"""
content = content.replace(input_number_old, input_number_new)

sweep_sg_old = """        if (updatedBoard.subGridNumbers[sgIndex]!.length == gridSize) {
          final int startRow = (sgIndex ~/ sgSize) * sgSize;
          final int startCol = (sgIndex % sgSize) * sgSize;
          for (int r = startRow; r < startRow + sgSize; r++) {
            for (int c = startCol; c < startCol + sgSize; c++) {
              superHighlights.add((r, c));
            }
          }
        }"""
sweep_sg_new = """        if (updatedBoard.subGridNumbers[sgIndex]!.length == gridSize) {
          final int startRow = (row ~/ sgRows) * sgRows;
          final int startCol = (col ~/ sgCols) * sgCols;
          for (int r = startRow; r < startRow + sgRows; r++) {
            for (int c = startCol; c < startCol + sgCols; c++) {
              superHighlights.add((r, c));
            }
          }
        }"""
content = content.replace(sweep_sg_old, sweep_sg_new)

# Auto-complete trigger at the end of inputNumber, just before _applyBoardUpdate
apply_board_old = """    _applyBoardUpdate(
      updatedBoard,
      cumulativeMistakeCount: newMistakeCount,
      newSuperHighlights: superHighlights,
      isAuto: isAuto,
    );
  }"""
apply_board_new = """    _applyBoardUpdate(
      updatedBoard,
      cumulativeMistakeCount: newMistakeCount,
      newSuperHighlights: superHighlights,
      isAuto: isAuto,
    );

    // Auto-complete trigger when 9 empty cells remain
    if (!isAuto && updatedBoard.totalCells - updatedBoard.filledCellCount == 9) {
      if (SudokuValidator.findConflicts(updatedBoard).isEmpty && newMistakeCount < GameState.maxMistakes) {
        Future.delayed(const Duration(milliseconds: 300), () {
          triggerAutoComplete();
        });
      }
    }
  }"""
content = content.replace(apply_board_old, apply_board_new)

# fastFillNotes logic needs update for sgIndex
fast_note_old = """        final sgIndex = (r ~/ board.subGridSize) * board.subGridSize + (c ~/ board.subGridSize);"""
fast_note_new = """        final sgIndex = (r ~/ board.subGridRows) * (size ~/ board.subGridCols) + (c ~/ board.subGridCols);"""
content = content.replace(fast_note_old, fast_note_new)


with open('lib/src/features/game/application/game_notifier.dart', 'w') as f:
    f.write(content)
