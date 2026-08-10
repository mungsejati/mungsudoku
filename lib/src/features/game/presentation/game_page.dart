import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/game_theme.dart';
import '../application/game_notifier.dart';
import '../application/game_state.dart';
import 'game_result_args.dart';
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

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameNotifierProvider, (prev, next) {
      if (prev?.isVictory != true && next.isVictory) {
        context.go('/result', extra: GameResultArgs(
          isVictory: true,
          difficulty: next.difficulty,
          time: next.gameDuration,
          mistakes: next.cumulativeMistakeCount,
          maxMistakes: GameState.maxMistakes,
        ));
      }
      if (prev?.isGameOver != true && next.isGameOver) {
        context.go('/result', extra: GameResultArgs(
          isVictory: false,
          difficulty: next.difficulty,
          time: next.gameDuration,
          mistakes: next.cumulativeMistakeCount,
          maxMistakes: GameState.maxMistakes,
        ));
      }
    });

    final gameTheme = ref.watch(gameThemeProvider);
    
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
                            icon: SvgPicture.asset(
                              'assets/arrow-left.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(gameTheme.topBarTextColor, BlendMode.srcIn),
                            ),
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
                          if (ref.watch(gameNotifierProvider.select((s) => s.isAutoCompleteRunning)))
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: gameTheme.background.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Auto completing...',
                                  style: TextStyle(
                                    color: gameTheme.topBarTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                        ],
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

