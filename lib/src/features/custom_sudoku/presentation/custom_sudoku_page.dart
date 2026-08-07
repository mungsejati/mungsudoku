import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/game_theme.dart';
import '../../game/domain/enums/symbol_type.dart';
import '../../game/domain/entities/sudoku_board.dart';
import '../../game/presentation/widgets/sudoku_board_widget.dart';
import '../../game/presentation/widgets/game_theme_picker.dart';
import '../application/custom_sudoku_notifier.dart';
import '../application/custom_sudoku_list_notifier.dart';

class CustomSudokuPage extends ConsumerWidget {
  const CustomSudokuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customSudokuNotifierProvider);
    final notifier = ref.read(customSudokuNotifierProvider.notifier);
    final gameTheme = ref.watch(gameThemeProvider);

    return Scaffold(
      backgroundColor: gameTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/arrow-left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(gameTheme.topBarTextColor, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: IconThemeData(color: gameTheme.topBarTextColor),
        title: Text(
          'Custom Puzzle',
          style: TextStyle(
            color: gameTheme.topBarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const GameThemePopupMenu(),
          IconButton(
            icon: state.isValidating 
                ? SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(color: gameTheme.topBarTextColor, strokeWidth: 2)
                  )
                : Icon(Icons.save_outlined, color: gameTheme.topBarTextColor),
            onPressed: state.isValidating 
                ? null 
                : () async {
                    final isValid = await notifier.validateAndPreparePlay();
                    if (!context.mounted) return;

                    if (isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Puzzle valid! Saving...'),
                          backgroundColor: Colors.green,
                        )
                      );
                      
                      final solution = notifier.getSolvedGrid();
                      final boardState = ref.read(customSudokuNotifierProvider).board;
                      
                      if (solution != null) {
                        // Create a board with given + solved
                        final finalBoard = SudokuBoard.fromValues(
                          given: [for (var r = 0; r < boardState.gridSize; r++) 
                                    for (var c = 0; c < boardState.gridSize; c++) 
                                      boardState.cellAt(r, c).value ?? 0],
                          solution: solution,
                          subGridRows: boardState.subGridRows,
                          subGridCols: boardState.subGridCols,
                        );
                        
                        
                        // Save puzzle to local storage
                        ref.read(customSudokuListNotifierProvider.notifier).savePuzzle(finalBoard);
                        
                        context.pop(); // Go back to the List page
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Invalid Puzzle'),
                          content: const Text(
                            'Soal tidak valid atau memiliki lebih dari satu kemungkinan solusi. Silakan periksa kembali!'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
            tooltip: 'Save / Play',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _CustomSudokuBoardWidget(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Custom Numpad
            _CustomNumpad(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CustomSudokuBoardWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customSudokuNotifierProvider);
    final gameTheme = ref.watch(gameThemeProvider);
    final board = state.board;

    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GridView.builder(
            clipBehavior: Clip.none,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board.gridSize ~/ board.subGridCols,
                      childAspectRatio: board.subGridCols / board.subGridRows,
              mainAxisSpacing: gameTheme.subGridSpacing,
              crossAxisSpacing: gameTheme.subGridSpacing,
            ),
            itemCount: (board.gridSize ~/ board.subGridRows) * (board.gridSize ~/ board.subGridCols),
            itemBuilder: (context, sgIndex) {
              final int numCols = board.gridSize ~/ board.subGridCols;
                      final sgRow = sgIndex ~/ numCols;
              final sgCol = sgIndex % numCols;
              return Container(
                decoration: BoxDecoration(
                  color: gameTheme.subGridBackground,
                  borderRadius: BorderRadius.circular(gameTheme.subGridBorderRadius),
                  boxShadow: gameTheme.subGridShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: board.gridSize ~/ board.subGridCols,
                      childAspectRatio: board.subGridCols / board.subGridRows,
                  ),
                  itemCount: (board.gridSize ~/ board.subGridRows) * (board.gridSize ~/ board.subGridCols),
                  itemBuilder: (context, index) {
                    final localRow = index ~/ board.subGridCols;
                    final localCol = index % board.subGridCols;
                    final row = sgRow * board.subGridRows + localRow;
                    final col = sgCol * board.subGridCols + localCol;
                    final cell = board.cellAt(row, col);

                    final isSelected = state.selectedRow == row && state.selectedCol == col;
                    final isConflict = state.conflictPositions.contains((row, col));
                    
                    bool isCrosshair = false;
                    if (state.hasSelection && !isSelected) {
                      final sameRow = row == state.selectedRow;
                      final sameCol = col == state.selectedCol;
                      final sameSg = (row ~/ board.subGridRows) == (state.selectedRow! ~/ board.subGridRows) &&
                                     (col ~/ board.subGridCols) == (state.selectedCol! ~/ board.subGridCols);
                      isCrosshair = sameRow || sameCol || sameSg;
                    }

                    bool isIdenticalValue = false;
                    if (state.hasSelection && !isSelected && cell.value != null && cell.value != 0) {
                      final selectedCell = board.cellAt(state.selectedRow, state.selectedCol);
                      if (selectedCell.value == cell.value) {
                        isIdenticalValue = true;
                      }
                    }

                    return SudokuCellTile(
                      cell: cell,
                      isSelected: isSelected,
                      isConflict: isConflict,
                      isSuperHighlight: false, // Not used in custom page yet
                      isCrosshair: isCrosshair,
                      isIdentical: isIdenticalValue,
                      isHighlightedNote: false, // Not used here
                      highlightedValue: null,   // Not used here
                      gridSize: board.gridSize,
                      subGridRows: board.subGridRows,
                          subGridCols: board.subGridCols,
                      symbolType: SymbolType.standard,
                      gameTheme: gameTheme,
                      onTap: () {
                        ref.read(customSudokuNotifierProvider.notifier).selectCell(row, col);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CustomNumpad extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameTheme = ref.watch(gameThemeProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: gameTheme.numpadBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: gameTheme.controlPadShadow,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 1; i <= 5; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: _NumpadButton(value: i, label: '$i', theme: gameTheme),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 6; i <= 9; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: _NumpadButton(value: i, label: '$i', theme: gameTheme),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: _NumpadButton(value: 0, label: 'X', theme: gameTheme, isDelete: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumpadButton extends ConsumerWidget {
  const _NumpadButton({
    required this.value,
    required this.label,
    required this.theme,
    this.isDelete = false,
  });

  final int value;
  final String label;
  final GameTheme theme;
  final bool isDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For consistency with main game numpad
    final textColor = isDelete ? theme.topBarMistakeColor : theme.originalTextColor;
    
    return AspectRatio(
      aspectRatio: 1.0, // Make it perfectly square like game_number_pad
      child: InkWell(
        onTap: () {
          ref.read(customSudokuNotifierProvider.notifier).inputNumber(value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.numpadButtonBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.cellBorderColor,
              width: 1,
            ),
            boxShadow: theme.numpadButtonShadow,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
