import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/symbol_type.dart';

class GameSetupDialog extends ConsumerStatefulWidget {
  const GameSetupDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const GameSetupDialog(),
    );
  }

  @override
  ConsumerState<GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends ConsumerState<GameSetupDialog> {
  Difficulty _difficulty = Difficulty.easy;
  int _subGridSize = 3;
  SymbolType _symbolType = SymbolType.standard;
  bool _isLoading = false;

  void _startGame() async {
    setState(() => _isLoading = true);
    // Give UI time to show loading spinner
    await Future.delayed(const Duration(milliseconds: 50)); 
    
    await ref.read(gameNotifierProvider.notifier).initNewGame(
      _difficulty,
      subGridSize: _subGridSize,
      symbolType: _symbolType,
    );
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Setup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<Difficulty>(
              value: _difficulty,
              isExpanded: true,
              items: Difficulty.values.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.displayName),
                );
              }).toList(),
              onChanged: (v) => setState(() => _difficulty = v!),
            ),
            const SizedBox(height: 16),
            
            const Text('Grid Size', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _subGridSize,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 2, child: Text('2x2 (4x4 Board)')),
                DropdownMenuItem(value: 3, child: Text('3x3 (9x9 Standard)')),
                DropdownMenuItem(value: 4, child: Text('4x4 (16x16 Mega)')),
                DropdownMenuItem(value: 5, child: Text('5x5 (25x25 Ultra)')),
              ],
              onChanged: (v) => setState(() => _subGridSize = v!),
            ),
            const SizedBox(height: 16),

            const Text('Symbol Type', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<SymbolType>(
              value: _symbolType,
              isExpanded: true,
              items: SymbolType.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.displayName),
                );
              }).toList(),
              onChanged: (v) => setState(() => _symbolType = v!),
            ),
          ],
        ),
      ),
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          FilledButton(
            onPressed: _startGame,
            child: const Text('Start Game'),
          ),
      ],
    );
  }
}
