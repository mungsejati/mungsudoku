import re

with open('lib/src/features/game/presentation/widgets/game_setup_dialog.dart', 'r') as f:
    content = f.read()

# Remove _subGridSize = 3;
content = re.sub(r"\s*int _subGridSize = 3;\n", "\n", content)

# Remove subGridSize: _subGridSize,
content = re.sub(r"\s*subGridSize: _subGridSize,\n", "\n", content)

# Remove the DropdownButton for Grid Size
dropdown_str = """            const Text('Grid Size', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 16),"""

content = content.replace(dropdown_str, "")

with open('lib/src/features/game/presentation/widgets/game_setup_dialog.dart', 'w') as f:
    f.write(content)

