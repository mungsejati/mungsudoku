import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';
import '../../game/application/game_notifier.dart';
import '../../game/domain/enums/difficulty.dart';
import 'widgets/menu_button.dart';

/// Main menu screen — the application's entry point for the player.
///
/// Phase 1: "Play Classic" is active.
/// Phase 2/3 buttons are visible but disabled as placeholders.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('current_game')) {
      setState(() => _hasSavedGame = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              const _Logo(),
              const SizedBox(height: 48),
              _MenuButtons(hasSavedGame: _hasSavedGame, ref: ref),
              const Spacer(),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.grid_4x4_rounded,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'MungSudoku',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Custom & Social Sudoku',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _MenuButtons extends StatelessWidget {
  const _MenuButtons({required this.hasSavedGame, required this.ref});

  final bool hasSavedGame;
  final WidgetRef ref;

  void _startNewGame(BuildContext context, Difficulty difficulty) {
    ref.read(gameNotifierProvider.notifier).initNewGame(difficulty);
    context.go(AppRouter.gamePath);
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
    return Column(
      children: [
        if (hasSavedGame) ...[
          MenuButton(
            label: 'Resume Game',
            icon: Icons.play_circle_filled_rounded,
            onPressed: () {
              ref.read(gameNotifierProvider.notifier).loadSavedGame();
              context.go(AppRouter.gamePath);
            },
          ),
          const SizedBox(height: 12),
        ],
        MenuButton(
          label: 'New Game',
          icon: Icons.play_arrow_rounded,
          onPressed: () => _showNewGameBottomSheet(context),
        ),
        const SizedBox(height: 12),
        const MenuButton(
          label: 'Custom & Creator Mode',
          icon: Icons.design_services_rounded,
          isEnabled: false,
          onPressed: null,
        ),
        const SizedBox(height: 12),
        const MenuButton(
          label: 'Enter Challenge Code',
          icon: Icons.vpn_key_rounded,
          isEnabled: false,
          onPressed: null,
        ),
        const SizedBox(height: 12),
        const MenuButton(
          label: 'Settings',
          icon: Icons.settings_rounded,
          isEnabled: false,
          onPressed: null,
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Phase 1 — Core Engine',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}
