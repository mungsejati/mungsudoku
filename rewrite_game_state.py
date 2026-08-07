import re

with open('lib/src/features/game/application/game_state.dart', 'r') as f:
    content = f.read()

content = content.replace("import '../domain/enums/difficulty.dart';", "import '../domain/enums/difficulty.dart';\nimport '../domain/entities/board_config.dart';")
content = content.replace("required this.selectedSubGridSize,", "required this.selectedBoardConfig,")
content = content.replace("final int selectedSubGridSize;", "final BoardConfig selectedBoardConfig;")
content = content.replace("selectedSubGridSize: 3,", "selectedBoardConfig: BoardConfig.standard,")
content = content.replace("int? selectedSubGridSize,", "BoardConfig? selectedBoardConfig,")
content = content.replace("selectedSubGridSize: selectedSubGridSize ?? this.selectedSubGridSize,", "selectedBoardConfig: selectedBoardConfig ?? this.selectedBoardConfig,")
content = content.replace("'selectedSubGridSize': selectedSubGridSize,", "'selectedBoardConfig': {'r': selectedBoardConfig.subGridRows, 'c': selectedBoardConfig.subGridCols},")

# For fromJson, we need to handle old int selectedSubGridSize and new map selectedBoardConfig.
from_json_old = "selectedSubGridSize: json['selectedSubGridSize'] as int,"
from_json_new = """selectedBoardConfig: json['selectedBoardConfig'] is Map 
          ? BoardConfig(
              subGridRows: json['selectedBoardConfig']['r'] as int,
              subGridCols: json['selectedBoardConfig']['c'] as int,
            )
          : BoardConfig(
              subGridRows: json['selectedSubGridSize'] as int? ?? 3,
              subGridCols: json['selectedSubGridSize'] as int? ?? 3,
            ),"""
content = content.replace(from_json_old, from_json_new)

with open('lib/src/features/game/application/game_state.dart', 'w') as f:
    f.write(content)
