import 'dart:math';

final Random _random = Random();
  List<int> _rotate90(List<int> grid, int size) {
    final result = List.filled(size * size, 0);
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        result[c * size + (size - 1 - r)] = grid[r * size + c];
      }
    }
    return result;
  }

  List<int> _transformSeed(List<int> seed, int size) {
    List<int> result = List.from(seed);
    
    // 1. Permute values (1-9 mapped to a random permutation)
    final values = List.generate(size, (i) => i + 1)..shuffle(_random);
    final map = <int, int>{};
    for (int i = 0; i < size; i++) {
      map[i + 1] = values[i];
    }
    
    for (int i = 0; i < result.length; i++) {
      if (result[i] != 0) {
        result[i] = map[result[i]]!;
      }
    }
    
    // 2. Rotate grid randomly (0, 90, 180, 270 degrees)
    int rotations = 1; // force 1 rotation to test
    for (int i = 0; i < rotations; i++) {
      result = _rotate90(result, size);
    }
    
    return result;
  }

void main() {
  final seedStr = '000000010400000000020000000000050407008000300001090000300400200050100000000806000';
  final seed = seedStr.split('').map(int.parse).toList();
  final t = _transformSeed(seed, 9);
  print('Original: ${seed.where((e) => e != 0).length}');
  print('Transformed: ${t.where((e) => e != 0).length}');
}
