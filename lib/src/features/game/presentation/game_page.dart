import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/theme/game_theme.dart';
import '../application/game_notifier.dart';
import '../application/game_state.dart';
import 'widgets/game_control_pad.dart';
import 'widgets/game_number_pad.dart';
import '../domain/enums/difficulty.dart';
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
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(gameNotifierProvider);
      if (state.board.filledCellCount == 0) {
        _showNewGameBottomSheet(context);
      }
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
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
              final s = ref.read(gameNotifierProvider);
              ref
                  .read(gameNotifierProvider.notifier)
                  .initNewGame(
                    s.difficulty,
                    subGridSize: s.selectedSubGridSize,
                    symbolType: s.symbolType,
                  );
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
                            color: Colors.white,
                            onPressed: () => context.go('/'),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Sudoku',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: Colors.white,
                            tooltip: 'New Game',
                            onPressed: () => _showNewGameBottomSheet(context),
                          ),
                        ],
                      ),
                    ),

                    // ---- Stats row (timer, mistakes, hints) ----
                    const GameTopBar(),

                    // ---- Board ----
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Center(child: const SudokuBoardWidget()),
                      ),
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
                          
                          // Auto Complete Button
                          if (canAutoComplete)
                            Positioned(
                              top: -46,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                builder: (context, val, child) {
                                  return Transform.scale(
                                    scale: val,
                                    child: child,
                                  );
                                },
                                child: FilledButton.icon(
                                  onPressed: () => ref.read(gameNotifierProvider.notifier).triggerAutoComplete(),
                                  icon: const Icon(Icons.auto_awesome_rounded),
                                  label: const Text(
                                    'Auto Complete',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.amberAccent,
                                    foregroundColor: Colors.black87,
                                    elevation: 6,
                                  ),
                                ),
                              ),
                            ),
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
