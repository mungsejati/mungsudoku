import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/game_state.dart';
import '../../../../core/theme/game_theme.dart';

class GameTopBar extends ConsumerWidget {
  const GameTopBar({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final gameTheme = ref.watch(gameThemeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Difficulty & Mistakes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.difficulty.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: gameTheme.topBarTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mistakes: ${state.cumulativeMistakeCount}/${GameState.maxMistakes}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: state.cumulativeMistakeCount > 0
                      ? gameTheme.topBarMistakeColor
                      : gameTheme.topBarTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Timer & Pause
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 20,
                color: gameTheme.topBarTextColor,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDuration(state.gameDuration),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: gameTheme.topBarTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  state.isPaused ? Icons.play_arrow : Icons.pause,
                  color: gameTheme.topBarTextColor,
                ),
                onPressed: () {
                  if (state.isPaused) {
                    ref.read(gameNotifierProvider.notifier).resumeGame();
                  } else {
                    ref.read(gameNotifierProvider.notifier).pauseGame();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
