import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/game_theme.dart';
import '../application/game_notifier.dart';
import '../application/game_state.dart';
import 'widgets/game_control_pad.dart';
import 'widgets/game_number_pad.dart';
import '../domain/enums/difficulty.dart';
import 'widgets/game_theme_picker.dart';
import 'widgets/game_top_bar.dart';
import 'widgets/sudoku_board_widget.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(gameNotifierProvider);
      if (state.board.filledCellCount == 0 && !state.isLoading) {
        _showNewGameBottomSheet(context);
      }
    });
  }

  void _startNewGame(BuildContext context, Difficulty difficulty) {
    ref.read(gameNotifierProvider.notifier).initNewGame(difficulty);
  }

  void _showNewGameBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Difficulty.values.map((diff) {
              return ListTile(
                title: Text(diff.displayName),
                onTap: () {
                  Navigator.pop(context);
                  _startNewGame(context, diff);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showVictoryDialog(BuildContext context, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Puzzle Solved! 🎉'),
        content: Text(
          'Congratulations!\n'
          'Difficulty: ${state.difficulty.displayName}\n'
          'Time: ${_formatDuration(state.gameDuration)}\n'
          'Mistakes: ${state.board.mistakeCount}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Main Menu'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showNewGameBottomSheet(context);
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: const Text('You have reached the maximum number of mistakes.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Main Menu'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(gameNotifierProvider.notifier).restartPuzzle();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes.toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameNotifierProvider, (prev, next) {
      if (prev?.isVictory != true && next.isVictory) {
        _showVictoryDialog(context, next);
      }
      if (prev?.isGameOver != true && next.isGameOver) {
        _showGameOverDialog(context);
      }
    });

    final gameTheme = ref.watch(gameThemeProvider);
    final canAutoComplete = ref.watch(gameNotifierProvider.select((s) => s.canAutoComplete));
    final isLoading = ref.watch(gameNotifierProvider.select((s) => s.isLoading));

    return Scaffold(
      body: Stack(
        children: [
          // ---- Solid colour background ----
          Container(color: gameTheme.background),

          // ---- Decorative arcs (bottom-right corner) ----
          Positioned(
            right: 0,
            bottom: 0,
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: DecorativeArcsPainter(color: gameTheme.arcColor),
            ),
          ),

          // ---- Main content ----
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    // ---- AppBar row ----
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            color: gameTheme.topBarTextColor,
                            onPressed: () => context.go('/'),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Sudoku',
                                style: TextStyle(
                                  color: gameTheme.topBarTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const GameThemePopupMenu(),
                        ],
                      ),
                    ),

                    // ---- Stats row (timer, mistakes, hints) ----
                    const GameTopBar(),

                    // ---- Board ----
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.0,
                              vertical: 12.0,
                            ),
                            child: Center(child: SudokuBoardWidget()),
                          ),
                          if (isLoading)
                            Container(
                              decoration: BoxDecoration(
                                color: gameTheme.background.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: 80,
                              height: 80,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ---- Auto Complete Button ----
                    if (canAutoComplete)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: _PulseAutoCompleteButton(),
                      ),

                    // ---- Toolbar overlapping numpad (Stack overlap) ----
                    SizedBox(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // Numpad sits behind with top padding for the overlap
                          const Padding(
                            padding: EdgeInsets.only(top: 42),
                            child: GameNumberPad(),
                          ),
                          // Control toolbar overlaps the top of the numpad
                          const GameControlPad(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseAutoCompleteButton extends ConsumerStatefulWidget {
  const _PulseAutoCompleteButton();

  @override
  ConsumerState<_PulseAutoCompleteButton> createState() => _PulseAutoCompleteButtonState();
}

class _PulseAutoCompleteButtonState extends ConsumerState<_PulseAutoCompleteButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _shadowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: _shadowAnimation.value,
                  spreadRadius: _shadowAnimation.value / 4,
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: () => ref.read(gameNotifierProvider.notifier).triggerAutoComplete(),
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text(
                'Auto Complete ✨',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Emerald Green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        );
      },
    );
  }
}
