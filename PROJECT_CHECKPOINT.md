# MungSudoku — Project Checkpoint

> **Last updated:** 2026-07-28  
> **Purpose:** Architectural blueprint for AI session continuity. If the chat is reset, the next AI can read this file and fully understand the system without re-scanning.

---

## 1. Project Status

| Phase | Description | Status |
|-------|-------------|--------|
| **Phase 1** | Core Engine — Puzzle generation, validation, game state, undo/redo, hints, timer, dual input modes | ✅ **100% Complete** |
| **Phase 2** | Dynamic Grid & Symbol Customization — Multi-size boards (4×4, 9×9, 16×16), Roman numeral symbols, adaptive UI, Auto-Prune Notes, cumulative mistakes, Game Over, Fast Note, visual polishing | ✅ **100% Complete** |
| **Phase 3** | Cloud Sync & Persistence — Supabase auth, offline-first auto-save, profile management | 🔲 Not Started |

### Quality Gates Passed

- `flutter analyze` → **0 issues**
- `flutter test test/features/game/sudoku_game_logic_test.dart` → **13/13 tests passed**
- Visual playtest on Chrome (375px iPhone SE through 1440px desktop) → **No overflow, no clipping**

---

## 2. Tech Stack

| Concern | Choice | Version |
|---------|--------|---------|
| Framework | Flutter (multi-platform) | SDK `^3.12.0` |
| State management | **Riverpod** (`Notifier<T>`) | `flutter_riverpod: ^3.3.2` |
| Routing | **GoRouter** (declarative) | `go_router: ^17.3.0` |
| Logging | `logging` package | `^1.3.0` |
| Linting | `flutter_lints` | `^6.0.0` |

---

## 3. Project Structure

```
lib/
├── main.dart                          # App entry → ProviderScope + MaterialApp.router
└── src/
    ├── core/
    │   ├── router/
    │   │   └── app_router.dart        # GoRouter: '/' (HomePage), '/game' (GamePage)
    │   └── theme/
    │       └── game_theme.dart        # GameTheme class + gameThemeProvider (blue / dark presets)
    └── features/
        ├── home/
        │   └── presentation/
        │       ├── home_page.dart      # Main menu / landing screen
        │       └── widgets/            # Home-specific widgets
        └── game/
            ├── domain/                 # Pure Dart, zero Flutter imports (except @immutable)
            │   ├── entities/
            │   │   ├── board_config.dart    # BoardConfig (subGridRows×subGridCols presets)
            │   │   ├── sudoku_board.dart    # SudokuBoard (immutable 2D cell grid + helpers)
            │   │   └── sudoku_cell.dart     # SudokuCell (value, notes, solutionValue, flags)
            │   ├── enums/
            │   │   ├── difficulty.dart      # Easy(36) / Medium(27) / Hard(17) given cells
            │   │   └── symbol_type.dart     # standard / roman
            │   └── services/
            │       └── sudoku_validator.dart # findConflicts(), isValidPlacement()
            ├── data/
            │   └── services/
            │       └── sudoku_generator.dart # Backtracking solver + difficulty masking
            ├── application/
            │   ├── game_state.dart          # GameState (immutable snapshot, undo/redo stacks)
            │   └── game_notifier.dart       # GameNotifier (Riverpod Notifier, all mutations)
            └── presentation/
                ├── game_page.dart           # Scaffold: Stack(board, controlPad, numpad, dialogs)
                ├── utils/
                │   └── symbol_mapper.dart   # int → display string (digits/letters/Roman)
                └── widgets/
                    ├── sudoku_board_widget.dart  # Board grid, sub-grid cards, cell tiles, notes
                    ├── sudoku_cell_widget.dart   # Public re-export stub (unused internally)
                    ├── game_control_pad.dart     # Pill toolbar: Undo, Erase, Fast Note, Note, Hint
                    ├── game_number_pad.dart      # Square digit buttons + remaining-count badges
                    ├── game_setup_dialog.dart    # Pre-game dialog: grid size + symbol type picker
                    └── game_top_bar.dart         # Difficulty label, Mistakes X/3, Timer, Pause

test/
└── features/
    └── game/
        └── sudoku_game_logic_test.dart  # 13 tests covering validator, generator, notifier
```

---

## 4. Architecture Deep Dive

### 4.1 Domain Layer (Pure Dart)

#### `SudokuCell` — Immutable value object

| Field | Type | Description |
|-------|------|-------------|
| `row`, `col` | `int` | Zero-indexed grid coordinates |
| `value` | `int?` | Player's current entry (`null` = empty) |
| `solutionValue` | `int` | The provably correct answer |
| `isOriginal` | `bool` | Pre-filled by generator → not editable |
| `notes` | `Set<int>` | Pencil-mark candidates |

Key methods: `copyWith()`, `toggleNote(digit)`, `clearNotes()`.  
Derived: `isEmpty`, `isFilled`, `isEditable`, `isIncorrect`, `isCorrect`.

#### `SudokuBoard` — Immutable 2D grid wrapper

- Stores `List<List<SudokuCell>>` + `subGridSize` (int).
- `gridSize` = `subGridSize²` (e.g., 3² = 9, 4² = 16).
- Key methods:
  - `cellAt(r, c)` — safe cell access.
  - `updateCell(r, c, cell)` — returns a new board with one cell replaced.
  - `pruneNotesForPlacement(r, c, value)` — **Auto-Prune**: removes `value` from the `notes` of all peers (same row, column, and sub-grid). Returns a new board.
  - `isCompleted` — true when every cell's `value == solutionValue`.
  - `filledCellCount`, `mistakeCount` — derived counters.
- Factory: `SudokuBoard.fromValues(given:, solution:, subGridSize:)` builds the initial board from flat `List<int>`.
- Factory: `SudokuBoard.empty()` for the initial state placeholder.

#### `BoardConfig` — Grid dimension presets

| Preset | Sub-grid | Board | Values |
|--------|----------|-------|--------|
| `mini` | 2×2 | 4×4 | 1–4 |
| `standard` | 3×3 | 9×9 | 1–9 |
| `large` | 4×4 | 16×16 | 1–16 |

#### `SudokuValidator` — Constraint checker (static, pure)

- `findConflicts(board)` → `Set<(int, int)>` of all cells violating row/col/sub-grid uniqueness.
- `isValidPlacement(board, r, c, value)` → `bool`, used by generator and Fast Note.

#### `Difficulty` — Enum

- `easy` → 36 givens on 9×9 (scaled proportionally for other sizes).
- `medium` → 27 givens.
- `hard` → 17 givens.

#### `SymbolType` — Enum

- `standard` → digits 1–9, then letters A–G for 10–16.
- `roman` → I, II, III, IV, V, ... XVI.

### 4.2 Data Layer

#### `SudokuGenerator` — Randomised backtracking solver

- `generate(Difficulty, {subGridSize})` → `SudokuBoard`.
- Internally: fills a `List<List<int>>` grid via recursive `_solve()` with shuffled candidates, then masks cells using `_maskCells()`.
- Difficulty scaling: `givenCellCount / 81 * totalCells` to support any grid size.

### 4.3 Application Layer (Riverpod)

#### `GameState` — Immutable session snapshot

| Field | Type | Notes |
|-------|------|-------|
| `board` | `SudokuBoard` | Current puzzle state |
| `difficulty` | `Difficulty` | Session difficulty |
| `selectedSubGridSize` | `int` | Grid config for current game |
| `symbolType` | `SymbolType` | Visual symbol set |
| `gameDuration` | `Duration` | Elapsed playing time |
| `isPaused` | `bool` | Timer paused, board hidden in UI |
| `remainingHints` | `int` | Starts at 3 |
| `isNoteMode` | `bool` | Pencil-mark input toggle |
| `cumulativeMistakeCount` | `int` | Cumulative (never decreases) |
| `selectedRow` / `selectedCol` | `int?` | Standard mode selection |
| `activeValue` | `int?` | Fast mode held digit |
| `undoStack` / `redoStack` | `List<SudokuBoard>` | Board snapshots |
| `conflictPositions` | `Set<(int, int)>` | Real-time constraint violations |
| `isGameOver` | `bool` | `cumulativeMistakeCount >= 3` |
| `isVictory` | `bool` | `board.isCompleted` |

Constants: `maxMistakes = 3`.  
Computed: `hasSelection`, `highlightedValue`, `board` (alias for `currentBoard`).

#### `GameNotifier` — Central state machine

| Method | Description |
|--------|-------------|
| `initNewGame(difficulty, {subGridSize, symbolType})` | Generates puzzle, resets all state, starts timer |
| `selectCell(r, c)` | Standard mode: toggle cell selection |
| `activateValue(v)` | Fast mode: hold a digit for tap-to-place |
| `inputNumber(r, c, v)` | Place value or toggle note, auto-prune peers, track mistakes |
| `clearCell(r, c)` | Erase value and notes from an editable cell |
| `toggleNoteMode()` | Switch between value/pencil-mark input |
| `fastFillNotes()` | Auto-fill all empty cells with valid candidates via `SudokuValidator.isValidPlacement` |
| `useHint()` | Reveal `solutionValue` in selected cell, decrement quota |
| `undo()` / `redo()` | Pop/push board snapshots from stacks |
| `pauseGame()` / `resumeGame()` | Halt/resume 1-second timer |

Internal:  
- `_applyBoardUpdate(board, {cumulativeMistakeCount?})` — central mutation: runs conflict detection, checks victory/game-over, pushes undo stack, triggers auto-save.
- `_autoSave()` — currently logs only; Phase 3 will write to Hive + sync to Supabase.
- `_tick()` — 1-second periodic timer incrementing `gameDuration`.

##### Mistake Rules (Important!)
1. Mistake increments **only** when `newValue != null && newValue != solutionValue`.
2. Erasing or correcting a wrong value does **NOT** decrease the count.
3. Game Over triggers immediately at `cumulativeMistakeCount >= 3`.
4. Timer stops on Game Over or Victory.

##### Auto-Prune Notes Flow
```
inputNumber(r, c, value) [fill mode, newValue != null]
  ├── updateCell → new board with value placed + cell's own notes cleared
  ├── pruneNotesForPlacement(r, c, value) → removes value from all peer notes
  └── _applyBoardUpdate → single undo snapshot covering both changes
```

### 4.4 Presentation Layer

#### Theme System — `GameTheme`

Centralised `@immutable` class with every visual token:

| Category | Tokens |
|----------|--------|
| Background | `background` (scaffold fill) |
| Sub-grid card | `subGridBackground`, `subGridBorderRadius`, `subGridSpacing`, `subGridShadow` |
| Cell states | `selectedCellColor` (yellow), `identicalValueCellColor` (blue), `conflictCellColor` (red), `originalCellColor` |
| Text | `originalTextColor`, `inputTextColor`, `conflictTextColor` |
| Controls | `controlPadBackground`, `controlPadShadow` |
| Numpad | `numpadBackground`, `numpadButtonBackground`, `numpadButtonShadow` |
| Decorative | `arcColor` |

Built-in presets: `GameTheme.blue` (default), `GameTheme.dark`.  
Provided via: `final gameThemeProvider = Provider<GameTheme>((ref) => GameTheme.blue);`.

#### Board Layout — `SudokuBoardWidget`

- Top-level: `GridView` of `_SubGridCard` widgets (arranged in `subGridSize × subGridSize`).
- Each `_SubGridCard`: white rounded card with `BoxShadow`, contains its own `GridView` of `_CellTile` widgets + a `_DashedGridPainter` overlay for cell separator lines.
- `_CellTile`: renders value text (centered, `FittedBox`) or `_NotesGrid` (mini `GridView` with `shrinkWrap: true`).
- Highlighting logic per cell:
  - **Selected** → yellow background.
  - **Identical value** → light blue background.
  - **Crosshair** (same row/col/sub-grid) → very faint grey.
  - **Conflict** → red background + red text.
  - **Highlighted note** → bold text for matching pencil mark.
- Decorative: `DecorativeArcsPainter` renders 3 quarter-circle arcs in bottom-right corner.

#### Adaptive Font Scaling

| Grid size | Main value font | Notes font |
|-----------|----------------|------------|
| ≤ 9 | 22.0 | 10.0 |
| 10–16 | 15.0 | 7.0 |
| > 16 | 11.0 | 7.0 |

Roman numeral notes use `FittedBox(fit: BoxFit.scaleDown)` to avoid overflow.

#### Numpad — `GameNumberPad`

- Buttons rendered as `Wrap` (not `Row`) for safe layout on narrow screens.
- `buttonSize`: 40px default, 34px for `screenWidth <= 375`.
- Each button: white square + `BoxShadow` (Neo-Brutalism), overlapping circular badge showing remaining count.
- `fontSize`: scales down proportionally on small screens and large grids.

#### Control Pad — `GameControlPad`

- Pill-shaped white container with 5 tool buttons: **Undo**, **Erase**, **Fast Note**, **Note**, **Hint**.
- Fast Note → calls `notifier.fastFillNotes()`.
- Note → calls `notifier.toggleNoteMode()` (icon changes between outlined/filled).

#### Top Bar — `GameTopBar`

- Left: Difficulty name + `Mistakes: X/3` (white text, red when mistakes > 0).
- Right: Timer icon + formatted duration + Pause/Play button.
- All text and icons use `Colors.white` for contrast on blue background.

#### Game Setup Dialog — `GameSetupDialog`

- Modal shown before game starts via `/game` route.
- Grid size picker: "2×2 (4×4)", "3×3 (9×9 Standard)", "4×4 (16×16 Mega)".
- Symbol type picker: "Angka / Huruf Standard", "Angka Romawi".
- Calls `notifier.initNewGame(difficulty, subGridSize: ..., symbolType: ...)`.

#### Dialogs

- **Game Over**: shown via `ref.listen` when `state.isGameOver == true`. Offers "Restart" and "Quit to Main Menu".
- **Victory**: shown via `ref.listen` when `state.isVictory == true`.
- **Pause overlay**: semi-transparent black overlay hiding the board, with Resume and Quit buttons.

---

## 5. Data Flow Summary

```
┌──────────────┐    generates     ┌───────────────────┐
│ SudokuGenerator├───────────────►│ SudokuBoard        │
└──────────────┘                  │ (immutable grid)   │
                                  └────────┬──────────┘
                                           │
                  ┌────────────────────────┘
                  ▼
┌─────────────────────────────┐   validates    ┌──────────────────┐
│ GameNotifier                │◄──────────────►│ SudokuValidator  │
│ (Riverpod Notifier)         │                └──────────────────┘
│                             │
│ • inputNumber / clearCell   │
│ • undo / redo               │   emits new
│ • useHint                   │──────────────►  GameState
│ • fastFillNotes             │                 (immutable snapshot)
│ • toggleNoteMode            │                      │
│ • selectCell / activateValue│                      │
└─────────────────────────────┘                      │
                                                     ▼
                                  ┌──────────────────────────────┐
                                  │ Presentation Layer           │
                                  │ • GamePage (scaffold)        │
                                  │ • SudokuBoardWidget (board)  │
                                  │ • GameControlPad (tools)     │
                                  │ • GameNumberPad (digits)     │
                                  │ • GameTopBar (metadata)      │
                                  └──────────────────────────────┘
```

---

## 6. Test Coverage

File: `test/features/game/sudoku_game_logic_test.dart` — **13 tests**

| Group | Test | What it verifies |
|-------|------|------------------|
| SudokuValidator | Empty board has no conflicts | Baseline — clean board = 0 conflicts |
| | Detects conflict in same row | Two identical values in one row |
| | Detects conflict in same column | Two identical values in one column |
| | Detects conflict in same sub-grid | Two identical values in one 3×3 box |
| SudokuGenerator | Full solution is valid | Fill all cells with solution → 0 conflicts |
| | Given cells count matches difficulty | Easy/Medium/Hard produce correct given counts |
| GameNotifier | selectCell updates selection | Tap selects, re-tap deselects |
| | inputNumber updates board immutably | Value placement + note toggling + clearing |
| | undo/redo restore board states | Snapshot stack correctness |
| | useHint fills correct cell | Decrements quota, reveals `solutionValue` |
| | Wrong input increments mistakes | Cumulative count, no decrease on erase |
| | Game Over at maxMistakes | 3 wrong inputs → `isGameOver == true` |
| | fastFillNotes fills valid candidates | All empty cells get notes, all notes are valid placements |

---

## 7. Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Immutable board** via `copyWith` / `updateCell` | Enables trivial undo/redo (snapshot stacks) and safe Riverpod rebuilds |
| **Cumulative mistake counter in GameState** (not derived from board) | Erasing a wrong answer must not reduce the count — permanent penalty |
| **Auto-Prune in `SudokuBoard`** (not in Notifier) | Domain owns geometry; Notifier stays thin and orchestration-only |
| **`pruneNotesForPlacement` returns one board** | Single undo snapshot captures both value placement and note pruning |
| **`Wrap` instead of `Row` for numpad** | Prevents horizontal overflow on narrow screens (iPhone SE 375px) |
| **`shrinkWrap: true` on notes GridView** | Prevents the GridView from collapsing to zero height inside cell tiles |
| **Theme as `@immutable` class + Riverpod Provider** | Swap entire visual identity by changing one provider value |
| **SymbolMapper in presentation, not domain** | Domain layer is symbol-agnostic; int-only throughout engine |

---

## 8. Phase 3 Roadmap — Cloud Sync & Persistence

### 8.1 Planned Technology

| Component | Choice | Notes |
|-----------|--------|-------|
| Auth | Supabase Auth | Email/password + Google OAuth |
| Database | Supabase PostgreSQL | Row-Level Security (RLS) |
| Local cache | Hive (or SharedPreferences for simple state) | Offline-first writes |
| Sync strategy | Write-local-first → queue → sync on connectivity | Conflict resolution: server wins on `updated_at` |

### 8.2 Proposed Database Schema

```sql
-- User profiles
CREATE TABLE profiles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

-- Saved games (one active + history)
CREATE TABLE saved_games (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  difficulty    TEXT NOT NULL,           -- 'easy' | 'medium' | 'hard'
  sub_grid_size INT NOT NULL DEFAULT 3,
  symbol_type   TEXT NOT NULL DEFAULT 'standard',
  board_snapshot JSONB NOT NULL,         -- Serialised SudokuBoard (cells + solution)
  game_state    JSONB NOT NULL,          -- Duration, mistakes, hints remaining, etc.
  is_completed  BOOLEAN NOT NULL DEFAULT false,
  is_game_over  BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_saved_games_user ON saved_games(user_id);
CREATE INDEX idx_saved_games_active ON saved_games(user_id) WHERE NOT is_completed AND NOT is_game_over;
```

### 8.3 Integration Points in Current Code

| Current code | Phase 3 change |
|--------------|----------------|
| `GameNotifier._autoSave()` (logs only) | Write `GameState` → Hive → enqueue Supabase upsert |
| `GameNotifier.initNewGame()` | Check for existing `saved_games` row; offer Resume vs New |
| `AppRouter` | Add `/auth` route, redirect guard on `go_router` |
| `GameState` | Add `toJson()` / `fromJson()` for JSONB serialisation |
| `SudokuBoard` | Add `toJson()` / `fromJson()` for snapshot persistence |
| `SudokuCell` | Add `toJson()` / `fromJson()` for cell-level serialisation |

---

## 9. Commands Cheat Sheet

```bash
# Analyze (should be 0 issues)
flutter analyze --no-pub

# Run all unit tests
flutter test test/features/game/sudoku_game_logic_test.dart --no-pub

# Run on Chrome (for visual testing)
flutter run -d chrome

# Run on specific device
flutter run -d <device-id>
```

---

> **For the next AI session:** Start by reading this file. Then read `game_state.dart` and `game_notifier.dart` for the full state machine. The architecture is Clean Architecture with Riverpod — domain is pure Dart, presentation reads from providers, all mutations flow through `GameNotifier`.
