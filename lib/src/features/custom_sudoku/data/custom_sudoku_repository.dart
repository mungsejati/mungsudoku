import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../game/domain/entities/sudoku_board.dart';

final customSudokuRepositoryProvider = Provider<CustomSudokuRepository>((ref) {
  return CustomSudokuRepository();
});

/// Handles local persistence of custom Sudoku boards.
class CustomSudokuRepository {
  static const String _storageKey = 'mung_sudoku_custom_boards';

  /// Saves a new custom board to the list of saved boards.
  Future<void> saveCustomPuzzle(SudokuBoard board) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentSaved = prefs.getStringList(_storageKey) ?? [];
    
    // Add the new board at the beginning of the list
    currentSaved.insert(0, jsonEncode(board.toJson()));
    
    await prefs.setStringList(_storageKey, currentSaved);
  }

  /// Retrieves the list of all saved custom boards.
  Future<List<SudokuBoard>> getCustomPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentSaved = prefs.getStringList(_storageKey) ?? [];
    
    final List<SudokuBoard> boards = [];
    for (final boardStr in currentSaved) {
      try {
        final Map<String, dynamic> json = jsonDecode(boardStr);
        boards.add(SudokuBoard.fromJson(json));
      } catch (e) {
        // Skip corrupted entries
      }
    }
    
    return boards;
  }
}
