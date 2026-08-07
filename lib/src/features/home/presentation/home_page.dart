import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/router/app_router.dart';
import '../../game/application/game_notifier.dart';
import '../../game/application/game_state.dart';
import '../../game/domain/enums/difficulty.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _hasSavedGame = false;
  String _savedGameSubtitle = 'Saved Game';

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('current_game')) {
      final savedData = prefs.getString('current_game');
      if (savedData != null) {
        try {
          final json = jsonDecode(savedData);
          final state = GameState.fromJson(json);
          final diffName = state.difficulty.displayName;
          final duration = state.gameDuration;
          String twoDigits(int n) => n.toString().padLeft(2, "0");
          String minutes = twoDigits(duration.inMinutes.remainder(60));
          String seconds = twoDigits(duration.inSeconds.remainder(60));
          String time = duration.inHours > 0 
            ? '${duration.inHours}:$minutes:$seconds' 
            : '$minutes:$seconds';

          setState(() {
            _hasSavedGame = true;
            _savedGameSubtitle = '$diffName • $time';
          });
          return;
        } catch (e) {
          // Fallback if parsing fails
        }
      }
      setState(() => _hasSavedGame = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo
              Center(
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  height: 160,
                  width: 160,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Menu Buttons
              if (_hasSavedGame) ...[
                _OutlinedPillButton(
                  label: 'Continue',
                  subLabel: _savedGameSubtitle,
                  onTap: () {
                    ref.read(gameNotifierProvider.notifier).loadSavedGame();
                    context.go(AppRouter.gamePath);
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              _FilledPillButton(
                label: 'New Game',
                onTap: () => _showNewGameBottomSheet(context),
              ),
              
              const Spacer(flex: 4),
              
              // Bottom Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionItem(
                    iconPath: 'assets/person.svg',
                    label: 'me',
                    onTap: () {},
                  ),
                  _ActionItem(
                    iconPath: 'assets/create.svg',
                    label: 'create',
                    onTap: () {
                      context.push(AppRouter.customSudokuListPath);
                    },
                  ),
                  _ActionItem(
                    iconPath: 'assets/shop.svg',
                    label: 'shop',
                    onTap: () => context.push(AppRouter.shopPath),
                  ),
                  _ActionItem(
                    iconPath: 'assets/setting.svg',
                    label: 'settings',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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
                      trailing: const Icon(Icons.play_arrow_rounded, color: Color(0xFF0092DF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      tileColor: Colors.grey.shade50,
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(gameNotifierProvider.notifier).initNewGame(diff);
                        context.go(AppRouter.gamePath);
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
}

class _OutlinedPillButton extends StatelessWidget {
  const _OutlinedPillButton({
    required this.label,
    required this.subLabel,
    required this.onTap,
  });

  final String label;
  final String subLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xFF0092DF), width: 2),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0092DF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: const TextStyle(
                  color: Color(0xFF5A5A5A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilledPillButton extends StatelessWidget {
  const _FilledPillButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0092DF),
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF0578B3),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 28,
              height: 28,
              colorFilter: const ColorFilter.mode(Color(0xFF0092DF), BlendMode.srcIn),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5A5A5A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
