import '../domain/enums/difficulty.dart';

/// Arguments passed to GameResultPage.
class GameResultArgs {
  final bool isVictory;
  final Difficulty difficulty;
  final Duration time;
  final int mistakes;
  final int maxMistakes;

  const GameResultArgs({
    required this.isVictory,
    required this.difficulty,
    required this.time,
    required this.mistakes,
    required this.maxMistakes,
  });
}
