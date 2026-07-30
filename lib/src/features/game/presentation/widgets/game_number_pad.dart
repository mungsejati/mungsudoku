import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/game_theme.dart';
import '../../application/game_notifier.dart';
import '../utils/symbol_mapper.dart';

class GameNumberPad extends ConsumerWidget {
  const GameNumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);
    final gameTheme = ref.watch(gameThemeProvider);
    final board = state.board;
    final gridSize = board.gridSize;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;
    
    final bool useSingleRow = gridSize <= 9;
    final double spacing = 4.0;

    final digitButtons = [
      for (int digit = 1; digit <= gridSize; digit++)
        _buildDigitButton(
          context,
          digit,
          gridSize,
          state,
          notifier,
          gameTheme,
          board,
          isSmallScreen,
        ),
    ];

    Widget buttons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (useSingleRow)
          ...digitButtons.map((btn) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: btn,
                ),
              ))
        else
          Expanded(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.center,
              children: digitButtons
                  .map((btn) => SizedBox(width: 40, child: btn))
                  .toList(),
            ),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        decoration: BoxDecoration(
          color: gameTheme.numpadBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: gameTheme.controlPadShadow,
        ),
        padding: const EdgeInsets.fromLTRB(8, 52, 8, 16),
        child: buttons,
      ),
    );
  }

  Widget _buildDigitButton(
    BuildContext context,
    int digit,
    int gridSize,
    dynamic state,
    dynamic notifier,
    GameTheme gameTheme,
    dynamic board,
    bool isSmallScreen,
  ) {
    int placedCount = 0;
    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        if (board.cellAt(r, c).value == digit) placedCount++;
      }
    }
    final remaining = gridSize - placedCount;
    final isComplete = remaining <= 0;
    final isActive = state.activeValue == digit;

    final double fontSize = gridSize > 9
        ? (isSmallScreen ? 12 : 14)
        : (isSmallScreen ? 20 : 24);

    return _NumpadDigitButton(
      label: SymbolMapper.getCellSymbol(digit, state.symbolType),
      remaining: remaining,
      isComplete: isComplete,
      isActive: isActive,
      fontSize: fontSize,
      gameTheme: gameTheme,
      onPressed: isComplete
          ? null
          : () {
              Future.microtask(() {
                if (state.hasSelection) {
                  notifier.inputNumber(
                    state.selectedRow!,
                    state.selectedCol!,
                    digit,
                  );
                } else {
                  notifier.activateValue(digit);
                }
              });
            },
      onLongPress: () => Future.microtask(() => notifier.activateValue(digit)),
    );
  }
}

/// A square numpad button with an overlapping circular badge showing
/// how many of this digit remain to be placed.
class _NumpadDigitButton extends StatelessWidget {
  const _NumpadDigitButton({
    required this.label,
    required this.remaining,
    required this.isComplete,
    required this.isActive,
    required this.fontSize,
    required this.gameTheme,
    this.onPressed,
    this.onLongPress,
  });

  final String label;
  final int remaining;
  final bool isComplete;
  final bool isActive;
  final double fontSize;
  final GameTheme gameTheme;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final Color bg = isActive
        ? gameTheme.selectedCellColor
        : gameTheme.numpadButtonBackground;

    final Color textColor = isComplete
        ? Colors.grey.shade400
        : isActive
        ? gameTheme.selectedCellBorderColor
        : gameTheme.inputTextColor;

    final badgeColor = isActive
        ? gameTheme.selectedCellBorderColor
        : gameTheme.inputTextColor.withValues(alpha: 0.65);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0), // Reserve space for the overlapping badge
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Main square button
            AspectRatio(
              aspectRatio: 1.0, // Perfect square
              child: Container(
                decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isComplete ? null : gameTheme.numpadButtonShadow,
                border: isActive
                    ? Border.all(
                        color: gameTheme.selectedCellBorderColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ),
            ),

            // Circular badge — overlaps bottom centre
            if (!isComplete && remaining > 0)
              Positioned(
                bottom: -10,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: gameTheme.numpadBackground,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$remaining',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
