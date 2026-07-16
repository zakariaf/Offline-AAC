# E03 — Data layer

> Six tables where position is the primary key, two concrete repositories over them, a migration suite that proves rows survive a version bump, a file copy that survives the bug the suite did not anticipate, and twelve starter phrases that admit what they are.

| | |
|---|---|
| **Status** | Done — all 6 tasks |
| **Tasks** | 6 |
| **Depends on** | E01 (E03-T01 gates on E01-T03 — the schema cannot be snapshotted before the tooling that snapshots it exists) |

## Why this epic exists

Everything else in Reed can be rewritten. A board cannot. It is months of hand-curated phrases, it is unmergeable — there is no merge better than leaving someone's phrase alone — and it is their voice. There is no telemetry and no server, so if an upgrade copies zero rows, nobody ever finds out. The user opens the app mid-shutdown, sees an empty grid, and uninstalls. That is the entire feedback loop for a data-loss bug: silence, then absence.

The subtler failure is worse than the empty board. A migration that "works" but shifts every tile one position is green under every shape check, renders fine, and makes a person reaching for the tile that has been at (2,1) for a year say the wrong sentence out loud, at the worst possible moment, with no way to verbally correct it. That is why this epic's schema puts `(board_id, row_index, col_index)` in the primary key: reflow is not policed by application logic one forgotten `WHERE` clause from failing — it is made unrepresentable. And it is why `migrateAndValidate` passing is never the deliverable here. It diffs `CREATE` statements out of `sqlite_schema`. It has never looked at a row.

## What "done" means

- `dart run build_runner build --delete-conflicting-outputs && git diff --exit-code` exits 0; `drift_schemas/` holds a committed snapshot for `schemaVersion = 1` and `git diff --exit-code -- drift_schemas/` after a fresh `schema dump` exits 0.
- `grid_slots` has no surrogate `id`, no `order`/`position`/`index` column, and `Set<Column> get primaryKey => {boardId, rowIndex, colIndex}` — verified by a test that inserts a duplicate coordinate and expects a `SqliteException`.
- A test asserts `PRAGMA foreign_keys` returns `1` on an opened connection, and a paired test asserts that deleting a button NULLs its slot and moves nothing.
- `flutter test test/drift` passes: the every-pair shape loop, plus a content test per version pair that writes the torture fixture with era-correct v(n) classes, migrates, runs `PRAGMA foreign_key_check`, and reads back per coordinate with v(n+1) classes. Empty slots survive as empty slots.
- Four backup tests pass: backup happens strictly before `onUpgrade`, last-two retention evicts the oldest, restore round-trips the phrases byte for byte, restore works when the live DB is corrupt.
- `BoardRepository` is the only file outside `lib/data/database/` importing `package:drift`; a policy grep proves no widget does.
- `lib/data/seed/starter_phrases.dart` is a `const` Dart list of twelve entries, every one carrying a provenance comment and a date. No `pubspec.yaml` asset entry is involved.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E03-T01 | The drift schema | M | E01-T03 |
| E03-T02 | BoardRepository | M | E03-T01 |
| E03-T03 | SettingsRepository | S | E03-T01 |
| E03-T04 | Migration test harness | M | E03-T01 |
| E03-T05 | Database backup before upgrade | XS | E03-T01 |
| E03-T06 | Starter set with visible provenance | S | E03-T02 |

**E03-T01 — The drift schema.** The only task in the project where a decision becomes permanent the moment it ships. Six tables, Open Board Format field names, `grid_slots` keyed by position with a nullable `button_id`, the `label` / `vocalization` / `display_text` split adopted on day one even though `display_text` has no reader yet, `hidden` / `is_system` / `user_edited`, media as relative paths against the documents directory while the DB itself lives in the support directory. It carries the `beforeOpen` that runs `PRAGMA foreign_keys = ON` unconditionally — outside the `wasCreated` branch — and the v1 schema dump. Everything downstream in this epic is a consumer of the shape this task fixes.

**E03-T02 — BoardRepository.** The home for the one thing drift cannot generate: the join. `grid_slots ⟕ buttons ⟕ images` with two nullable FKs has no generated row class, so somebody unpacks `List<TypedResult>` with `readTable()` / `readTableOrNull()` and materializes `BoardGrid` — and that somebody is not a widget. It also owns the bounds check that SQL deliberately does not have, because `CHECK (row_index < 4)` would make the 2×3 layout a database-level insert failure at v2. Concrete class, no interface, tested against `NativeDatabase.memory()`. It blocks E05-T02 because the grid UI has nothing to render until `watchGrid` emits.

**E03-T03 — SettingsRepository.** Plain k/v over the `settings` table: `voice_id`, `pitch`, `rate`, `output_mode`, `theme`, `haptics`, `grid_size`. Small on purpose and listed separately on purpose — it blocks E08-T01, and the settings screen is not allowed to reach past it into drift. There is no `SettingsService` above it; the repository is already the generous version.

**E03-T04 — Migration test harness.** Written at `schemaVersion = 1`, when there are no migrations to test, because the alternative is writing it under pressure on the day a board is at stake. It lands the every-pair shape loop (so the v1→v3 skip path — the one a user who ignored updates for six months takes — cannot be forgotten at the next bump), the torture fixture, and the content test shape that later version pairs get cloned from. Its real subject is the gap: shape tests are necessary and never sufficient.

**E03-T05 — Database backup before upgrade.** XS, ~15 lines, and the highest safety-per-line item in the project — higher than every migration test in E03-T04 combined. Copy the `.sqlite` file before `onUpgrade` runs, keep the last two, expose "Restore previous board." The tests protect against the bugs somebody enumerated. This protects against the one nobody did, which with no telemetry is the entire invisible category. They are complements. A green suite is never a reason to skip this, and this is never a reason to skip the content test.

**E03-T06 — Starter set with visible provenance.** Twelve phrases as a `const` Dart list — not a JSON asset, because a missed `pubspec.yaml` entry makes first launch a silently empty board. Three of the twelve are attested in public sources ("too loud", "I need a break", "I want to go"); the rest are assumptions, and the task's actual deliverable is that every line says which it is and when it was written. It depends on E03-T02 rather than E03-T01 because seeding writes slots through the bounds-checked path, not raw inserts.

## Skills this epic draws on

**Schema and generation**
- `reed-drift-schema` — the six tables, the composite primary key, the three-field split and the 16-char label cap, `hidden` / `is_system` / `user_edited`, relative media paths, the two base directories, the `PRAGMA foreign_keys` placement.
- `reed-codegen-workflow` — `--delete-conflicting-outputs`, the `databases:` block, `make-migrations` and the vacuously-passing generated test it leaves behind.
- `reed-dart3-idioms` — `final class`, `sealed`, records and pattern matching in the join unpacking; no `freezed`.

**Migration and failure**
- `reed-migration-testing` — the row-blindness of `migrateAndValidate`, the every-pair loop, the torture fixture, `foreign_key_check`, the CI dump-and-diff gate, the four backup tests.
- `reed-error-model` — `assert` vs `Exception` vs sealed outcome around the backup and restore paths; asserts are stripped in release, so never assert on a file operation.

**Boundaries and wiring**
- `reed-layering-rules` — concrete repositories, no `lib/domain/`, no abstract interface over `BoardRepository`, no `AppDatabase` DAO wrapper, no Map-backed fake.
- `reed-riverpod-usage` — `databaseProvider` throwing by default, `boardRepositoryProvider`, `gridProvider` as a `StreamProvider` over `watchGrid`, `overrideWithValue` as the only test seam.
- `reed-async-rules` — cancelling `watchGrid()` subscriptions, closing sinks, no dropped Futures on a DB write.

**Content**
- `reed-vocabulary-rules` — the twelve phrases, the provenance-and-date requirement, `Wrong one` as the repair phrase, stock assignment scattered by category, the adult lexicon requirement.
- `reed-copy-voice` — the register of the provenance page: first person, named author, no reassurance, no byline that congratulates the user for editing.
- `reed-aac-audience` — who this is for and why a pre-filled board is presumptuous unless it says so.

## Sequencing

E03-T01 is a hard gate on everything else in the epic — five tasks fan out from it and none can start early, because each of them either queries the tables, snapshots them, copies the file they live in, or seeds them. It in turn cannot start before E01-T03, since the v1 dump is due in E03-T01's own commit and `drift_dev` cannot dump without `build.yaml`.

After T01, three tasks are genuinely parallel: T02, T03, and T04 touch different files and share nothing but the schema. T05 is parallel too and small enough to land first — do it early, not last, because the value of a backup is entirely in it existing before the first risky change, and "we'll add it when migrations start" is how it does not exist when migrations start. T06 waits on T02.

The critical path out of this epic runs E01-T03 → E03-T01 → E03-T02 → E05-T02. T03 → E08-T01 is a shorter, independent chain. T04, T05, and T06 block nothing downstream, which is exactly the trap: nothing will force them to happen, and they are three of the four reasons this epic is a gate.

## Risks specific to this epic

- **The green migration that copied zero rows.** `migrateAndValidate` compares `CREATE` statements. A perfect table rebuild with no `INSERT ... SELECT` passes it. Mitigated only by E03-T04's content test, and only if the lists in it are actually filled — `make-migrations` emits `// TODO: Fill these lists` and empty lists assert `[] == []` and pass.
- **The reflow that renders correctly.** Row-count assertions do not catch reordering. Every slot assertion looks up by `(rowIndex, colIndex)`, never by list index, and an empty slot is asserted to survive as empty rather than be backfilled by its neighbour.
- **A surrogate key added to `grid_slots` in a later "cleanup".** `autoIncrement()` will not compile alongside the `primaryKey` override — that compile error is the architecture defending itself, and the failure mode is somebody deleting the override to make it build.
- **FKs silently off.** SQLite does not enforce foreign keys unless told, per connection, on every open, and drift does not do it. The pragma is also a no-op inside a transaction — it does not error. Get it wrong and `onDelete: setNull` does nothing, `button_id` points at a deleted row forever, and the tile just renders blank.
- **The wrong base directory.** Media paths resolve against the documents directory; the DB file lives in the support directory. Join a media path to the support base and the row survives, the file survives, and the tile is blank forever with no error.
- **Fields swapped.** `label`, `vocalization`, and `display_text` are three `String`s the type system cannot tell apart. Backwards means a screen-reader user hears a paragraph per scan step, or a stranger hears the wrong sentence.
- **A default-set update touching `user_edited = 1`.** Any seed or migration step that "upgrades" a phrase the user has touched destroys ground truth. New content ships additive and opt-in, or not at all.
- **Test DB skew.** `flutter test` runs in a plain Dart VM where `sqlite3_flutter_libs` does nothing. Linux CI needs `libsqlite3-dev` installed before `flutter test`, or every test here fails and a stranger concludes the repo is broken.

## Out of scope

- **The tile widget, the grid layout, edit mode.** This epic emits `BoardGrid`; E05 renders it. No file here imports `package:flutter/material.dart`.
- **The 16-char label cap as a user-facing behaviour.** The schema states the cap; the editor *refusing* at 16 — never truncating — is E06's job.
- **`SpeechService` and anything about what gets spoken.** E04. The data layer only decides which string is the vocalization.
- **The settings screen.** E08-T01 consumes E03-T03; the widgets are not here.
- **The provenance page itself.** E03-T06 writes the phrases and their provenance comments; the static first-person page that shows who wrote them lives with the UI surfaces.
- **The CI schema-freshness gate.** The dump-and-diff step is E01-T04's file; this epic supplies the committed `drift_schemas/` it diffs against.
