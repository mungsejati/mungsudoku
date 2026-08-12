import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/game_theme.dart';
import '../application/game_notifier.dart';
import 'game_result_args.dart';

class GameResultPage extends ConsumerWidget {
  final GameResultArgs args;

  const GameResultPage({super.key, required this.args});

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes.toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameTheme = ref.watch(gameThemeProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: gameTheme.background),
          Positioned(
            right: 0,
            bottom: 0,
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: _DecorativeArcsPainter(color: gameTheme.arcColor),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 48.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        args.isVictory ? 'Victory!' : 'Game Over',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: gameTheme.topBarTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Message
                      Text(
                        args.isVictory
                            ? 'Congratulations on solving the puzzle!'
                            : 'You have reached the maximum number of mistakes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: gameTheme.topBarTextColor.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Stats Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: gameTheme.subGridBackground,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _StatRow(
                              label: 'Difficulty',
                              value: args.difficulty.displayName,
                              textColor: gameTheme.originalTextColor,
                            ),
                            const Divider(height: 32),
                            _StatRow(
                              label: 'Time',
                              value: _formatDuration(args.time),
                              textColor: gameTheme.originalTextColor,
                            ),
                            const Divider(height: 32),
                            _StatRow(
                              label: 'Mistakes',
                              value: '${args.mistakes}/${args.maxMistakes}',
                              textColor: gameTheme.originalTextColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Actions
                      _FilledPillButton(
                        label: args.isVictory ? 'Play Again' : 'Try Again',
                        backgroundColor: gameTheme.subGridBackground,
                        textColor: gameTheme.inputTextColor,
                        onTap: () {
                          if (args.isVictory) {
                            ref
                                .read(gameNotifierProvider.notifier)
                                .initNewGame(args.difficulty);
                          } else {
                            ref
                                .read(gameNotifierProvider.notifier)
                                .restartPuzzle();
                          }
                          context.go('/game');
                        },
                      ),
                      const SizedBox(height: 16),
                      _OutlinedPillButton(
                        label: 'Main Menu',
                        color: gameTheme.topBarTextColor,
                        onTap: () => context.go('/'),
                      ),
                    ],
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

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  const _StatRow({
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: textColor.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FilledPillButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _FilledPillButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedPillButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OutlinedPillButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DecorativeArcsPainter extends CustomPainter {
  final Color color;

  _DecorativeArcsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width, size.height);

    canvas.drawCircle(center, size.width * 0.4, paint);
    canvas.drawCircle(center, size.width * 0.6, paint);
    canvas.drawCircle(center, size.width * 0.8, paint);
    canvas.drawCircle(center, size.width * 1.0, paint);
  }

  @override
  bool shouldRepaint(covariant _DecorativeArcsPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
