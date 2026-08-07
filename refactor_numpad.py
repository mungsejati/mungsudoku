import re

with open('lib/src/features/game/presentation/widgets/game_number_pad.dart', 'r') as f:
    content = f.read()

# Remove `final state = ref.watch(gameNotifierProvider);`
content = content.replace("    final state = ref.watch(gameNotifierProvider);\n", "")

# Change board = state.board to use select
content = content.replace("    final board = state.board;\n", "    final board = ref.watch(gameNotifierProvider.select((s) => s.board));\n")

# Note: board is also changing frequently? Yes, when we input. But we need board.gridSize, which doesn't change during a game.
# Wait, `gridSize` doesn't change, but if we watch `board`, we rebuild on EVERY INPUT.
# Is that okay? We want the numpad to rebuild only when `placedCount` changes, or when `activeValue` changes.
# Actually, the user asked to make `_NumpadDigitButton` smart. Let's rewrite `GameNumberPad` and `_NumpadDigitButton` completely.

new_code = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/game_theme.dart';
import '../../application/game_notifier.dart';
import '../utils/symbol_mapper.dart';

class GameNumberPad extends ConsumerWidget {
  const GameNumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch what doesn't change frequently during a game, or what needs a full numpad structural rebuild.
    final gridSize = ref.watch(gameNotifierProvider.select((s) => s.board.gridSize));
    final gameTheme = ref.watch(gameThemeProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;
    
    final bool useSingleRow = gridSize <= 9;
    final double spacing = 4.0;

    final digitButtons = [
      for (int digit = 1; digit <= gridSize; digit++)
        _SmartDigitButton(
          digit: digit,
          gridSize: gridSize,
          gameTheme: gameTheme,
          isSmallScreen: isSmallScreen,
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
}

class _SmartDigitButton extends ConsumerWidget {
  final int digit;
  final int gridSize;
  final GameTheme gameTheme;
  final bool isSmallScreen;

  const _SmartDigitButton({
    required this.digit,
    required this.gridSize,
    required this.gameTheme,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider.notifier);
    
    // Specifically select only what this button needs to avoid UI Jank (timer rebuilds)
    final isActive = ref.watch(gameNotifierProvider.select((s) => s.activeValue == digit));
    final symbolType = ref.watch(gameNotifierProvider.select((s) => s.symbolType));
    
    // Watch placedCount directly to only rebuild when THIS number is placed/removed
    final placedCount = ref.watch(gameNotifierProvider.select((s) {
      int count = 0;
      final board = s.board;
      for (var r = 0; r < board.gridSize; r++) {
        for (var c = 0; c < board.gridSize; c++) {
          if (board.cellAt(r, c).value == digit) count++;
        }
      }
      return count;
    }));

    final remaining = gridSize - placedCount;
    final isComplete = remaining <= 0;

    final double fontSize = gridSize > 9
        ? (isSmallScreen ? 12 : 14)
        : (isSmallScreen ? 20 : 24);

    return _NumpadDigitButton(
      label: SymbolMapper.getCellSymbol(digit, symbolType),
      remaining: remaining,
      isComplete: isComplete,
      isActive: isActive,
      fontSize: fontSize,
      gameTheme: gameTheme,
      onPressed: isComplete
          ? null
          : () {
              final freshState = ref.read(gameNotifierProvider);
              if (freshState.hasSelection) {
                notifier.inputNumber(
                  freshState.selectedRow!,
                  freshState.selectedCol!,
                  digit,
                );
              } else {
                notifier.activateValue(digit);
              }
            },
      onLongPress: () => notifier.activateValue(digit),
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
"""

with open('lib/src/features/game/presentation/widgets/game_number_pad.dart', 'w') as f:
    f.write(new_code)
