import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/game_theme.dart';
import '../../application/game_notifier.dart';

/// Pill-shaped toolbar placed above the numpad.
/// Contains: Undo · Erase · Notes · Hint
class GameControlPad extends ConsumerWidget {
  const GameControlPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);
    final gameTheme = ref.watch(gameThemeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: gameTheme.controlPadBackground,
          borderRadius: BorderRadius.circular(36),
          boxShadow: gameTheme.controlPadShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ToolButton(
              icon: Icons.undo_rounded,
              label: 'Undo',
              onPressed: state.canUndo ? () => notifier.undo() : null,
              gameTheme: gameTheme,
            ),
            _ToolButton(
              icon: Icons.close_rounded,
              label: 'Erase',
              onPressed: state.hasSelection
                  ? () => notifier.clearCell(
                      state.selectedRow!,
                      state.selectedCol!,
                    )
                  : null,
              gameTheme: gameTheme,
            ),
            _ToolButton(
              icon: Icons.bolt_rounded,
              label: 'Fast Note',
              badge: '${state.fastNoteQuota}',
              onPressed: () => notifier.fastFillNotes(),
              gameTheme: gameTheme,
            ),
            _ToolButton(
              icon: state.isNoteMode ? Icons.edit_rounded : Icons.edit_outlined,
              label: 'Note',
              isActive: state.isNoteMode,
              onPressed: () => notifier.toggleNoteMode(),
              gameTheme: gameTheme,
            ),
            _ToolButton(
              icon: Icons.lightbulb_outline_rounded,
              label: 'Hint',
              badge: '${state.hintQuota}',
              onPressed: () => notifier.useHint(),
              gameTheme: gameTheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.gameTheme,
    this.isActive = false,
    this.badge,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final String? badge;
  final VoidCallback? onPressed;
  final GameTheme gameTheme;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    final Color color;
    if (isActive) {
      color = gameTheme.selectedCellBorderColor;
    } else if (isDisabled) {
      color = Colors.grey.shade400;
    } else {
      color = Colors.grey.shade600;
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 20),
                if (badge != null)
                  Positioned(
                    right: -10,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
