# MungSudoku Project Summary

## `.agent` Directory
Folder ini berisi konfigurasi, instruksi, agen, aturan, dan keterampilan yang digunakan oleh sistem AI (Antigravity/Agentic Framework) untuk membantu pengembangan proyek ini.

### 📜 Instruksi Dasar
- **`instruction.md`**: Instruksi wajib bagi agen AI untuk membaca PRD dan SCOPE sebelum menulis kode.

### 🤖 Agen (Agents)
Agen adalah persona spesialis AI yang memiliki tugas dan fokus tertentu:
- **`agents/code-archaeologist.md`**: Ahli dalam *legacy code* Dart/Flutter, bertugas melakukan refactoring dan mengurangi technical debt.
- **`agents/debugger.md`**: Spesialis perbaikan bug yang sistematis, investigasi crash, dan analisis akar masalah.
- **`agents/documentation-writer.md`**: Ahli menulis dokumentasi Dart/Flutter yang rapi, sesuai standar Pub.dev dan memprioritaskan *Developer Experience*.
- **`agents/explorer-agent.md`**: Spesialis penemuan *codebase*, analisis arsitektur, dan riset secara proaktif.
- **`agents/mobile-developer.md`**: Ahli pengembangan aplikasi *mobile* Flutter & Dart dengan fokus pada arsitektur yang kuat dan performa tinggi (60/120fps).
- **`agents/orchestrator.md`**: Koordinator multi-agen untuk framework Antigravity yang mengatur pendelegasian tugas ke agen lain.
- **`agents/penetration-tester.md`**: Spesialis keamanan ofensif *mobile*, verifikasi standar MASVS, dan simulasi operasi *red team*.
- **`agents/performance-optimizer.md`**: Ahli optimasi performa Flutter, bertugas menghilangkan *Jank* dan mengurangi ukuran aplikasi.
- **`agents/product-manager.md`**: Ahli kebutuhan produk *mobile*, *user stories*, dan kepatuhan standar rilis App Store.
- **`agents/project-planner.md`**: Agen perencana proyek yang cerdas untuk mengatur struktur tugas Flutter.
- **`agents/qa-automation-engineer.md`**: Spesialis pengujian otomatisasi (*Integration Testing*, Patrol) dan *device farm pipelines*.
- **`agents/security-auditor.md`**: Ahli keamanan siber *mobile* level elit yang mendeteksi kerentanan penyimpanan data dan otorisasi.
- **`agents/test-engineer.md`**: Ahli strategi pengujian Flutter yang berpusat pada *Test-Driven Development* (TDD) dengan fokus kecepatan dan isolasi.

### 📂 Proyek (Project)
Menyimpan dokumen perencanaan dan cakupan (scope) produk:
- **`project/PRD.md`**: Product Requirements Document; menjelaskan bahwa tujuan proyek adalah membuat game Sudoku modern dan fleksibel dengan kustomisasi tanpa batas.
- **`project/SCOPE.md`**: Dokumen batasan tahap pengembangan; fokus saat ini adalah membangun *Classic 9x9 Engine* yang solid, offline, dengan fitur seperti *Timer*, *Pause/Resume*, dan *Puzzle Generator*.

### 📏 Aturan (Rules)
Berisi standar penulisan kode yang secara otomatis aktif (always_on) selama pengembangan:
- **`rules/architecture.md`**: Standar arsitektur Flutter berbasis *Clean Architecture* dan pemisahan lapisan (layers).
- **`rules/dart_standards.md`**: Aturan penulisan kode Dart bersih (*Clean Code*).
- **`rules/flutter_standards.md`**: Praktik terbaik spesifik untuk kerangka kerja Flutter.
- **`rules/routing.md`**: Panduan sistem navigasi dan perutean (routing) aplikasi.
- **`rules/state_management.md`**: Standar pengelolaan state aplikasi menggunakan pola *ValueNotifier-based controllers*.

### 🛠 Keterampilan (Skills)
Kemampuan dan alur kerja (workflow) spesifik yang bisa dimanfaatkan oleh agen:
- **`skills/app-builder/SKILL.md`**: Aturan *scaffolding* dan pembangunan struktur awal aplikasi Flutter.
- **`skills/architecture/SKILL.md`**: Panduan merancang aplikasi agar memiliki pengikatan yang rendah (*low coupling*) dan mudah diuji (*high testability*).
- **`skills/behavioral-modes/SKILL.md`**: Berbagai mode operasional AI (seperti *brainstorm*, *implement*, *debug*, dll) dan cara AI bereaksi di masing-masing mode.
- **`skills/brainstorming/SKILL.md`**: Protokol pertanyaan sokratik untuk menggali masalah, target pengguna, dan cakupan fitur secara dinamis (didukung oleh **`dynamic-questioning.md`**).
- **`skills/clean-code/SKILL.md`**: Aturan *Clean Code* seperti memprioritaskan keterbacaan, prinsip tanggung jawab tunggal (SRP), dan meminimalkan kompleksitas.
- **`skills/documentation-templates/SKILL.md`**: Panduan struktur dan templat penulisan dokumentasi.
- **`skills/parallel-agents/SKILL.md`**: Pola pengaturan dan orkestrasi beberapa agen yang bekerja beriringan.
- **`skills/performance-profiling/SKILL.md`**: Prinsip pengukuran dan perbaikan kinerja aplikasi (profiling).
- **`skills/plan-writing/SKILL.md`**: Panduan memecah tugas secara terstruktur (2-5 menit per tugas) dengan hasil yang dapat diverifikasi secara mandiri.
- **`skills/skill-creator/SKILL.md`**: Panduan dan format tentang bagaimana membuat *skill* agen AI yang baru (membutuhkan file YAML dan Markdown).
- **`skills/state-management/SKILL.md`**: Prinsip *state management* (state harus eksplisit, terprediksi, dan terpusat di lokal) yang dilengkapi dengan contoh penerapan di **`examples/examples.md`**.
- **`skills/tdd-workflow/SKILL.md`**: Alur kerja metodologi TDD (Pastikan tes gagal dulu, tulis nama tes deskriptif, dan satu asersi per tes).
- **`skills/testing-patterns/SKILL.md`**: Pola dan fungsi penting dalam menulis tes (seperti `find.text`, `find.byType`, dll).
- **`skills/vulnerability-scanner/SKILL.md`**: Prinsip analisis kerentanan tingkat lanjut yang meliputi *Reverse Engineering*, masalah *Root/Jailbreak*, dan mitigasi (dibantu panduan pemeriksaan keamanan cepat di **`checklists.md`**).

### 🔄 Alur Kerja (Workflows)
Panduan bertahap (step-by-step) untuk mempermudah pembuatan komponen:
- **`workflows/create_entity_model.md`**: Panduan men-generate Domain Entity dan Data Model lengkap dengan konvensi penamaan (`PascalCase` vs `snake_case`).
- **`workflows/create_feature.md`**: Panduan membuat fitur baru dengan struktur View, Controller, dan State sesuai standar arsitektur proyek.

## `lib` Directory
Folder ini berisi seluruh *source code* (kode sumber) dari aplikasi MungSudoku. Berikut adalah penjabaran file dan fungsinya:

### 📄 `lib/main.dart`
- **Class/Widget `MungSudokuApp`**: Root widget of the MungSudoku application.  [ProviderScope] is the outermost widget, ensuring all Riverpod providers are accessible throughout the entire widget tree.

### 📄 `lib/src/core/theme/app_theme.dart`
- *Mengatur tema utama aplikasi (Material 3), termasuk skema warna dasar, font, dan elemen antarmuka standar.*

### 📄 `lib/src/core/theme/game_theme.dart`
- **Class/Widget `GameTheme`**: Defines the visual style of the Sudoku game board and its surrounding UI.  All colors and dimensions that make up the board's look-and-feel are collected here so they can be swapped in one place without touching individual widget code.

### 📄 `lib/src/core/router/app_router.dart`
- *Konfigurasi routing navigasi layar dalam aplikasi menggunakan `go_router`.*

### 📄 `lib/src/features/home/presentation/home_page.dart`
- **Class/Widget `HomePage`**: Halaman utama aplikasi (Main Menu) yang kini mengusung gaya desain *Clean & Minimalist*. Berisi logo, tombol navigasi permainan, dan baris aksi (action row) dengan palet dasar biru `#0092DF`.
- **Class/Widget `_HomePageState`**: Mengelola state awal dari halaman utama (termasuk mendeteksi adanya *save game*).
- **Class/Widget `_OutlinedPillButton`**: Desain tombol sekunder/lanjutan (seperti tombol "Continue") berbentuk kapsul dengan garis batas tepi berwarna biru `#0092DF`. Menampilkan teks dinamis sisa waktu dan tingkat kesulitan (contoh: "Medium • 02:30").
- **Class/Widget `_FilledPillButton`**: Desain tombol utama (seperti tombol "New Game") berbentuk kapsul dengan warna latar biru tebal dan *drop shadow*.
- **Class/Widget `_ActionItem`**: Ikon beserta label (me, create, shop, settings) yang diletakkan berjejer di bagian bawah layar menggunakan dukungan `flutter_svg`.



### 📄 `lib/src/features/custom_sudoku/application/custom_sudoku_list_notifier.dart`
- **Class/Widget `CustomSudokuListNotifier`**: Bertugas mengambil dan memperbarui daftar puzzle kustom dari penyimpanan lokal untuk ditampilkan di list.

### 📄 `lib/src/features/custom_sudoku/application/custom_sudoku_notifier.dart`
- **Class/Widget `CustomSudokuNotifier`**: State notifier spesifik yang menangani logika pembuatan (editor) puzzle kustom, seperti pergerakan kursor otomatis dan validasi sel.
  - `function inputNumber()`: Inputs a value (1-9) or clears (0) at the currently selected cell
  - `function validateAndPreparePlay()`: Validates if the board has exactly one unique solution
  - `function getSolvedGrid()`: Returns the fully solved grid as a flat list if valid, otherwise null.

### 📄 `lib/src/features/custom_sudoku/application/custom_sudoku_state.dart`
- **Class/Widget `CustomSudokuState`**: Menyimpan kondisi terkini editor puzzle, seperti sel mana yang sedang aktif disorot (selected) dan status validasinya.

### 📄 `lib/src/features/custom_sudoku/data/custom_sudoku_repository.dart`
- **Class/Widget `CustomSudokuRepository`**: Handles local persistence of custom Sudoku boards.
  - `function saveCustomPuzzle()`: Saves a new custom board to the list of saved boards.
  - `function getCustomPuzzles()`: Retrieves the list of all saved custom boards.

### 📄 `lib/src/features/custom_sudoku/presentation/custom_sudoku_list_page.dart`
- **Class/Widget `CustomSudokuListPage`**: Layar _List_ untuk menampilkan puzzle hasil buatan sendiri (Custom Sudoku). Layar ini kini dirombak mengikuti _Clean Architecture_ dan bergaya dinamis (merespons warna latar _primaryColor_ tema aktif). Dilengkapi AppBar dengan fungsi tema (`assets/theme.svg`) dan tombol *+ Create New* (pengganti *FloatingActionButton*) di area atas.
- **Class/Widget `_CustomSudokuCard`**: Desain kartu list kini berbentuk _Pill / Rounded_ dengan _bottom drop shadow_ tebal dan latar putih. Berisi informasi tanggal (dihiasi aset `calendar.svg`), judul kode kustom puzzle, fungsi Hapus (`Delete`), fungsi Eksekusi Main (`Play`), serta fitur berbagi (Share). Fungsi _Share_ menggunakan modal yang memfasilitasi _Copy Code_ ke papan klip (menggunakan `flutter/services.dart` - `Clipboard`) dan rintisan pembagian _Share Link_ ke eksternal.

### 📄 `lib/src/features/custom_sudoku/presentation/custom_sudoku_page.dart`
- **Class/Widget `CustomSudokuPage`**: Halaman editor (kanvas) untuk menyusun teka-teki Sudoku buatan sendiri dengan *numpad* 2-baris.
- **Class/Widget `_CustomSudokuBoardWidget`**: Wadah papan (grid) khusus untuk layar pembuatan puzzle.
- **Class/Widget `_CustomNumpad`**: Komponen tata letak tombol angka yang dirancang lebih padat khusus untuk editor.
- **Class/Widget `_NumpadButton`**: Tombol individual angka/X pada _CustomNumpad.

### 📄 `lib/src/features/game/application/game_notifier.dart`
- **Class/Widget `GameNotifier`**: Riverpod [Notifier] that owns the complete lifecycle of a Sudoku session.  ## Responsibilities  - Starting and managing a new game session via [initNewGame]. - Routing player input for both Standard Mode (Method A) and Fast Mode (Method B) via [selectCell], [activateValue], and [inputNumber]. - Maintaining the undo/redo board-snapshot stack. - Managing hint quota and triggering the mock ad prompt. - Running the per-second game timer. - Triggering local auto-save after every state mutation (mock in Phase 1).  ## Input Modes  | Mode     | Flow                                                            | |----------|-----------------------------------------------------------------| | Standard | `selectCell(r,c)` → player taps numpad → `inputNumber(r,c,v)` | | Fast     | `activateValue(v)` (long-press) → player taps cells           |  The notifier is mode-agnostic: the UI drives behaviour by calling the appropriate selection method before [inputNumber].  ## Auto-Save (Mock)  [_autoSave] is called after every mutation. In Phase 1 it only logs. In Phase 3, replace it with a Hive write + Supabase sync.
  - `function initNewGame()`: Initialises a new puzzle at the given [difficulty] and starts the timer.  Puzzle generation is offloaded to a separate isolate via [compute] so that the UI thread is never blocked (backtracking can take several ms).
  - `function initCustomGame()`: Initializes a custom game session with a pre-built board.
  - `function restartPuzzle()`: Restarts the current puzzle from the beginning without generating a new one.
  - `function pauseGame()`: Pauses the game: stops the timer. Board is hidden in the UI.
  - `function resumeGame()`: Resumes a paused game: restarts the timer.
  - `function selectCell()`: Selects a cell for Standard Input Mode (Method A).  Tapping the same cell again deselects it.
  - `function activateValue()`: Activates (or deactivates) a numpad digit for Fast Input Mode (Method B).  While a value is active, tapping any editable cell writes it immediately. Activating the same value again deactivates Fast Mode.
  - `function inputNumber()`: Places [value] in the cell at ([row], [col]).  Supports both input modes — the UI decides which cell and value to pass based on the active selection state.  **Note mode:** writes [value] as a pencil mark (toggled). **Fill mode:** writes [value] as the definitive answer, clears notes, pushes the previous board onto [GameState.undoStack], and clears [GameState.redoStack].  After every input, conflict detection is re-run and the board is checked for victory. Auto-save is triggered.
  - `function clearCell()`: Clears the value (and notes) from the cell at ([row], [col]).  Does nothing if the cell is original or already empty.
  - `function toggleNoteMode()`: Toggles pencil/notes input mode on or off.
  - `function fastFillNotes()`: Auto-fills all empty editable cells with their valid note candidates.  For each empty cell, every digit that does not already appear in the same row, column, or sub-grid is inserted as a pencil mark. Existing notes and filled cells are left untouched.
  - `function useHint()`: Fills the currently selected cell with its [SudokuCell.solutionValue].  **Preconditions (all must pass):** - A cell is selected ([GameState.hasSelection] == `true`). - The selected cell is editable and not already correct. - [GameState.remainingHints] > 0.  When hints run out, the ad-prompt mock is triggered instead. Hint usage is recorded in the undo stack so it can be undone.
  - `function undo()`: Reverts the board to the state before the last player action.
  - `function redo()`: Re-applies the last undone action.
  - `function _applyBoardUpdate()`: Pushes [updatedBoard] as the new game state, updating conflicts, undo stack, redo stack, and checking for victory. Triggers auto-save.
  - `function _clearSave()`: Clears the saved game state from local storage.
  - `function _autoSave()`: Persists the current game state to local storage.
  - `function loadSavedGame()`: Loads the saved game state from local storage.
  - `function _generatePuzzle()`: Top-level free function required by [compute].  Must NOT be a lambda or an instance method — [compute] serialises the function reference to pass it to a background isolate.

### 📄 `lib/src/features/game/application/game_state.dart`
- **Class/Widget `GameState`**: Immutable snapshot of all game-related state for a single Sudoku session.  [GameNotifier] produces a new [GameState] for every state transition. Riverpod rebuilds only the widgets that depend on the parts of [GameState] that have actually changed.  ## Undo / Redo Stack  [undoStack] contains previous [SudokuBoard] snapshots in chronological order (oldest at index 0, most recent at the end). [redoStack] holds boards that were undone and can be re-applied. Any new player input clears [redoStack] entirely.  ## Input Modes  | Mode     | Selection fields used                    | |----------|------------------------------------------| | Standard | [selectedRow] + [selectedCol]            | | Fast     | [activeValue] (held numpad digit)        |  Both modes call [GameNotifier.inputNumber] — the difference is only in which fields are set before the call.
  - `function initial()`: Creates the default state before any game has been loaded.
  - `function copyWith()`: Returns a new [GameState] with only the specified fields replaced.  Use the `clear*` boolean flags to explicitly set nullable fields to `null` (passing `null` for a nullable field means "no change").

### 📄 `lib/src/features/game/data/services/sudoku_generator.dart`
- **Function `generate()`**: Returns a fully initialised [SudokuBoard] at the requested [difficulty] and [subGridSize].
- **Function `hasUniqueSolution()`**: Checks if the given grid has exactly one unique solution.
- **Function `solveGrid()`**: Attempts to solve the grid and returns the flat 1D solution list. Returns null if no solution exists.

### 📄 `lib/src/features/game/domain/enums/difficulty.dart`
- **Class/Widget `Difficulty`**: Defines the available difficulty levels for a Sudoku puzzle.  [givenCellCount] represents the number of pre-filled cells on a standard 9x9 board. The minimum for a uniquely-solvable puzzle is 17 (Hard).
  - `function switch()`: Number of pre-filled (given) cells for a standard 9x9 board.

### 📄 `lib/src/features/game/domain/enums/symbol_type.dart`
- **Class/Widget `SymbolType`**: Defines the visual representation of numbers on the Sudoku board.

### 📄 `lib/src/features/game/domain/services/sudoku_validator.dart`
- **Function `findConflicts()`**: Returns the set of `(row, col)` positions whose current values violate at least one Sudoku constraint (row, column, or sub-grid).  Empty cells are never included in the result.
- **Function `isValidPlacement()`**: Returns `true` if placing [value] at ([row], [col]) would **not** violate any Sudoku constraint.  The cell at ([row], [col]) is excluded from the check, making this safe to call when the cell already contains a value being replaced.  Used internally by the generator to validate each placement during backtracking.
- **Function `findConflictPositionsForValue()`**: Returns the set of `(row, col)` positions of cells that already contain [value] in the same row, column, or sub-grid as the cell at ([row], [col]).  Used for validating Note inputs.

### 📄 `lib/src/features/game/domain/entities/board_config.dart`
- **Class/Widget `BoardConfig`**: Defines the structural dimensions of a Sudoku grid.  The total [gridSize] equals [subGridRows] × [subGridCols], and valid cell values range from 1 to [gridSize] inclusive.  This class is the Phase 2 future-proofing anchor: the entire engine (board, validator, generator, UI) reads its dimensions from here, so swapping to a different grid shape requires changing only the config.  | Preset    | Sub-grid | Board   | Values  | |-----------|----------|---------|---------| | `standard`| 3 × 3   | 9 × 9  | 1 – 9  | | `mini`    | 2 × 2   | 4 × 4  | 1 – 4  | | `large`   | 4 × 4   | 16 × 16| 1 – 16 |

### 📄 `lib/src/features/game/domain/entities/sudoku_board.dart`
- **Class/Widget `SudokuBoard`**: The aggregate root for a Sudoku puzzle.  Holds a deeply immutable two-dimensional grid of [SudokuCell]s and provides helper methods to access rows, columns, and sub-grid regions.  ## Immutability Contract  Every mutation method ([updateCell], [copyWith]) returns a **new** [SudokuBoard] — the original is never modified. This aligns naturally with Riverpod's state model and makes undo/redo trivially easy: maintain a `List<SudokuBoard>` stack of snapshots.  ## Grid Dimensions  [subGridSize] defines the side-length of each square sub-grid region. The full board is [gridSize] × [gridSize], where `gridSize = subGridSize²`.  | [subGridSize] | Sub-grid shape | Full board  | Valid values | |---------------|----------------|-------------|--------------| | `3` (default) | 3 × 3          | 9 × 9      | 1 – 9       | | `2`           | 2 × 2          | 4 × 4      | 1 – 4       | | `4`           | 4 × 4          | 16 × 16    | 1 – 16      | | `5`           | 5 × 5          | 25 × 25    | 1 – 25      |  ## Coordinate System  `(row, col)` — both zero-indexed, top-left origin.
  - `function empty()`: Creates a completely empty board.  Every cell has [SudokuCell.isOriginal] = `false`, [SudokuCell.value] = `null`, and a placeholder [SudokuCell.solutionValue] of `1`. The puzzle generator is responsible for setting real solution values before exposing the board to the player.
  - `function reset()`: Returns a new board resetting all user inputs and notes, restoring the board to its initial state.
  - `function fromValues()`: Creates a board from two flat integer lists in row-major order.  - [given]: The puzzle's initial state. Use `0` for empty (player-fillable) cells. Non-zero values become [SudokuCell.isOriginal] = `true`. - [solution]: The complete, correct solution. Must not contain zeros.  This is the primary constructor used by the puzzle generator after it has produced both a full solution and a masked puzzle.
  - `function cellAt()`: Returns the cell at ([row], [col]).
  - `function rowAt()`: Returns all cells in the given [row] (left to right).
  - `function columnAt()`: Returns all cells in the given [col] (top to bottom).
  - `function subGridAt()`: Returns all cells in the sub-grid region that contains ([row], [col]).  Correct for any [subGridSize], making this Phase 2-ready automatically.
  - `function updateCell()`: Returns a new board with the cell at ([row], [col]) replaced by [cell].  All other cells are preserved. This is the primary way for the Riverpod notifier to advance the board state after player input.
  - `function copyWith()`: Returns a new board with the specified top-level fields replaced.
  - `function pruneNotesForPlacement()`: Returns a new board with [value] removed from the [SudokuCell.notes] of every peer cell at ([row], [col]).  "Peer" means any cell that shares the same row, column, or sub-grid. The cell at ([row], [col]) itself is never modified here — the caller is responsible for having already placed the value there.  This is the **Auto-Prune** step: after filling a cell the caller should immediately call this to keep pencil marks consistent.
  - `function fold()`: Number of cells that currently have any value (original + user-entered).
  - `function fold()`: Number of cells the player has filled in (excludes original cells).

### 📄 `lib/src/features/game/domain/entities/sudoku_cell.dart`
- **Class/Widget `SudokuCell`**: An immutable value object representing a single cell in the Sudoku grid.  ## Symbol-Agnostic Design (Phase 2 Future-Proofing)  All values — [value], [solutionValue], and [notes] — are stored as plain [int]s (1 to `gridSize`). The domain layer is completely decoupled from visual symbols. The presentation layer maps each integer to the appropriate display symbol (digit, Roman numeral, letter, color swatch) via a `SymbolMapper`, so the entire game engine works identically regardless of the active symbol set chosen by the player.  ## Fields  | Field           | Description                                          | |-----------------|------------------------------------------------------| | [row]           | Zero-indexed row coordinate on the board             | | [col]           | Zero-indexed column coordinate on the board          | | [value]         | Player's current entry; `null` when the cell is empty| | [solutionValue] | The provably correct answer for this cell            | | [isOriginal]    | `true` when pre-filled by the puzzle; not editable   | | [notes]         | Set of pencil-mark candidates chosen by the player   |  ## Constraints - An [isOriginal] cell must have a non-null [value]. - [solutionValue] must be ≥ 1.
  - `function copyWith()`: Returns a new [SudokuCell] with only the specified fields replaced.  To explicitly clear [value], set `clearValue: true` instead of passing `value: null` — this avoids the ambiguity between "no change" and an intentional clear. Setting `clearValue: true` also wipes all [notes].
  - `function toggleNote()`: Returns a new cell with [digit] toggled in [notes].  If [digit] is already present it is removed; otherwise it is added. To clear all notes, use [clearNotes] or pass `clearValue: true` to [copyWith] when placing a definitive value.
  - `function clearNotes()`: Returns a new cell with all pencil marks removed.

### 📄 `lib/src/features/game/presentation/game_page.dart`
- **Class/Widget `GamePage`**: Halaman arena bermain Sudoku. Menghubungkan seluruh komponen UI papan, numpad, timer, dan alat.
- **Class/Widget `_GamePageState`**: Mengatur event daur hidup (lifecycle) `GamePage` dan mendengarkan status menang/kalah.
- **Class/Widget `_PulseAutoCompleteButton`**: Tombol "Auto Complete" yang akan berdenyut memanggil pemain saat sisa sel kosong sangat sedikit.
- **Class/Widget `_PulseAutoCompleteButtonState`**: Mengelola animasi denyut tak berujung (looping animation) dari tombol Auto Complete.

### 📄 `lib/src/features/game/presentation/utils/symbol_mapper.dart`
- *Fungsi utilitas untuk menerjemahkan angka data internal (1-9) menjadi berbagai gaya simbol visual (angka biasa, Romawi, warna, dll) di antarmuka.*

### 📄 `lib/src/features/game/presentation/widgets/game_control_pad.dart`
- **Class/Widget `GameControlPad`**: Pill-shaped toolbar placed above the numpad. Contains: Undo · Erase · Notes · Hint
- **Class/Widget `_ToolButton`**: Tombol utilitas satuan di Control Pad (Undo, Notes, Erase, Hint).

### 📄 `lib/src/features/game/presentation/widgets/game_number_pad.dart`
- **Class/Widget `GameNumberPad`**: Komponen kumpulan tombol input angka 1-9 (berbentuk keypad) di bagian bawah papan bermain.
- **Class/Widget `_NumpadDigitButton`**: A square numpad button with an overlapping circular badge showing how many of this digit remain to be placed.

### 📄 `lib/src/features/game/presentation/widgets/game_setup_dialog.dart`
- **Class/Widget `GameSetupDialog`**: Dialog sembulan (pop-up) awal yang meminta pengguna memilih tingkat kesulitan sebelum memulai puzzle baru.
- **Class/Widget `_GameSetupDialogState`**: Menyimpan pilihan tombol kesulitan sementara hingga pengguna menekan "Start".

### 📄 `lib/src/features/game/presentation/widgets/game_theme_picker.dart`
- **Class/Widget `GameThemePopupMenu`**: Antarmuka *dropdown/popup* untuk mengganti skema warna tema secara dinamis.
- **Class/Widget `_ThemeSwatch`**: Elemen lingkaran kecil (swatch) penanda warna yang mewakili sebuah preset tema tertentu.

### 📄 `lib/src/features/game/presentation/widgets/game_top_bar.dart`
- **Class/Widget `GameTopBar`**: Bar paling atas saat bermain; menampilkan tingkat kesulitan, timer (*stopwatch*), batas kesalahan (mistakes), dan tombol Pause.

### 📄 `lib/src/features/game/presentation/widgets/sudoku_board_widget.dart`
- **Class/Widget `SudokuBoardWidget`**: Widget inti perender papan Sudoku besar 9x9 (atau dinamis), mengelola susunan 9 `_SubGridCard`.
- **Class/Widget `_BoardHighlightData`**: Kelas utilitas untuk merangkum seluruh parameter sorotan visual (selected, crosshair, dll) yang disalurkan dari State ke Widget papan.
- **Class/Widget `_SubGridCard`**: Komponen area sub-grid 3x3; memberikan jarak garis pemisah (border) yang tegas terhadap sub-grid lainnya.
- **Class/Widget `SudokuCellTile`**: Widget unit terkecil: satu buah kotak sel Sudoku yang dirender dengan animasi sentuh (tap) dan transisi warna.
- **Class/Widget `_NotesGrid`**: Sistem grid miniatur di dalam satu `SudokuCellTile` untuk merender angka catatan (pencil marks) kecil-kecil.
- **Class/Widget `_DashedGridPainter`**: Kelas perender garis titik-titik (dashed line) halus antar sel di dalam satu `_SubGridCard`.
- **Class/Widget `DecorativeArcsPainter`**: Perender ornamen sudut (lengkungan estetika) tambahan untuk mempercantik papan, digambar manual menggunakan Canvas API.

## `test` Directory
Folder ini berisi kode pengujian (tests) untuk memastikan kualitas dan keandalan logika aplikasi MungSudoku. Berikut adalah rincian pengujian yang dilakukan:

### 📄 `test/features/game/sudoku_game_logic_test.dart`
- **Tujuan Pengujian**: Menguji kebenaran aturan (rules) dari permainan Sudoku pada level entitas (*Domain Layer*).
- **Detail**:
  - Memastikan papan yang kosong tidak terdeteksi memiliki konflik.
  - Menguji `SudokuValidator` untuk mampu mendeteksi secara akurat bentrokan angka yang terjadi pada baris (row), kolom (column), dan blok sub-grid 3x3.
  - Memvalidasi logika generator dalam memproduksi kandidat angka atau fungsi-fungsi lain yang terkait dengan logika mentah papan.

### 📄 `test/features/game/application/game_notifier_test.dart`
- **Tujuan Pengujian**: Menguji integritas `GameNotifier` (state manager utama) menggunakan arsitektur Riverpod (*Application Layer*).
- **Detail**:
  - Memastikan *state* awal terinisialisasi dengan benar sebelum ada aksi pengguna.
  - Menguji logika transisi permainan, seperti interaksi memilih sel, menekan numpad, dan menggunakan fitur seperti *undo/redo* dan *hints*.
  - Mengonfirmasi bahwa setiap input pemain mengubah status `GameState` secara immutabel (menciptakan objek state baru, bukan memodifikasi yang lama).

### 📄 `test/widget_test.dart`
- **Tujuan Pengujian**: Melakukan *UI / Widget Testing* dasar (*Presentation Layer*).
- **Detail**:
  - Menguji apakah kerangka utama aplikasi (`MungSudokuApp`) dapat diluncurkan (launch) tanpa *crash*.
  - Memverifikasi halaman utama (Home Page) muncul dengan benar dan mendeteksi keberadaan teks kunci, seperti "Player 1" dan tombol "NEW GAME".
