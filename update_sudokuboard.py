import re

def update_sudokuboard():
    path = "lib/src/features/game/domain/entities/sudoku_board.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Constructor
    content = content.replace(
        """  SudokuBoard({
    required List<List<SudokuCell>> cells,
    this.subGridSize = 3,
    required this.rowNumbers,
    required this.colNumbers,
    required this.subGridNumbers,
  })""",
        """  SudokuBoard({
    required List<List<SudokuCell>> cells,
    this.subGridSize = 3,
    required this.rowNumbers,
    required this.colNumbers,
    required this.subGridNumbers,
    this.id,
    this.createdAt,
  })"""
    )

    # 2. Fields
    content = content.replace(
        """  final Map<int, Set<int>> subGridNumbers;

  // --- Derived dimensions ---""",
        """  final Map<int, Set<int>> subGridNumbers;

  /// Unique identifier for this specific puzzle (especially custom puzzles).
  final String? id;

  /// The timestamp when this puzzle was created.
  final DateTime? createdAt;

  // --- Derived dimensions ---"""
    )

    # 3. reset()
    content = content.replace(
        """    return SudokuBoard(
      cells: newCells,
      subGridSize: subGridSize,
      rowNumbers: rowNums,
      colNumbers: colNums,
      subGridNumbers: sgNums,
    );
  }""",
        """    return SudokuBoard(
      cells: newCells,
      subGridSize: subGridSize,
      rowNumbers: rowNums,
      colNumbers: colNums,
      subGridNumbers: sgNums,
      id: id,
      createdAt: createdAt,
    );
  }""", 1
    )

    # 4. updateCell()
    content = content.replace(
        """    return SudokuBoard(
      cells: newCells,
      subGridSize: subGridSize,
      rowNumbers: newRowNums,
      colNumbers: newColNums,
      subGridNumbers: newSgNums,
    );
  }""",
        """    return SudokuBoard(
      cells: newCells,
      subGridSize: subGridSize,
      rowNumbers: newRowNums,
      colNumbers: newColNums,
      subGridNumbers: newSgNums,
      id: id,
      createdAt: createdAt,
    );
  }""", 1 # The second occurrence is updateCell
    )
    
    # 5. copyWith
    content = content.replace(
        """  SudokuBoard copyWith({
    List<List<SudokuCell>>? cells,
    int? subGridSize,
    Map<int, Set<int>>? rowNumbers,
    Map<int, Set<int>>? colNumbers,
    Map<int, Set<int>>? subGridNumbers,
  }) =>
      SudokuBoard(
        cells: cells ?? this.cells,
        subGridSize: subGridSize ?? this.subGridSize,
        rowNumbers: rowNumbers ?? this.rowNumbers,
        colNumbers: colNumbers ?? this.colNumbers,
        subGridNumbers: subGridNumbers ?? this.subGridNumbers,
      );""",
        """  SudokuBoard copyWith({
    List<List<SudokuCell>>? cells,
    int? subGridSize,
    Map<int, Set<int>>? rowNumbers,
    Map<int, Set<int>>? colNumbers,
    Map<int, Set<int>>? subGridNumbers,
    String? id,
    DateTime? createdAt,
  }) =>
      SudokuBoard(
        cells: cells ?? this.cells,
        subGridSize: subGridSize ?? this.subGridSize,
        rowNumbers: rowNumbers ?? this.rowNumbers,
        colNumbers: colNumbers ?? this.colNumbers,
        subGridNumbers: subGridNumbers ?? this.subGridNumbers,
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
      );"""
    )
    
    # 6. toJson
    content = content.replace(
        """  Map<String, dynamic> toJson() => {
        'subGridSize': subGridSize,
        'cells': cells.expand((row) => row).map((c) => c.toJson()).toList(),
      };""",
        """  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt?.toIso8601String(),
        'subGridSize': subGridSize,
        'cells': cells.expand((row) => row).map((c) => c.toJson()).toList(),
      };"""
    )
    
    # 7. fromJson
    content = content.replace(
        """  factory SudokuBoard.fromJson(Map<String, dynamic> json) {""",
        """  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null;"""
    )
    
    content = content.replace(
        """    return SudokuBoard(
      subGridSize: subGridSize,
      cells: grid,
      rowNumbers: Map.unmodifiable(rowNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      colNumbers: Map.unmodifiable(colNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      subGridNumbers: Map.unmodifiable(sgNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
    );
  }""",
        """    return SudokuBoard(
      subGridSize: subGridSize,
      cells: grid,
      rowNumbers: Map.unmodifiable(rowNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      colNumbers: Map.unmodifiable(colNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      subGridNumbers: Map.unmodifiable(sgNums.map((k, v) => MapEntry(k, Set.unmodifiable(v)))),
      id: id,
      createdAt: createdAt,
    );
  }"""
    )

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

update_sudokuboard()
