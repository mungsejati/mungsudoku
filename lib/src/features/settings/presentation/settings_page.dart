import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/settings_notifier.dart';
import '../../../core/theme/game_theme.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final gameTheme = ref.watch(gameThemeProvider);

    return Scaffold(
      backgroundColor: gameTheme.background,
      appBar: AppBar(
        backgroundColor: gameTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: gameTheme.topBarTextColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: gameTheme.topBarTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Preview Section
              _LivePreviewCard(gameTheme: gameTheme),
              const SizedBox(height: 40),

              // Font Size Selector
              Text(
                'Font Size',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: gameTheme.topBarTextColor,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<double>(
                segments: const [
                  ButtonSegment(value: 0.8, label: Text('Small')),
                  ButtonSegment(value: 1.0, label: Text('Medium')),
                  ButtonSegment(value: 1.2, label: Text('Big')),
                ],
                selected: {settings.fontSizeFactor},
                onSelectionChanged: (Set<double> newSelection) {
                  notifier.setFontSizeFactor(newSelection.first);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return gameTheme.inputTextColor;
                    }
                    return gameTheme.topBarTextColor;
                  }),
                  side: WidgetStateProperty.resolveWith<BorderSide>(
                    (Set<WidgetState> states) => BorderSide(
                      color: states.contains(WidgetState.selected)
                          ? gameTheme.selectedCellColor
                          : gameTheme.topBarTextColor.withValues(alpha: 0.3),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return gameTheme.selectedCellColor;
                    }
                    return Colors.transparent;
                  }),
                ),
              ), // End SegmentedButton

              const SizedBox(height: 40),

              // Game Theme Selector
              Text(
                'Game Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: gameTheme.topBarTextColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _GameThemeSwatch(
                    name: 'Blue',
                    preset: 'blue',
                    color: Color(0xFF1E9BED),
                  ),
                  _GameThemeSwatch(
                    name: 'Red',
                    preset: 'red',
                    color: Color(0xFFE53935),
                  ),
                  _GameThemeSwatch(
                    name: 'Green',
                    preset: 'green',
                    color: Color(0xFF43A047),
                  ),
                  _GameThemeSwatch(
                    name: 'White',
                    preset: 'white',
                    color: Color(0xFFF5F5F5),
                  ),
                  _GameThemeSwatch(
                    name: 'Black',
                    preset: 'black',
                    color: Color(0xFF121212),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivePreviewCard extends StatelessWidget {
  final GameTheme gameTheme;

  const _LivePreviewCard({required this.gameTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gameTheme.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_rounded, color: gameTheme.topBarTextColor),
              const SizedBox(width: 8),
              Text(
                'Board Preview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: gameTheme.topBarTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: gameTheme.subGridBackground,
                borderRadius: BorderRadius.circular(
                  gameTheme.subGridBorderRadius,
                ),
                boxShadow: gameTheme.subGridShadow,
              ),
              child: Stack(
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: List.generate(9, (index) {
                      final isSelected = index == 4;
                      final isConflict = index == 2;
                      final isSameVal = index == 0;

                      Color bg = Colors.transparent;
                      Color txt = gameTheme.inputTextColor;
                      String val = "";

                      if (isSelected) {
                        bg = gameTheme.selectedCellColor;
                        val = "5";
                      } else if (isConflict) {
                        bg = gameTheme.conflictCellColor;
                        txt = gameTheme.conflictTextColor;
                        val = "5";
                      } else if (isSameVal) {
                        bg = gameTheme.identicalValueCellColor;
                        txt = gameTheme.originalTextColor;
                        val = "5";
                      } else if (index == 1) {
                        txt = gameTheme.originalTextColor;
                        val = "1";
                      }

                      return Container(
                        margin: const EdgeInsets.all(1.0),
                        decoration: BoxDecoration(
                          color: bg,
                          // border: Border.all(
                          //   color: gameTheme.cellBorderColor,
                          //   width: 0.5,
                          // ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            val,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: (index == 1 || isSameVal)
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: txt,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _DashedGridPainter(
                          color: gameTheme.cellBorderColor,
                          rows: 3,
                          cols: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameThemeSwatch extends ConsumerWidget {
  const _GameThemeSwatch({
    required this.name,
    required this.preset,
    required this.color,
  });

  final String name;
  final String preset;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(
      settingsNotifierProvider.select((state) => state.gameThemePreset),
    );
    final gameTheme = ref.watch(gameThemeProvider);
    final isSelected =
        activeTheme == preset || (activeTheme == 'dark' && preset == 'black');

    return GestureDetector(
      onTap: () {
        ref.read(settingsNotifierProvider.notifier).setGameThemePreset(preset);
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? gameTheme.topBarTextColor
                    : gameTheme.topBarTextColor.withValues(alpha: 0.3),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 24,
                    color: preset == 'white' ? Colors.black : Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: gameTheme.topBarTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashed grid line painter (copied from game board for consistency)
// ---------------------------------------------------------------------------

class _DashedGridPainter extends CustomPainter {
  const _DashedGridPainter({
    required this.color,
    required this.rows,
    required this.cols,
  });

  final Color color;
  final int rows;
  final int cols;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashLen = 4.0;
    const gapLen = 4.0;

    for (var i = 1; i < cols; i++) {
      final x = size.width * i / cols;
      _dash(
        canvas,
        paint,
        Offset(x, 0),
        Offset(x, size.height),
        dashLen,
        gapLen,
      );
    }
    for (var i = 1; i < rows; i++) {
      final y = size.height * i / rows;
      _dash(
        canvas,
        paint,
        Offset(0, y),
        Offset(size.width, y),
        dashLen,
        gapLen,
      );
    }
  }

  void _dash(
    Canvas canvas,
    Paint paint,
    Offset from,
    Offset to,
    double dashLen,
    double gapLen,
  ) {
    final delta = to - from;
    final length = delta.distance;
    final step = dashLen + gapLen;
    final count = (length / step).floor();
    for (var i = 0; i < count; i++) {
      final t0 = i * step / length;
      final t1 = (i * step + dashLen) / length;
      canvas.drawLine(from + delta * t0, from + delta * t1, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedGridPainter old) =>
      old.color != color || old.rows != rows || old.cols != cols;
}
