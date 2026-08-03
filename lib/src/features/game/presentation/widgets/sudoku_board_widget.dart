import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/game_theme.dart';
import '../../application/game_notifier.dart';
import '../../domain/entities/sudoku_board.dart';
import '../../domain/entities/sudoku_cell.dart';
import '../../domain/enums/symbol_type.dart';
import '../utils/symbol_mapper.dart';

class SudokuBoardWidget extends ConsumerWidget {
  const SudokuBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final gameTheme = ref.watch(gameThemeProvider);
    final board = state.board;

    // Compute the value to highlight (same-value cells go blue)
    int? highlightedValue = state.activeValue;
    if (state.selectedRow != null && state.selectedCol != null) {
      final sel = board.cellAt(state.selectedRow!, state.selectedCol!);
      highlightedValue ??= sel.value;
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          // Sub-grid grid (separated cards)
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board.subGridSize,
              mainAxisSpacing: gameTheme.subGridSpacing,
              crossAxisSpacing: gameTheme.subGridSpacing,
            ),
            itemCount: board.subGridSize * board.subGridSize,
            itemBuilder: (context, sgIndex) {
              final sgRow = sgIndex ~/ board.subGridSize;
              final sgCol = sgIndex % board.subGridSize;
              return _SubGridCard(
                sgRow: sgRow,
                sgCol: sgCol,
                board: board,
                state: _BoardHighlightData(
                  selectedRow: state.selectedRow,
                  selectedCol: state.selectedCol,
                  highlightedValue: highlightedValue,
                  conflictPositions: state.conflictPositions,
                  superHighlightPositions: state.superHighlightPositions,
                  isFastModeActive: state.isFastModeActive,
                  activeValue: state.activeValue,
                  symbolType: state.symbolType,
                ),
                gameTheme: gameTheme,
                onCellTap: (row, col) {
                  if (state.isFastModeActive) {
                    ref
                        .read(gameNotifierProvider.notifier)
                        .inputNumber(row, col, state.activeValue!);
                  } else {
                    ref
                        .read(gameNotifierProvider.notifier)
                        .selectCell(row, col);
                  }
                },
              );
            },
          ),

          // Pause overlay
          if (state.isPaused)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Paused',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          FilledButton.icon(
                            onPressed: () => ref
                                .read(gameNotifierProvider.notifier)
                                .resumeGame(),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Resume Game'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                            onPressed: () {
                              ref.read(gameNotifierProvider.notifier).restartPuzzle();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Restart Puzzle'),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.home),
                            label: const Text('Quit to Main Menu'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal data struct passed from board → sub-grid → cell
// ---------------------------------------------------------------------------

class _BoardHighlightData {
  const _BoardHighlightData({
    required this.selectedRow,
    required this.selectedCol,
    required this.highlightedValue,
    required this.conflictPositions,
    required this.superHighlightPositions,
    required this.isFastModeActive,
    required this.activeValue,
    required this.symbolType,
  });

  final int? selectedRow;
  final int? selectedCol;
  final int? highlightedValue;
  final Set<(int, int)> conflictPositions;
  final Set<(int, int)> superHighlightPositions;
  final bool isFastModeActive;
  final int? activeValue;
  final SymbolType symbolType;
}

// ---------------------------------------------------------------------------
// One white rounded card = one sub-grid
// ---------------------------------------------------------------------------

class _SubGridCard extends StatelessWidget {
  const _SubGridCard({
    required this.sgRow,
    required this.sgCol,
    required this.board,
    required this.state,
    required this.gameTheme,
    required this.onCellTap,
  });

  final int sgRow;
  final int sgCol;
  final SudokuBoard board;
  final _BoardHighlightData state;
  final GameTheme gameTheme;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    final s = board.subGridSize;

    return Container(
      decoration: BoxDecoration(
        color: gameTheme.subGridBackground,
        borderRadius: BorderRadius.circular(gameTheme.subGridBorderRadius),
        boxShadow: gameTheme.subGridShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Cell grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: s,
            ),
            itemCount: s * s,
            itemBuilder: (context, index) {
              final localRow = index ~/ s;
              final localCol = index % s;
              final row = sgRow * s + localRow;
              final col = sgCol * s + localCol;
              final cell = board.cellAt(row, col);

              final isSelected =
                  state.selectedRow == row && state.selectedCol == col;
              final isConflict = state.conflictPositions.contains((row, col));
              final isSuperHighlight = state.superHighlightPositions.contains((
                row,
                col,
              ));

              bool isCrosshair = false;
              if (state.selectedRow != null &&
                  state.selectedCol != null &&
                  !isSelected) {
                final sameRow = row == state.selectedRow;
                final sameCol = col == state.selectedCol;
                final sameSg =
                    (row ~/ s) == (state.selectedRow! ~/ s) &&
                    (col ~/ s) == (state.selectedCol! ~/ s);
                isCrosshair = sameRow || sameCol || sameSg;
              }

              final isIdentical =
                  state.highlightedValue != null &&
                  state.highlightedValue != 0 &&
                  !isSelected &&
                  cell.value == state.highlightedValue;

              final isHighlightedNote =
                  state.highlightedValue != null &&
                  cell.value == null &&
                  cell.notes.contains(state.highlightedValue);

              return _CellTile(
                cell: cell,
                isSelected: isSelected,
                isConflict: isConflict,
                isSuperHighlight: isSuperHighlight,
                isCrosshair: isCrosshair,
                isIdentical: isIdentical,
                isHighlightedNote: isHighlightedNote,
                highlightedValue: state.highlightedValue,
                gridSize: board.gridSize,
                subGridSize: s,
                symbolType: state.symbolType,
                gameTheme: gameTheme,
                onTap: () => onCellTap(row, col),
              );
            },
          ),

          // Dashed dividers overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DashedGridPainter(
                  color: gameTheme.cellBorderColor,
                  divisions: s,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single cell tile
// ---------------------------------------------------------------------------

class _CellTile extends StatelessWidget {
  const _CellTile({
    required this.cell,
    required this.isSelected,
    required this.isConflict,
    required this.isSuperHighlight,
    required this.isCrosshair,
    required this.isIdentical,
    required this.isHighlightedNote,
    required this.highlightedValue,
    required this.gridSize,
    required this.subGridSize,
    required this.symbolType,
    required this.gameTheme,
    required this.onTap,
  });

  final SudokuCell cell;
  final bool isSelected;
  final bool isConflict;
  final bool isSuperHighlight;
  final bool isCrosshair;
  final bool isIdentical;
  final bool isHighlightedNote;
  final int? highlightedValue;
  final int gridSize;
  final int subGridSize;
  final SymbolType symbolType;
  final GameTheme gameTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    Border? border;
    BorderRadius? borderRadius;

    final bool showRedBackground = isConflict && cell.isOriginal;

    if (isSuperHighlight) {
      bg = Colors.amberAccent;
      borderRadius = BorderRadius.circular(6);
    } else if (isSelected) {
      bg = gameTheme.selectedCellColor;
      borderRadius = BorderRadius.circular(6);
    } else if (showRedBackground) {
      bg = gameTheme.conflictCellColor;
      borderRadius = BorderRadius.circular(6);
    } else if (isIdentical) {
      bg = gameTheme.identicalValueCellColor;
      borderRadius = BorderRadius.circular(6);
    } else if (isCrosshair) {
      bg = gameTheme.crosshairColor;
      borderRadius = BorderRadius.circular(6);
    } else {
      bg = Colors.transparent;
    }

    double fontSize = 22.0;
    if (gridSize > 9) fontSize = 15.0;
    if (gridSize > 16) fontSize = 11.0;

    Widget content;
    if (cell.value != null) {
      final bool isWrong = cell.isIncorrect || isConflict;
      final Color textColor = isWrong
          ? gameTheme.conflictTextColor
          : cell.isOriginal
          ? gameTheme.originalTextColor
          : gameTheme.inputTextColor;

      content = Center(
        child: Text(
          SymbolMapper.getCellSymbol(cell.value, symbolType),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: cell.isOriginal ? FontWeight.w800 : FontWeight.w500,
            color: textColor,
            height: 1.0,
          ),
        ),
      );
    } else if (cell.notes.isNotEmpty) {
      content = Padding(
        padding: const EdgeInsets.all(2.0),
        child: _NotesGrid(
          cell: cell,
          gridSize: gridSize,
          subGridSize: subGridSize,
          symbolType: symbolType,
          highlightedValue: highlightedValue,
          gameTheme: gameTheme,
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        margin: bg != Colors.transparent
            ? const EdgeInsets.all(3.5)
            : const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: borderRadius,
        ),
        child: AnimatedScale(
          scale: isIdentical ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: content,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notes mini-grid
// ---------------------------------------------------------------------------

class _NotesGrid extends StatelessWidget {
  const _NotesGrid({
    required this.cell,
    required this.gridSize,
    required this.subGridSize,
    required this.symbolType,
    required this.highlightedValue,
    required this.gameTheme,
  });

  final SudokuCell cell;
  final int gridSize;
  final int subGridSize;
  final SymbolType symbolType;
  final int? highlightedValue;
  final GameTheme gameTheme;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: subGridSize,
      ),
      itemCount: gridSize,
      itemBuilder: (context, index) {
        final digit = index + 1;
        if (!cell.notes.contains(digit)) return const SizedBox.shrink();

        final isHot = digit == highlightedValue;
        final double fontSize = gridSize > 9 ? 7.0 : 10.0;

        final text = Text(
          SymbolMapper.getCellSymbol(digit, symbolType),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isHot ? FontWeight.bold : FontWeight.normal,
            color: isHot
                ? gameTheme.inputTextColor
                : gameTheme.originalTextColor.withValues(alpha: 0.5),
          ),
        );

        return Center(
          child: isHot
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2.0,
                    vertical: 1.0,
                  ),
                  decoration: BoxDecoration(
                    color: gameTheme.identicalValueCellColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FittedBox(fit: BoxFit.scaleDown, child: text),
                )
              : FittedBox(fit: BoxFit.scaleDown, child: text),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Dashed grid line painter
// ---------------------------------------------------------------------------

class _DashedGridPainter extends CustomPainter {
  const _DashedGridPainter({required this.color, required this.divisions});

  final Color color;
  final int divisions;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashLen = 4.0;
    const gapLen = 4.0;

    for (var i = 1; i < divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      _dash(
        canvas,
        paint,
        Offset(x, 0),
        Offset(x, size.height),
        dashLen,
        gapLen,
      );
      _dash(
        canvas,
        paint,
        Offset(0, y),
        Offset(size.width, y),
        dashLen,
        gapLen,
      );
    }
  }

  void _dash(
    Canvas canvas,
    Paint paint,
    Offset from,
    Offset to,
    double dashLen,
    double gapLen,
  ) {
    final delta = to - from;
    final length = delta.distance;
    final step = dashLen + gapLen;
    final count = (length / step).floor();
    for (var i = 0; i < count; i++) {
      final t0 = i * step / length;
      final t1 = (i * step + dashLen) / length;
      canvas.drawLine(from + delta * t0, from + delta * t1, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedGridPainter old) =>
      old.color != color || old.divisions != divisions;
}

// ---------------------------------------------------------------------------
// Re-export old public widget name so game_page.dart doesn't need changes
// ---------------------------------------------------------------------------

/// Public-facing cell widget — kept so that any external references compile.
/// Internally the board now uses [_CellTile] directly.
class SudokuCellWidget extends StatelessWidget {
  const SudokuCellWidget({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.isConflict,
    required this.isCrosshair,
    required this.isIdenticalValue,
    this.highlightedValue,
    required this.gridSize,
    required this.subGridSize,
    required this.symbolType,
    required this.onTap,
  });

  final SudokuCell cell;
  final bool isSelected;
  final bool isConflict;
  final bool isCrosshair;
  final bool isIdenticalValue;
  final int? highlightedValue;
  final int gridSize;
  final int subGridSize;
  final SymbolType symbolType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ---------------------------------------------------------------------------
// Decorative quarter-circle arcs painter (bottom-right ornament)
// ---------------------------------------------------------------------------

class DecorativeArcsPainter extends CustomPainter {
  const DecorativeArcsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 20.0;
    const baseRadius = 70.0;
    const spacing = 44.0;
    const arcCount = 3;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width, size.height);

    for (var i = 0; i < arcCount; i++) {
      final radius = baseRadius + i * spacing;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi, // start: left side
        pi / 2, // sweep: 90° → bottom
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DecorativeArcsPainter old) => old.color != color;
}
