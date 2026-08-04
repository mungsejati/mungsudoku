import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/game_theme.dart';
import '../../game/application/game_notifier.dart';
import '../../game/domain/entities/sudoku_board.dart';
import '../application/custom_sudoku_list_notifier.dart';

class CustomSudokuListPage extends ConsumerWidget {
  const CustomSudokuListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customSudokuListNotifierProvider);
    final gameTheme = ref.watch(gameThemeProvider);

    return Scaffold(
      backgroundColor: gameTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: gameTheme.topBarTextColor),
        title: Text(
          'My Custom Puzzles',
          style: TextStyle(
            color: gameTheme.topBarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: state.when(
        data: (puzzles) {
          if (puzzles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.extension_off_rounded, size: 64, color: gameTheme.cellBorderColor),
                  const SizedBox(height: 16),
                  Text(
                    'No custom puzzles yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: gameTheme.topBarTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create a new one',
                    style: TextStyle(
                      fontSize: 14,
                      color: gameTheme.topBarTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: puzzles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final puzzle = puzzles[index];
              return _CustomSudokuCard(
                puzzle: puzzle,
                index: puzzles.length - index,
                gameTheme: gameTheme,
                onTap: () {
                  ref.read(gameNotifierProvider.notifier).initCustomGame(puzzle);
                  context.go(AppRouter.gamePath);
                },
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: gameTheme.arcColor)),
        error: (err, _) => Center(child: Text('Error loading puzzles: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: gameTheme.arcColor,
        foregroundColor: Colors.white,
        onPressed: () {
          context.push(AppRouter.customSudokuPath);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CustomSudokuCard extends StatelessWidget {
  const _CustomSudokuCard({
    required this.puzzle,
    required this.index,
    required this.gameTheme,
    required this.onTap,
  });

  final SudokuBoard puzzle;
  final int index;
  final GameTheme gameTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: gameTheme.subGridBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: gameTheme.subGridShadow,
          border: Border.all(color: gameTheme.cellBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: gameTheme.arcColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.grid_on_rounded,
                  color: gameTheme.arcColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Puzzle #$index',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: gameTheme.topBarTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${puzzle.gridSize}x${puzzle.gridSize} Grid',
                    style: TextStyle(
                      fontSize: 14,
                      color: gameTheme.topBarTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, color: gameTheme.arcColor, size: 32),
          ],
        ),
      ),
    );
  }
}
