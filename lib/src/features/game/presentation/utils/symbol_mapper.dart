import '../../domain/enums/symbol_type.dart';

/// Helper utility to convert internal integer values (1, 2, 3...) to visual
/// text symbols (e.g., "1", "2", "A", or "I", "II", "III").
abstract final class SymbolMapper {
  static String getCellSymbol(int? value, SymbolType type) {
    if (value == null || value == 0) return '';

    switch (type) {
      case SymbolType.standard:
        return _toStandard(value);
      case SymbolType.roman:
        return _toRoman(value);
    }
  }

  static String _toStandard(int value) {
    // For grids > 9 (like 16x16 or 25x25), values > 9 are
    // represented as letters to keep them single-character.
    if (value <= 9) return value.toString();
    // 10 becomes 'A' (ASCII 65)
    return String.fromCharCode(65 + (value - 10));
  }

  static String _toRoman(int value) {
    if (value <= 0 || value > 3999) return value.toString();
    const romanNumerals = {
      1000: 'M',
      900: 'CM',
      500: 'D',
      400: 'CD',
      100: 'C',
      90: 'XC',
      50: 'L',
      40: 'XL',
      10: 'X',
      9: 'IX',
      5: 'V',
      4: 'IV',
      1: 'I',
    };

    var result = '';
    var num = value;
    for (final entry in romanNumerals.entries) {
      while (num >= entry.key) {
        result += entry.value;
        num -= entry.key;
      }
    }
    return result;
  }
}
