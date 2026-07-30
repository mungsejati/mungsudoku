import 'package:flutter/material.dart';

import '../../domain/entities/sudoku_cell.dart';
import '../../domain/enums/symbol_type.dart';
import '../utils/symbol_mapper.dart';

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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ---- Background palette ----
    // Priority: conflict > selected > identical > crosshair > original > empty
    Color backgroundColor;
    Border? border;

    if (isConflict) {
      backgroundColor = isDark
          ? const Color(0xFF5C1A1A)
          : const Color(0xFFFFDDDD);
      border = Border.all(color: colorScheme.error, width: 1.5);
    } else if (isSelected) {
      // Yellow-highlight selected cell with a blue border (premium Sudoku style)
      backgroundColor = isDark
          ? const Color(0xFF2A4A6A)
          : const Color(0xFFFFF9C4);
      border = Border.all(
        color: colorScheme.primary,
        width: 2.0,
      );
    } else if (isIdenticalValue) {
      // Soft blue for cells sharing the same value
      backgroundColor = isDark
          ? const Color(0xFF1B3557)
          : const Color(0xFFBBDEFB);
    } else if (isCrosshair) {
      // Very light grey crosshair
      backgroundColor = isDark
          ? const Color(0xFF2A2A35)
          : const Color(0xFFEEEEF4);
    } else if (cell.isOriginal) {
      backgroundColor = isDark
          ? const Color(0xFF252530)
          : const Color(0xFFE8E8F0);
    } else {
      backgroundColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border ??
              Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 0.5,
              ),
        ),
        child: Center(
          child: _buildContent(context, colorScheme),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    if (cell.value != null) {
      double fontSize = 22.0;
      if (gridSize > 9) fontSize = 15.0;
      if (gridSize > 16) fontSize = 11.0;

      final Color textColor;
      if (isConflict) {
        textColor = colorScheme.error;
      } else if (cell.isOriginal) {
        textColor = colorScheme.onSurface;
      } else {
        textColor = colorScheme.primary;
      }

      return Text(
        SymbolMapper.getCellSymbol(cell.value, symbolType),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: cell.isOriginal ? FontWeight.w800 : FontWeight.w500,
          color: textColor,
          height: 1.0,
        ),
      );
    } else if (cell.notes.isNotEmpty) {
      return _buildNotesGrid(context, colorScheme);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildNotesGrid(BuildContext context, ColorScheme colorScheme) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: subGridSize,
        childAspectRatio: 1.0,
      ),
      itemCount: gridSize,
      itemBuilder: (context, index) {
        final digit = index + 1;
        if (!cell.notes.contains(digit)) return const SizedBox.shrink();

        final isHighlightedNote = digit == highlightedValue;
        final double fontSize = gridSize > 9 ? 7.0 : 10.0;

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              SymbolMapper.getCellSymbol(digit, symbolType),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight:
                    isHighlightedNote ? FontWeight.bold : FontWeight.normal,
                color: isHighlightedNote
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}
