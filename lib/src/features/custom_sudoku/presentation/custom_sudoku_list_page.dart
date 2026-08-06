import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/game_theme.dart';
import '../../game/application/game_notifier.dart';
import '../../game/domain/entities/sudoku_board.dart';
import '../../game/presentation/widgets/game_theme_picker.dart';
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
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/arrow-left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              gameTheme.topBarTextColor,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Sudoku',
          style: TextStyle(
            color: gameTheme.topBarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [GameThemePopupMenu()],
      ),
      body: Column(
        children: [
          // + Create New Button
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: TextButton.icon(
              onPressed: () => context.push(AppRouter.customSudokuPath),
              icon: Icon(Icons.add, color: gameTheme.topBarTextColor, size: 28),
              label: Text(
                'Create New',
                style: TextStyle(
                  color: gameTheme.topBarTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          // List Section
          Expanded(
            child: state.when(
              data: (puzzles) {
                if (puzzles.isEmpty) {
                  return Center(
                    child: Text(
                      'No custom puzzles yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: gameTheme.topBarTextColor.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: puzzles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final puzzle = puzzles[index];
                    return _CustomSudokuCard(
                      puzzle: puzzle,
                      gameTheme: gameTheme,
                      onTap: () {
                        ref
                            .read(gameNotifierProvider.notifier)
                            .initCustomGame(puzzle);
                        context.go(AppRouter.gamePath);
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Puzzle?'),
                            content: const Text(
                              'Are you sure you want to delete this puzzle?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && puzzle.id != null) {
                          ref
                              .read(customSudokuListNotifierProvider.notifier)
                              .deletePuzzle(puzzle.id!);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: gameTheme.topBarTextColor,
                ),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error loading puzzles: $err',
                  style: TextStyle(color: gameTheme.topBarTextColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomSudokuCard extends StatelessWidget {
  const _CustomSudokuCard({
    required this.puzzle,
    required this.gameTheme,
    required this.onTap,
    required this.onDelete,
  });

  final SudokuBoard puzzle;
  final GameTheme gameTheme;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color _getCardThemeColor(GameTheme theme) {
    if (theme.background.computeLuminance() > 0.8) {
      return Colors.black87;
    }
    return theme.background;
  }

  void _showShareOptions(BuildContext context, GameTheme theme) {
    final cardThemeColor = _getCardThemeColor(theme);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: SvgPicture.asset(
                  'assets/copy.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    cardThemeColor,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text(
                  'Copy Code',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: puzzle.id ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kode disalin!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.link_rounded, color: cardThemeColor),
                title: const Text(
                  'Share Link',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  // Mock print for Share Link
                  debugPrint(
                    'Mock Share: Sharing link for puzzle ${puzzle.id}',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membuka menu share... (Mock)'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final puzzleIdStr = puzzle.id != null
        ? '#SDK-${puzzle.id!.length > 8 ? puzzle.id!.substring(0, 8).toUpperCase() : puzzle.id!.toUpperCase()}'
        : '#SDK-UNKNOWN';
    final dateStr = puzzle.createdAt?.toString().substring(0, 10) ?? '-';
    final cardThemeColor = _getCardThemeColor(gameTheme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sudoku $puzzleIdStr',
                    style: TextStyle(fontSize: 16, color: cardThemeColor),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/calendar.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF5A5A5A),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5A5A5A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/share.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(cardThemeColor, BlendMode.srcIn),
              ),
              onPressed: () => _showShareOptions(context, gameTheme),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
