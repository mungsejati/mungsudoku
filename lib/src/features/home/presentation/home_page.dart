import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop =
            await _showExitConfirmationDialog(context) ?? false;
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Center(child: ThemedLogo(size: 160)),

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
                      onTap: () => context.push(AppRouter.profilePath),
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
                      onTap: () => context.push(AppRouter.settingsPath),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Keluar dari MungSudoku?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A5A5A),
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari aplikasi?',
            style: TextStyle(color: Color(0xFF5A5A5A)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Game',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A5A5A),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: Difficulty.values.map((diff) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            title: Text(
                              diff.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF5A5A5A),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF5A5A5A),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            tileColor: Colors.grey.shade50,
                            onTap: () {
                              Navigator.pop(context);
                              ref
                                  .read(gameNotifierProvider.notifier)
                                  .initNewGame(diff);
                              context.go(AppRouter.gamePath);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
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
            color: Colors.white, // Solid white so shadow doesn't bleed through
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
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
  const _FilledPillButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    // For #5A5A5A, a lerp of 0.31 yields approx #3e3e3e. We'll use exactly #3e3e3e if it's #5a5a5a
    final shadowColor = primaryColor == const Color(0xFF5A5A5A)
        ? const Color(0xFF3E3E3E)
        : Color.lerp(primaryColor, Colors.black, 0.2) ?? Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
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
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
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

class ThemedLogo extends StatelessWidget {
  final double size;

  const ThemedLogo({super.key, required this.size});

  String _colorToHex(Color color) {
    final r = (color.r * 255).toInt().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).toInt().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).toInt().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    // Create a darker shade for the shadow slice (similar to what we did for the button)
    final shadowColor =
        Color.lerp(primaryColor, Colors.black, 0.2) ?? Colors.black;

    final primaryHex = _colorToHex(primaryColor);
    final shadowHex = _colorToHex(shadowColor);

    final String coloredSvg = _rawLogoSvg
        .replaceAll('#0092DF', primaryHex)
        .replaceAll('#0578B3', shadowHex);

    return SvgPicture.string(coloredSvg, width: size, height: size);
  }
}

const String _rawLogoSvg = '''
<svg width="321" height="321" viewBox="0 0 321 321" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="160.5" cy="160.5" r="160.5" fill="#0092DF"/>
<path d="M296.752 75.6724C315.13 105.193 323.425 139.883 320.386 174.524C317.348 209.165 303.141 241.882 279.903 267.752C256.666 293.622 225.655 311.246 191.538 317.97C157.42 324.695 122.042 320.157 90.7258 305.04L160.5 160.5L296.752 75.6724Z" fill="#0578B3"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 131 79)" fill="white"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 243 79)" fill="white"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 187 79)" fill="white"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 131 135)" fill="white"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 243 135)" fill="white"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 187 135)" fill="white"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 131 191)" fill="white"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 243 191)" fill="white"/>
<rect width="52" height="52" rx="12" transform="matrix(-1 0 0 1 187 191)" fill="white"/>
<circle cx="161" cy="105" r="15" fill="#0092DF"/>
<circle cx="217" cy="105" r="15" fill="#0092DF"/>
<circle cx="161" cy="161" r="15" fill="#0092DF"/>
<circle cx="161" cy="217" r="15" fill="#0092DF"/>
<circle cx="105" cy="217" r="15" fill="#0092DF"/>
</svg>
''';
