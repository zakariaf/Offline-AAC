# E03-T01 — The drift schema

| | |
|---|---|
| **Epic** | E03 — Data layer |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E01-T03 |
| **Blocks** | E03-T02, E03-T03, E03-T04, E03-T05 |

**Skills:** `reed-drift-schema` · `reed-dart3-idioms` · `reed-codegen-workflow`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

This is the commit where three product rules stop being policy and become physics. `grid_slots` keyed by `(board_id, row_index, col_index)` with a nullable `button_id` makes reflow *unrepresentable* — a deleted tile leaves a hole where it was, so the tile next to it never moves and the user never presses a familiar square and says the wrong sentence out loud. The `label` / `vocalization` / `display_text` split has to land now, because retrofitting it once people have hand-curated boards is a migration against irreplaceable data. And `PRAGMA foreign_keys` is off by default and per-connection: forget it and the `setNull` that this whole schema leans on becomes a silent no-op.

## Scope

Six tables in `lib/data/database/tables.dart`: `boards`, `buttons`, `grid_slots`, `images`, `sounds`, `settings`. Field-name semantics borrowed from Open Board Format. `schemaVersion = 1`. The database class lives in `lib/data/database/app_database.dart`.

### grid_slots — position IS the primary key

```dart
class GridSlots extends Table {
  IntColumn get boardId => integer().references(Boards, #id, onDelete: KeyAction.cascade)();

  // `row` is a SQLite keyword and these are PK columns. Renaming a PK column
  // later is a TableMigration against live data. Name them right now.
  IntColumn get rowIndex => integer().named('row_index')();
  IntColumn get colIndex => integer().named('col_index')();

  IntColumn get buttonId =>
      integer().nullable().references(Buttons, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column> get primaryKey => {boardId, rowIndex, colIndex};
}
```

An empty cell is a row with `button_id IS NULL` — **not an absent row**. A board always holds exactly `grid_rows × grid_cols` slot rows. No surrogate `id`. No `order` / `position` / `index` column. Deleting a tile deletes from `buttons`; the slot survives, empty, in place:

```dart
// WRONG — deletes the cell, invites a reflow, loses the coordinate.
await (db.delete(db.gridSlots)..where((GridSlots s) => s.buttonId.equals(id))).go();

// RIGHT — the button goes; the slot survives, empty, in place.
await (db.delete(db.buttons)..where((Buttons b) => b.id.equals(id))).go();
```

### buttons — the three-string split

| Column | Meaning | Rule |
|---|---|---|
| `label` | what the tile **shows** | NOT NULL. Hard cap **16 characters** — the editor refuses at 16, never silently truncates |
| `vocalization` | what is **spoken** | Nullable, **uncapped**; NULL ⇒ fall back to `label` |
| `display_text` | what show-text mode **renders** | Nullable; NULL ⇒ `vocalization ?? label` |

Plus: `id`, `board_id`, `background_color`, `border_color`, `image_id` (nullable FK), `sound_id` (nullable FK), `load_board_id` (nullable, one level only), `hidden` (default 0), `is_system` (default 0), `user_edited` (default 0), `created_at`, `updated_at`.

`hidden = 1` is how content is removed. `is_system = 1` is the repair phrase — undeletable. There is no STOP tile. `user_edited = 1` is a hard stop: nothing may ever overwrite, upgrade or reconcile that row.

### The other four

- `boards`: `id`, `name`, `locale`, `grid_rows`, `grid_cols`, `is_root`, `created_at`, `updated_at`. Grid dimensions are **real columns** — a 2×3 crisis layout ships alongside the 3×4 phone default. No `const kRows = 4`, and no `CHECK (row_index < 4 AND col_index < 3)`: a CHECK makes the 2×3 layout a database-level insert failure. Bounds are enforced in `BoardRepository`, not in SQL.
- `images`: `id`, `path`, `content_type`, `width`, `height`, `license`, `attribution`. `sounds`: `id`, `path`, `content_type`, `duration_ms`. Never BLOBs. `path` is **relative to the app documents directory**, never absolute — an absolute path dies on reinstall/restore when the container UUID changes and the tile renders blank forever with no error.
- `settings`: plain k/v — `voice_id`, `pitch`, `rate`, `output_mode`, `theme`, `haptics`, `grid_size`. No `SettingsService`.

### Open, and the pragma

```dart
beforeOpen: (OpeningDetails details) async {
  await customStatement('PRAGMA foreign_keys = ON'); // UNCONDITIONAL
  if (details.wasCreated) { /* seed here — and ONLY here */ }
},
```

Storage location: `getApplicationSupportDirectory()`, **not** `getApplicationDocumentsDirectory()`. Media paths resolve against the *documents* dir through one helper; the DB file lives in *support*. Two bases, not interchangeable.

### build.yaml, at the repo root, this commit

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/data/database/app_database.dart
          test_dir: test/drift/          # default
          schema_dir: drift_schemas/     # default
```

Then:

```sh
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
```

Commit `drift_schemas/`, the `.g.dart` / `.drift.dart`, and add `.gitattributes`:

```
*.g.dart      linguist-generated=true
*.drift.dart  linguist-generated=true
```

Analyzer excludes in `analysis_options.yaml`: `**/*.g.dart`, `**/*.drift.dart`, `**/generated_plugin_registrant.dart`, `test/drift/generated/**`. **Check which suffix this drift config actually emits before writing the pattern** — modern drift emits `.drift.dart`, legacy part-file setups emit `.g.dart`.

Types follow `reed-dart3-idioms`: no `freezed`, no `equatable`. drift's generated row class **is** the domain model. The only two hand-written model types in the app are `BoardGrid` (a materialized `rows × cols` of `Tile?`) and the joined `Tile` — drift generates a class per table, never per join.

**Out of scope:** `BoardRepository` and the join unpacking (E03-T02), seed content in `lib/data/seed/starter_phrases.dart`, `media_store.dart` downscaling, `backup.dart`, migration tests (there are no migrations at `schemaVersion = 1`).

## Acceptance criteria

- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds and `git diff --exit-code -- '*.g.dart' '*.drift.dart'` is clean.
- [ ] `dart run drift_dev make-migrations` does **not** error with "No databases found in the build.yaml file".
- [ ] `drift_schemas/` contains a committed snapshot for `schemaVersion = 1`; re-running `schema dump` produces no diff.
- [ ] `flutter analyze --fatal-infos` is green.
- [ ] A test opens `NativeDatabase.memory()` and asserts `PRAGMA foreign_keys` returns `1`.
- [ ] A paired test inserts a full 3×4 board, deletes one button, and asserts: the slot row still exists at its `(row_index, col_index)`, its `button_id IS NULL`, the row count is still exactly `grid_rows × grid_cols`, and every other slot's `button_id` is unchanged.
- [ ] A test asserts inserting a second `grid_slots` row at an existing `(board_id, row_index, col_index)` fails.
- [ ] A test asserts a board row with `grid_rows = 2, grid_cols = 3` inserts and accepts slots at all six coordinates.
- [ ] `grep -rn "order\|position" lib/data/database/tables.dart` shows no such column on `GridSlots`.
- [ ] Tests run against real in-memory SQLite, never a Map-backed fake.

## Traps

- **`autoIncrement()` on `GridSlots` will not compile** next to the `primaryKey` override — it implies `PRIMARY KEY`. That compile error is the architecture defending itself. Do not "fix" it by dropping the override.
- **A surrogate `id` on `grid_slots` re-enables reflow silently.** Two rows can then claim the same `(row_index, col_index)`. No test and no crash report surfaces it; it manifests only as a real person saying the wrong sentence.
- **`PRAGMA foreign_keys = ON` inside `if (details.wasCreated)`** is the classic. Correct for seeding, catastrophic for a per-connection pragma — every subsequent open runs with FKs off, `setNull` becomes a silent no-op, `button_id` points at a deleted row, and the tile renders blank. Two tests, and they are a pair: one says *why*, one says *that*.
- **Naming the columns `row` / `col` now.** `row` is a SQLite keyword; both are PK columns; renaming a PK column later is a `TableMigration` against live user data.
- **Adding a `CHECK` on the indices** bakes the phone layout into the primary key's own table. SQLite `CHECK` cannot reference another table anyway, so it can only hardcode 3×4 — and the 2×3 layout becomes an insert failure at v2.
- **Storing an absolute media path.** Works on your device forever, dies on the user's reinstall. DB row survives, file survives, tile is blank, no error, no telemetry.
- **Skipping the split now.** Three `String`s are indistinguishable to the type system. Get them backwards and a screen-reader user hears a paragraph on every scan step. Add them on day one or pay a migration later.
- **Edit `tables.dart`, forget to bump `schemaVersion`, run `schema dump`** — it overwrites the v1 snapshot with the v2 shape and nothing errors. Not applicable yet at v1 in a positive sense, but the dump gate must exist from this commit so the trap is caught later. If a dump ever diffs a shipped snapshot, stop and reconcile — do not commit it.
- **Omitting `--delete-conflicting-outputs`** yields a wall of "conflicting outputs" text because every output is committed. That is not a bug to investigate.
- **`freezed`/`equatable` on top of drift.** A second generator on overlapping classes plus a hand-written row→model mapping layer, buying nothing drift does not already emit.

## Files

- `lib/data/database/tables.dart` (new)
- `lib/data/database/app_database.dart` (new)
- `build.yaml` (new, repo root)
- `.gitattributes` (new or changed)
- `analysis_options.yaml` (changed — exclusions)
- `drift_schemas/` (new, generated + committed)
- Generated `.g.dart` / `.drift.dart` under `lib/data/database/` (committed)
- Schema tests under `test/` (new)

## Done when

The six tables exist at `schemaVersion = 1` with the v1 snapshot committed, `PRAGMA foreign_keys` is proven on by test, and deleting a button provably nulls its slot while moving nothing.
