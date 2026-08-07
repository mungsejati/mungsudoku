import re

with open('lib/src/features/game/presentation/widgets/sudoku_board_widget.dart', 'r') as f:
    content = f.read()

content = content.replace("divisions: s,", "rows: sRows, cols: sCols,")
content = content.replace("required this.divisions", "required this.rows, required this.cols")
content = content.replace("final int divisions;", "final int rows;\n  final int cols;")

painter_body = """    for (var i = 1; i < divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      _dash(
        canvas,
        paint,
        Offset(x, 0),
        Offset(x, size.height),
        dashLen,
        gapLen,
      );
      _dash(
        canvas,
        paint,
        Offset(0, y),
        Offset(size.width, y),
        dashLen,
        gapLen,
      );
    }"""

new_painter_body = """    for (var i = 1; i < cols; i++) {
      final x = size.width * i / cols;
      _dash(
        canvas,
        paint,
        Offset(x, 0),
        Offset(x, size.height),
        dashLen,
        gapLen,
      );
    }
    for (var i = 1; i < rows; i++) {
      final y = size.height * i / rows;
      _dash(
        canvas,
        paint,
        Offset(0, y),
        Offset(size.width, y),
        dashLen,
        gapLen,
      );
    }"""
content = content.replace(painter_body, new_painter_body)
content = content.replace("old.divisions != divisions;", "old.rows != rows || old.cols != cols;")

with open('lib/src/features/game/presentation/widgets/sudoku_board_widget.dart', 'w') as f:
    f.write(content)
