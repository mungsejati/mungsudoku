import re

def update_list_page():
    path = "lib/src/features/custom_sudoku/presentation/custom_sudoku_list_page.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Update itemBuilder in CustomSudokuListPage
    replacement1 = """            itemBuilder: (context, index) {
              final puzzle = puzzles[index];
              return _CustomSudokuCard(
                puzzle: puzzle,
                index: puzzles.length - index,
                gameTheme: gameTheme,
                onTap: () {
                  ref.read(gameNotifierProvider.notifier).initCustomGame(puzzle);
                  context.go(AppRouter.gamePath);
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Puzzle?'),
                      content: const Text('Are you sure you want to delete this puzzle?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && puzzle.id != null) {
                    ref.read(customSudokuListNotifierProvider.notifier).deletePuzzle(puzzle.id!);
                  }
                },
              );
            },"""
    
    content = re.sub(
        r'            itemBuilder: \(context, index\) \{.*?            \},',
        replacement1,
        content,
        flags=re.DOTALL
    )

    # 2. Update _CustomSudokuCard parameters
    replacement2 = """class _CustomSudokuCard extends StatelessWidget {
  const _CustomSudokuCard({
    required this.puzzle,
    required this.index,
    required this.gameTheme,
    required this.onTap,
    required this.onDelete,
  });

  final SudokuBoard puzzle;
  final int index;
  final GameTheme gameTheme;
  final VoidCallback onTap;
  final VoidCallback onDelete;"""

    content = re.sub(
        r'class _CustomSudokuCard extends StatelessWidget \{.*?  final VoidCallback onTap;',
        replacement2,
        content,
        flags=re.DOTALL
    )

    # 3. Update _CustomSudokuCard UI
    replacement3 = """            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code: ${puzzle.id ?? "Unknown"}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: gameTheme.topBarTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${puzzle.gridSize}x${puzzle.gridSize} Grid • Created: ${puzzle.createdAt?.toString().substring(0, 16) ?? "-"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: gameTheme.topBarTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
            const SizedBox(width: 8),
            Icon(Icons.play_arrow_rounded, color: gameTheme.arcColor, size: 32),
          ],
        ),
      ),
    );"""
    
    content = re.sub(
        r'            Expanded\(\s*child: Column\(\s*crossAxisAlignment: CrossAxisAlignment\.start,\s*children: \[.*?            Icon\(Icons\.play_arrow_rounded, color: gameTheme\.arcColor, size: 32\),\s*\],\s*\),\s*\),\s*\);',
        replacement3,
        content,
        flags=re.DOTALL
    )

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

update_list_page()
