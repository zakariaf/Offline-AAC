---
name: reed-drift-schema
description: Reed's drift schema and its invariants — grid_slots keyed by (board_id, row_index, col_index) with a nullable button_id, the label/vocalization/display_text split, hidden and user_edited, relative media paths, PRAGMA foreign_keys. Use when adding or altering a table or column, defining a drift Table subclass or Companion, writing a select/join/insert/update/delete against boards, buttons or grid_slots, deleting or hiding a tile, or reviewing a data-layer diff. Not for running codegen or writing the migration's tests.
---

# Reed schema invariants

Six tables: `boards`, `buttons`, `grid_slots`, `images`, `sounds`, `settings`. Borrow Open Board Format semantics for field names. The schema is not storage — it is where three product rules are made unrepresentable rather than merely policed. Preserve them in that spirit.

Context that justifies every rule below: this app has **no telemetry and never will**. A user who cannot speak does not file a bug report. Nothing will ever tell anyone the data layer failed. A botched migration is the loss of months of hand-curated phrases — someone's voice, irreplaceable and unmergeable.

## 1. Position IS the primary key

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

`PRIMARY KEY (board_id, row_index, col_index)` with a **nullable** `button_id`. An empty cell is a row with `button_id IS NULL` — **not an absent row**. Deleting a tile writes NULL into its slot.

Why this is not a normalization mistake: position-based muscle memory is the retrieval channel most likely to survive a shutdown. A tile that **moves** is worse than a tile that is **missing** — the user presses it and says the wrong sentence at the worst possible moment. Every ordered-list schema eventually reflows: a delete shifts everything up, and the defence is application logic one forgotten `WHERE` clause from failing silently. With position as the key there is no ordering to recompute, so reflow is not prevented — it is **unrepresentable**. That is the only kind of guarantee that survives 2am.

**Never add a surrogate `id` to `grid_slots`. Never add an `order`, `position`, or `index` column.** That single change permits two rows claiming the same `(row_index, col_index)` and quietly re-enables the exact failure this schema exists to prevent. No test and no crash report will surface it; it manifests only as a real person saying the wrong sentence out loud. If a change requires a surrogate key on this table, the change is wrong.

`autoIncrement()` implies `PRIMARY KEY` and **will not compile** alongside a `primaryKey` override. That compile error is the architecture defending itself. Do not work around it by dropping the override.

**Deleting always means: write NULL to the slot.**

```dart
// WRONG — deletes the cell, invites a reflow, loses the coordinate.
await (db.delete(db.gridSlots)..where((GridSlots s) => s.buttonId.equals(id))).go();

// RIGHT — the button goes; the slot survives, empty, in place.
await (db.delete(db.buttons)..where((Buttons b) => b.id.equals(id))).go();
// grid_slots.button_id becomes NULL via onDelete: setNull. Nothing moves.
```

A board always holds exactly `grid_rows × grid_cols` slot rows — full ones and empty ones. Any query that returns fewer than that has lost a coordinate.

## 2. The grid is NOT hardcoded 3×4

`boards.grid_rows` and `boards.grid_cols` are real columns; `settings` carries a `grid_size` key. A 2×3 crisis/large layout (~180dp tiles) ships alongside the 3×4 phone default. So:

- Never write `const kRows = 4` and never write `CHECK (row_index < 4 AND col_index < 3)`. A CHECK bakes the phone layout into the primary key's own table and makes the 2×3 layout a **database-level insert failure** — the exact migration to avoid at v2.
- Bounds come from the board row and are enforced in `BoardRepository`, not in SQL. (SQLite `CHECK` cannot reference another table anyway.)

`BoardGrid` (a materialized `rows × cols` of `Tile?`) and the joined `Tile` are the **only two hand-written model types** in the app. Everything persisted uses drift's generated row class directly — it IS the domain model. drift generates a class per table and never per join, and a displayable tile is `grid_slots ⟕ buttons ⟕ images` with two nullable FKs; unpack `List<TypedResult>` with `readTable()` / `readTableOrNull()` inside `BoardRepository`. Never in a widget — no widget imports `package:drift`.

## 3. label ≠ vocalization ≠ display_text

| Column | Meaning | Rule |
|---|---|---|
| `buttons.label` | what the tile **shows** | NOT NULL. Hard cap **16 characters** — the editor refuses at 16 and never silently truncates |
| `buttons.vocalization` | what is **spoken** | Nullable, **uncapped**; NULL ⇒ fall back to `label` |
| `buttons.display_text` | what show-text mode **renders** | Nullable; NULL ⇒ `vocalization ?? label` |

The tile shows `Overwhelmed`; it speaks `I need to leave, I'm not able to talk right now`. Nothing in the type system distinguishes three `String`s, so getting them backwards means a screen-reader user hears a paragraph on every scan step, or a stranger hears the wrong sentence. Adopt all three fields on day one — retrofitting them after users have customised boards is a painful migration.

The 16-char cap exists because the tile is a **handle** for an utterance, not the utterance; that is what makes "never truncate, never ellipsize" safe. An ellipsis on an AAC utterance is a *different utterance*.

## 4. Hide, never delete. Never overwrite user edits.

| Column | Default | Rule |
|---|---|---|
| `buttons.hidden` | 0 | Hide a tile by setting `hidden = 1`. Removing content is not a reason to destroy it |
| `buttons.is_system` | 0 | The repair phrase. Undeletable. There is no STOP tile — the lit tile is the stop control, and repair is a phrase the user says, not a button the app supplies |
| `buttons.user_edited` | 0 | Set to 1 the moment the user touches a tile |

`user_edited = 1` is a **hard stop**: never overwrite, "upgrade", or reconcile a tile the user has touched, in a migration, in a seed step, or in a default-set update. Ship new default content as **additive, opt-in, and clearly separate** — a new board or new slots the user chooses. User data is unmergeable ground truth; there is no merge that is better than leaving their phrase alone.

Seeds live in `lib/data/seed/starter_phrases.dart` as a `const` Dart list, **not a JSON asset** — a missed `pubspec.yaml` entry would make first launch an empty board, silently.

Other columns worth knowing: `buttons` also carries `board_id`, `background_color`, `border_color`, `image_id` (nullable FK), `sound_id` (nullable FK), `load_board_id` (nullable, one level only), `created_at`, `updated_at`. `boards`: `id`, `name`, `locale`, `grid_rows`, `grid_cols`, `is_root`, `created_at`, `updated_at`. `settings` is plain k/v: `voice_id`, `pitch`, `rate`, `output_mode`, `theme`, `haptics`, `grid_size` — no `SettingsService`; `SettingsRepository` is already generous.

## 5. Images and sounds are FILES ON DISK — paths RELATIVE

`images`: `id`, `path`, `content_type`, `width`, `height`, `license`, `attribution` (symbol-set attribution lives here). `sounds`: `id`, `path`, `content_type`, `duration_ms`.

Never store BLOBs. Files-with-paths mirror Open Board Format, allow per-directory backup exclusion (impossible for rows inside one DB file), keep the DB small, and Flutter's image cache erases the read-speed difference after first paint.

**Store the path RELATIVE to the app documents directory. Never absolute.** An absolute path dies on iOS reinstall or restore, because the app container UUID changes — the DB row survives, the file survives, and the tile renders blank forever with no error and no telemetry. Resolve to absolute only at read time, by joining the current documents dir.

**Two different base directories are in play, deliberately — do not join a path against the wrong one.** Media files are relative to the *documents* directory. The database file itself lives in the *support* directory (see the storage section below). They are not interchangeable, and an absolute path built from the wrong base fails exactly the way described above: silently, permanently, invisibly. Resolve media through one helper that owns the documents base, and never hand-build a media path anywhere else.

```dart
// WRONG — dead after the next restore.
await db.into(db.images).insert(ImagesCompanion.insert(path: file.path));

// RIGHT — durable across reinstall.
final String rel = p.relative(file.path, from: docsDir.path);
await db.into(db.images).insert(ImagesCompanion.insert(path: rel));
```

Downscale photos **at import** in `media_store.dart`: ≤512px, JPEG q80, ~30–60KB. A 4MB camera original destroys the export story.

## 6. Foreign keys are OFF by default, per connection

SQLite does not enforce foreign keys unless told to — **per connection, on every open** — and drift does not do it. This is the load-bearing footgun of this schema.

`grid_slots.button_id` is a nullable FK whose **entire purpose** is `onDelete: KeyAction.setNull`. With FKs off, SQLite does not error — it **silently does nothing**. `button_id` keeps pointing at a deleted row, the tile renders blank or the join throws, and nobody ever finds out.

```dart
beforeOpen: (OpeningDetails details) async {
  await customStatement('PRAGMA foreign_keys = ON'); // UNCONDITIONAL
  if (details.wasCreated) { /* seed here — and ONLY here */ }
},
```

Putting the pragma inside `if (details.wasCreated)` is correct for seeding and catastrophically wrong for a per-connection pragma. During migration, toggle the pragma **outside any transaction** — it is a silent no-op while a `BEGIN`/`SAVEPOINT` is pending — and run `PRAGMA foreign_key_check` afterwards to prove nothing was corrupted while enforcement was off.

Two tests, and they are a pair: one asserts `PRAGMA foreign_keys` returns `1` (tells you *why* it broke); one asserts that deleting a button nulls its slot and **moves nothing** (tells you *that* it broke).

## 7. Where the data lives

`getApplicationSupportDirectory()`, **not** `getApplicationDocumentsDirectory()`. Backed up like Documents, but not user-visible in Files — correct for an internal DB.

## 8. Migrations

`build.yaml` declares the database so `dart run drift_dev make-migrations` emits schema JSONs, the `stepByStep` helper, and migration tests in one command. Defaults are already right (`schema_dir: drift_schemas`, `test_dir: test/drift`); only `databases:` needs declaring. Commit `drift_schemas/` and the `.g.dart` — schema deltas become a reviewable diff.

- Dump the schema at commit #1, before there is user data to lose. At `schemaVersion = 1` there are no migrations to test.
- **`migrateAndValidate` is blind to rows.** It compares `CREATE` statements from `sqlite_schema`. A migration that rebuilds `grid_slots` perfectly and copies **zero rows** passes it, green. Data survival requires `verifier.schemaAt(n)` plus `--data-classes --companions`, writing real rows with old-era classes and asserting content with new-era ones. Assert that an empty slot survives as an empty slot — not vanished, not collapsed, not backfilled by its neighbour.
- Test against real in-memory SQLite (`NativeDatabase.memory()`), never a Map-backed fake. A fake happily accepts a row the real composite PK rejects and never executes a migration step.
- **`backup.dart` outranks all of it.** Copy the `.sqlite` file before `onUpgrade` runs, keep the last two, expose "Restore previous board." ~15 lines. Migration tests protect against enumerated bugs; the backup protects against the one nobody enumerated — which, with no telemetry, is the entire invisible category.
