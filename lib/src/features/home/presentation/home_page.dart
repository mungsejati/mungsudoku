import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/router/app_router.dart';
import '../../game/application/game_notifier.dart';
import '../../game/domain/enums/difficulty.dart';

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
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PlayerStatsHeader(),
                const SizedBox(height: 48),
                const _MiniSudokuHero(),
                const SizedBox(height: 64),
                _GameModes(hasSavedGame: _hasSavedGame, ref: ref),
                const SizedBox(height: 40),
                const Center(child: _Footer()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerStatsHeader extends StatelessWidget {
  const _PlayerStatsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar & Name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, color: Colors.blueAccent, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'Player 1',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
        // Quotas
        Row(
          children: [
            _QuotaBadge(icon: Icons.lightbulb_rounded, color: Colors.amber.shade600, count: '3'),
            const SizedBox(width: 8),
            _QuotaBadge(icon: Icons.bolt_rounded, color: Colors.blue.shade600, count: '5'),
          ],
        )
      ],
    );
  }
}

class _QuotaBadge extends StatelessWidget {
  const _QuotaBadge({required this.icon, required this.color, required this.count});
  final IconData icon;
  final Color color;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _MiniSudokuHero extends StatefulWidget {
  const _MiniSudokuHero();

  @override
  State<_MiniSudokuHero> createState() => _MiniSudokuHeroState();
}

class _MiniSudokuHeroState extends State<_MiniSudokuHero> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -6 * _anim.value),
          child: child,
        );
      },
      child: Center(
        child: Container(
          width: 160,
          height: 160,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final val = [1, 5, 9, 3, 8, 2, 6, 7, 4][index];
              final isHighlighted = index == 4;
              return Container(
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.blue.shade100 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$val',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isHighlighted ? Colors.blue.shade800 : Colors.blue.shade300,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GameModes extends StatelessWidget {
  const _GameModes({required this.hasSavedGame, required this.ref});

  final bool hasSavedGame;
  final WidgetRef ref;

  void _startNewGame(BuildContext context, Difficulty difficulty) {
    ref.read(gameNotifierProvider.notifier).initNewGame(difficulty);
    context.go(AppRouter.gamePath);
  }

  void _showNewGameBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Difficulty',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...Difficulty.values.map((diff) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: Text(
                        diff.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: const Icon(Icons.play_arrow_rounded, color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      tileColor: Colors.grey.shade50,
                      onTap: () {
                        Navigator.pop(context);
                        _startNewGame(context, diff);
                      },
                    ),
                  );
                }),
              ],
            ),
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
          _GamifiedCard(
            title: 'RESUME GAME',
            subtitle: 'Continue your last puzzle',
            icon: Icons.play_circle_fill_rounded,
            colors: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            shadowColor: Colors.green.shade800,
            onTap: () {
              ref.read(gameNotifierProvider.notifier).loadSavedGame();
              context.go(AppRouter.gamePath);
            },
          ),
          const SizedBox(height: 20),
        ],
        _GamifiedCard(
          title: 'NEW GAME',
          subtitle: 'Start a fresh puzzle',
          icon: Icons.videogame_asset_rounded,
          colors: const [Color(0xFF2196F3), Color(0xFF1565C0)],
          shadowColor: Colors.blue.shade800,
          onTap: () => _showNewGameBottomSheet(context),
        ),
        const SizedBox(height: 32),
        // Secondary buttons
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                icon: Icons.design_services_rounded,
                label: 'Custom',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SecondaryButton(
                icon: Icons.vpn_key_rounded,
                label: 'Code',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SecondaryButton(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GamifiedCard extends StatelessWidget {
  const _GamifiedCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.shadowColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final Color shadowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        highlightColor: Colors.white.withValues(alpha: 0.2),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.grey.shade600, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'MungSudoku v1.0.0',
      style: TextStyle(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}
