import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../settings/application/settings_notifier.dart';
import '../../../../core/theme/game_theme.dart';

class GameThemePopupMenu extends ConsumerWidget {
  const GameThemePopupMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameTheme = ref.watch(gameThemeProvider);
    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          icon: SvgPicture.asset(
            'assets/theme.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(gameTheme.topBarTextColor, BlendMode.srcIn),
          ),
          tooltip: 'Theme',
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Theme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _ThemeSwatch(name: 'Blue', preset: 'blue', color: Color(0xFF1E9BED)),
                  SizedBox(width: 8),
                  _ThemeSwatch(name: 'Red', preset: 'red', color: Color(0xFFE53935)),
                  SizedBox(width: 8),
                  _ThemeSwatch(name: 'Green', preset: 'green', color: Color(0xFF43A047)),
                  SizedBox(width: 8),
                  _ThemeSwatch(name: 'White', preset: 'white', color: Color(0xFFF5F5F5)),
                  SizedBox(width: 8),
                  _ThemeSwatch(name: 'Black', preset: 'black', color: Color(0xFF121212)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSwatch extends ConsumerWidget {
  const _ThemeSwatch({
    required this.name,
    required this.preset,
    required this.color,
  });

  final String name;
  final String preset;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(settingsNotifierProvider.select((state) => state.gameThemePreset));
    final isSelected = activeTheme == preset || (activeTheme == 'dark' && preset == 'black');

    return GestureDetector(
      onTap: () {
        ref.read(settingsNotifierProvider.notifier).setGameThemePreset(preset);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey.withValues(alpha: 0.3),
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
                size: 20,
                color: preset == 'white' ? Colors.black : Colors.white,
              )
            : null,
      ),
    );
  }
}
