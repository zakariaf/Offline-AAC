# E03-T02 — BoardRepository

| | |
|---|---|
| **Epic** | E03 — Data layer |
| **Status** | Done |
| **Size** | M |
| **Depends on** | E03-T01 |
| **Blocks** | E03-T06, E05-T02, E05-T08, E09-T01 |

**Skills:** `reed-drift-schema` · `reed-layering-rules` · `reed-riverpod-usage` · `reed-async-rules`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A displayable tile is a three-table join — `grid_slots ⟕ buttons ⟕ images`, two nullable FKs — and drift generates a row class per table and **never per join**. Somebody has to unpack `List<TypedResult>` with `readTable()` / `readTableOrNull()` and materialize a `BoardGrid`, and that somebody must not be a widget. This class is the only thing in the app the UI may ask about boards; below it is drift, above it is `gridProvider` and `BoardController`. It is also where grid bounds are enforced, because the schema deliberately refuses to hardcode 3×4 and SQLite `CHECK` cannot reference another table.

## Scope

One concrete final class at `lib/data/board_repository.dart`. Constructor takes `AppDatabase`. No interface, no DAO wrapper, no `*UseCase`, no mapper layer.

```dart
final class BoardRepository {
  BoardRepository(this._db);
  final AppDatabase _db;
  // ...
}
```

### 1. The joined read

Build the select on `grid_slots` with two `leftOuterJoin`s. `buttons` is nullable because an empty cell is a real row with `button_id IS NULL`; `images` is nullable because `buttons.image_id` is nullable.

```dart
final JoinedSelectStatement<HasResultSet, dynamic> q = _db.select(_db.gridSlots).join(<Join<HasResultSet, dynamic>>[
  leftOuterJoin(_db.buttons, _db.buttons.id.equalsExp(_db.gridSlots.buttonId)),
  leftOuterJoin(_db.images, _db.images.id.equalsExp(_db.buttons.imageId)),
])..where(_db.gridSlots.boardId.equals(boardId));
```

Unpack each `TypedResult` with `readTable(_db.gridSlots)` (never null — the slot row is the driving table) and `readTableOrNull(_db.buttons)` / `readTableOrNull(_db.images)`. A row whose button is null is an **empty slot**, not a row to skip.

Hidden tiles: `buttons.hidden == true` means the slot presents as empty in speak mode. Do not filter hidden buttons out in the `WHERE` — that would drop the slot row too and lose the coordinate. Read the row, then resolve the button to `null` when `hidden` is set. Edit mode needs hidden tiles visible, so expose that as a parameter on the method rather than baking one policy in.

### 2. `BoardGrid` materialization

`BoardGrid` and the joined `Tile` are the only two hand-written model types in the app (`lib/model/`, flat). Dimensions come from the `boards` row — `boards.grid_rows` and `boards.grid_cols` — never from a `const kRows = 4`. Read the board row in the same call and build a `rows × cols` structure of `Tile?`.

A board always holds exactly `grid_rows × grid_cols` slot rows. If the query returns fewer, a coordinate has been lost — that is a real corruption, not a case to paper over. Build the grid by allocating `rows × cols` nulls and placing each returned slot at `(row_index, col_index)`, so a missing row surfaces as an empty tile rather than a reflow, and a slot whose indices fall outside the board's dimensions is a defect that must be surfaced, not silently dropped.

Tile field resolution — three `String`s the type system cannot tell apart, so resolve them in exactly one place, here:

| Field | Source |
|---|---|
| what the tile shows | `buttons.label` (NOT NULL, hard cap 16 chars) |
| what is spoken | `buttons.vocalization ?? buttons.label` |
| what show-text renders | `buttons.display_text ?? (vocalization ?? label)` |

Media path resolution is **not** this class's job to hand-build: `images.path` is relative to the **documents** directory, while the DB file lives in the **support** directory. Resolve media through the single helper that owns the documents base (`media_store.dart`). Never join an image path against the support dir. Never emit an absolute path into the DB.

### 3. The reactive watch

```dart
Stream<BoardGrid> watchGrid(int boardId)
```

Backed by drift's `.watch()`. `gridProvider` is a `StreamProvider` over it, so Riverpod owns the subscription lifecycle — this class hand-manages no `StreamSubscription` and no `StreamController`.

Also provide the point read used by the tap path:

```dart
Future<Tile?> tileAt(int boardId, int row, int col)
```

`(board_id, row_index, col_index)` is the primary key. Position is what the tap path resolves by, because position cannot go stale between build and tap.

### 4. The write path

- **Delete a tile = delete the button.** `grid_slots.button_id` becomes NULL via `onDelete: KeyAction.setNull`, and nothing moves.

  ```dart
  // WRONG — deletes the cell, invites a reflow, loses the coordinate.
  await (_db.delete(_db.gridSlots)..where((GridSlots s) => s.buttonId.equals(id))).go();

  // RIGHT — the button goes; the slot survives, empty, in place.
  await (_db.delete(_db.buttons)..where((Buttons b) => b.id.equals(id))).go();
  ```

- **Hide = `hidden = 1`.** Removing content from view is never a reason to destroy it. `is_system` buttons (the repair phrase) are undeletable — the repository refuses the delete rather than the UI merely not offering it.
- **Any user write sets `user_edited = 1`** and bumps `updated_at`. `user_edited = 1` is a hard stop for every future seed/default-set update: never overwrite, never "upgrade", never reconcile.
- **Placing a button in a slot is an update of the slot row, never an insert of a second one.** The composite PK makes a duplicate coordinate a constraint failure — let it fail loudly; do not `insertOnConflictUpdate` your way past a signal.
- **Bounds are enforced here.** Reject `row < 0 || row >= board.gridRows || col < 0 || col >= board.gridCols` with a thrown error, before touching SQL. The schema carries no `CHECK` on purpose (a 2×3 large layout ships alongside the 3×4 phone default, and a `CHECK` would make it a database-level insert failure at v2).
- Multi-statement writes (insert button + point the slot at it) go in one `transaction`.

### Out of scope

- `SettingsRepository` — separate class, separate task.
- `gridProvider` / `boardRepositoryProvider` wiring in `lib/providers.dart` — that lives with the provider task; this class must simply be constructible as `BoardRepository(ref.watch(databaseProvider))`.
- Media import/downscaling (`media_store.dart`).
- Any `BoardController` / `Notifier` work.
- Any abstract interface, fake, or DAO layer — explicitly rejected.

## Acceptance criteria

- [ ] `dart analyze` is clean (`use_build_context_synchronously`, `discarded_futures`, `unawaited_futures`, `cancel_subscriptions`, `close_sinks` are all at `error`).
- [ ] `grep -rn "package:drift" lib/ui/ lib/model/` returns nothing.
- [ ] `grep -rn "abstract interface class BoardRepository\|BoardRepositoryImpl\|DriftBoardRepository\|UseCase" lib/` returns nothing.
- [ ] `grep -rn "kRows\|kCols\|= 4;\|= 3;" lib/data/board_repository.dart` shows no hardcoded grid dimension — rows/cols come from the `boards` row.
- [ ] Test: on a seeded 3×4 board, `watchGrid` emits a `BoardGrid` with `rows == 3`, `cols == 4`, and exactly 12 addressable cells including the empty ones. Runs against `NativeDatabase.memory()` — not a fake.
- [ ] Test: a slot with `button_id IS NULL` yields a `null` tile at its coordinate and every other tile stays at its original `(row, col)`.
- [ ] Test: deleting a button emits a new `BoardGrid` where that coordinate is `null` and **no other tile has moved** — assert every remaining tile's `(row, col)` is unchanged, not just the count.
- [ ] Test: `PRAGMA foreign_keys` returns `1` on the connection the repository uses. (Pairs with the test above: this one says *why* it broke, that one says *that* it broke.)
- [ ] Test: a button with `vocalization == null` speaks its `label`; a button with `display_text == null` renders `vocalization ?? label`. Assert with three distinct strings so a swap cannot pass.
- [ ] Test: a button with `hidden = 1` resolves to an empty tile in the speak read and to a present tile in the edit read — the slot row exists in both.
- [ ] Test: writing to `(row: 3, col: 0)` on a 3×4 board throws before any SQL runs; the DB is unchanged afterwards.
- [ ] Test: on a 2×3 board row, `watchGrid` emits `rows == 2, cols == 3` and no insert within those bounds fails.
- [ ] Test: any user write sets `user_edited = 1` on the touched button.
- [ ] Test: deleting an `is_system` button is refused and the button still exists.
- [ ] No `StreamSubscription` or `StreamController` field exists in this file.

## Traps

- **Deleting the slot row instead of the button.** The single most destructive mistake available here. It removes the coordinate, and the next write reflows the board — the user presses their muscle-memory tile and says the wrong sentence to a stranger, mid-shutdown, with no way to verbally correct it. Delete the *button*; the setNull FK empties the slot in place.
- **Foreign keys are OFF unless the connection turns them on, and drift does not.** With FKs off, the `setNull` does not error — it silently does nothing. `button_id` keeps pointing at a deleted row and the tile renders blank forever. `PRAGMA foreign_keys = ON` belongs in `beforeOpen`, **unconditional** — putting it inside `if (details.wasCreated)` is correct for seeding and catastrophically wrong for a per-connection pragma. If the delete test passes but the pragma test fails, the delete test is lying.
- **Filtering hidden buttons in the `WHERE`.** `WHERE buttons.hidden = 0` on a left join also drops the slot row for every empty cell (NULL is not 0), silently returning fewer than `rows × cols` coordinates. Filter after the read, on the resolved button.
- **`readTable` vs `readTableOrNull` on the joined tables.** `readTable(_db.buttons)` on an empty slot throws at runtime — no compile error, no analyzer warning, and with no telemetry the first report is a person whose board went blank. Only the driving table (`grid_slots`) is safe with `readTable`.
- **Swapping label / vocalization / display_text.** Three `String`s, nothing in the type system distinguishing them. Backwards means a screen-reader user hears a whole paragraph on every scan step, or a stranger hears the wrong sentence. Resolve in one place and test with three distinct strings.
- **Skipping null-button rows while building the grid.** `results.where((r) => r.readTableOrNull(_db.buttons) != null)` looks like a tidy guard and collapses the grid — an empty cell must hold its space, never collapse.
- **Hardcoding 3×4.** `const kRows = 4` anywhere in this file makes the 2×3 large layout a v2 migration. Read `boards.grid_rows` / `boards.grid_cols`.
- **Adding a surrogate `id` or an `order` column to `grid_slots` because the join "would be easier".** That permits two rows claiming the same `(row_index, col_index)` and re-enables the exact failure this schema exists to prevent. If a change requires it, the change is wrong.
- **Reaching for an interface because "the repository should be swappable".** There is one environment, no network, no auth. A Map-backed fake would accept a row the real composite PK rejects and never execute a migration step — actively worse than no fake. The test seam is one `databaseProvider.overrideWithValue(db)`.
- **Making a method that a tap callback invokes return `Future`.** `onTap: () => repo.doThing()` is flagged by *neither* `discarded_futures` *nor* `unawaited_futures` — the arrow closure "returns" the Future so both lints think it is handled, but the target type is `VoidCallback`, so the Future **and its error** are dropped. That is the silence bug. The repository may return Futures (it is not a callback target); the fix lives in `BoardController`'s void methods. Do not let a widget wire a repository method directly to `onTap`.
- **Absolute media paths, or joining a relative one against the support dir.** The DB lives in the support directory, media lives relative to the documents directory. They are not interchangeable, and the wrong base fails silently, permanently, invisibly.
- **Optimistic in-memory state to "make the grid feel fast".** A local SQLite write is single-digit milliseconds; the revert path could never fire and is pure liability, and a state that appears then reverts is a visual change the user did not cause.

## Files

- Creates: `lib/data/board_repository.dart`
- Creates: `lib/model/tile.dart`, `lib/model/board_grid.dart` (the two hand-written model types; `@immutable` + `final class` by hand — no `freezed`)
- Creates: `test/data/board_repository_test.dart`
- Reads: `lib/data/app_database.dart` and its `.g.dart` (from E03-T01)

## Done when

`flutter test test/data/board_repository_test.dart` passes against real in-memory SQLite, proving a deleted tile empties its slot without moving anything else, and no file under `lib/ui/` imports `package:drift`.


---

## What actually happened

Repository built in the chain; tests added. watchGrid/readGrid/deleteTile/editTileText covered against a real in-memory DB (not a fake): a delete empties a coordinate and MOVES NO OTHER TILE, asserted per-cell not just by count. label/vocalization/display_text fall back independently, proved with three distinct strings.
