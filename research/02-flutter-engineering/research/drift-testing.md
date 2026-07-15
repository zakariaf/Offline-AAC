# drift-testing

> Phase: **research** · Agent `a94b101060758056b` · Run `wf_12b14467-451`

## Result

## Summary

drift is at 2.34.2 (July 2026) and its migration tooling has consolidated around one command — `dart run drift_dev make-migrations` — driven by a `databases:` block in build.yaml. That command exports schema JSONs, generates `database.steps.dart` (the `stepByStep` helper), AND generates migration tests, replacing the older manual `schema dump` / `schema steps` / `schema generate` triad. Use it; it is the single highest-leverage practice for this dimension. Crucially, drift DOES have first-class data-integrity migration testing, and it is not `migrateAndValidate` — that only checks schema shape. The real mechanism is `verifier.schemaAt(n)` plus `--data-classes --companions`, which generates `DatabaseAtV1`/`DatabaseAtV2` classes so a test can insert real phrase rows at v1, migrate, then read them back at v2 and assert content. For an app where a botched migration is the loss of someone's voice, `migrateAndValidate` alone is insufficient and `schemaAt` is mandatory. The biggest correctness footgun for THIS schema is that SQLite foreign keys are OFF by default and are per-connection — drift does not enable them. Since `grid_slots.button_id` is a nullable FK, `onDelete: KeyAction.setNull` is what makes "delete a button, its slot goes blank but does not reflow" work; with FKs off that silently degrades to a dangling button_id and a blank-or-crashing tile, which is exactly the silent-failure class this project fears. Enable them unconditionally in `beforeOpen` and write a test asserting `PRAGMA foreign_keys` returns 1. Two decisions are v1-only and effectively irreversible-without-pain: DateTime storage mode (`store_date_time_values_as_text`) and committing `drift_schemas/*.json`. On the skip side: DriftIsolate/`computeWithDriftIsolate` is unjustifiable ceremony for 12 tiles — use `drift_flutter`'s `driftDatabase(name:)` one-liner and move on.

### drift is at 2.34.2 as of July 2026; drift_flutter exists and is at 0.3.1

*Confidence: high, **LOAD-BEARING***

drift 2.34.2 published within the last day of research. drift_flutter 0.3.1 is a thin Flutter-only wrapper providing a single `driftDatabase(name: 'app_db')` helper that handles path_provider + platform selection (application documents dir, .sqlite file on native). It exists precisely because core drift is Dart-only and cannot depend on Flutter. Optional `native: DriftNativeOptions(shareAcrossIsolates: true)` for multi-isolate apps.

- https://pub.dev/packages/drift

- https://pub.dev/packages/drift_flutter

### `make-migrations` is the current recommended workflow and supersedes manually running schema dump/steps/generate

*Confidence: high, **LOAD-BEARING***

Requires build.yaml: `targets: $default: builders: drift_dev: options: databases: {my_database: lib/database.dart}, test_dir: test/drift/, schema_dir: drift_schemas/`. Then `dart run drift_dev make-migrations` generates drift_schemas/drift_schema_vX.json, test/drift/ migration tests, and database.steps.dart next to the database class. Docs state plainly: 'Writing migrations manually is error-prone and can lead to data loss.' Workflow: run once for baseline, change schema, bump schemaVersion, run again, implement the generated stepByStep callbacks, run generated tests. `--no-test` disables test generation (do not use it here).

- https://drift.simonbinder.eu/migrations/

- https://drift.simonbinder.eu/migrations/exports/

### `migrateAndValidate()` validates SCHEMA SHAPE ONLY — it does not prove the user's data survived

*Confidence: high, **LOAD-BEARING***

`verifier.startAt(n)` returns a connection at version n; `verifier.migrateAndValidate(db, target)` runs the migration and asserts the resulting schema matches the exported v-target schema. It says nothing about row contents. A migration that recreates a table correctly but drops every row PASSES migrateAndValidate. For this project that is the difference between a green test suite and a user with an empty board.

- https://drift.simonbinder.eu/migrations/tests/

### Data-integrity migration testing DOES exist: `verifier.schemaAt(n)` + `schema generate --data-classes --companions`

*Confidence: high, **LOAD-BEARING***

THE mechanism the task asked about. `dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/generated_migrations/` emits schema_v1.dart, schema_v2.dart… each containing a full versioned database class (`DatabaseAtV1`) with era-correct data classes and companions. Test pattern: `final schema = await verifier.schemaAt(1);` then `v1.DatabaseAtV1(schema.newConnection())` to INSERT real rows, close, open the real `AppDatabase(schema.newConnection())`, `migrateAndValidate(db, 2)`, close, then reopen as `v2.DatabaseAtV2(schema.newConnection())` and assert the rows are present AND correct. Note `schemaAt` (not `startAt`) is the entry point — `schema.newConnection()` can be called repeatedly against the same underlying database, which is what lets three different-era database objects see the same bytes.

- https://drift.simonbinder.eu/migrations/tests/

### SQLite foreign keys are OFF by default and drift does not turn them on; the setting is per-connection

*Confidence: high, **LOAD-BEARING***

`PRAGMA foreign_keys = ON` must be issued on every connection, every open. Drift's `beforeOpen` is the sanctioned place. This is the load-bearing footgun for THIS schema: grid_slots.button_id is a nullable FK whose whole purpose is `onDelete: KeyAction.setNull` (delete a button → its slot blanks, position preserved, no reflow). With FKs off, SQLite silently ignores the action, button_id keeps pointing at a deleted row, and the tile renders blank or throws on join — a silent failure in a no-telemetry app.

- https://drift.simonbinder.eu/migrations/api/

- https://github.com/simolus3/drift/issues/163

- https://nicolaiarocci.com/sqlite-foreign-key-constraints-are-disabled-by-default/

### The official docs' own beforeOpen example is a trap: it shows the FK pragma inside an `if (details.wasCreated)` guard

*Confidence: medium, **LOAD-BEARING***

The migrations overview page renders `beforeOpen: (details) async { if (details.wasCreated) { await customStatement('PRAGMA foreign_keys = ON'); } }`. The `wasCreated` guard is correct for SEEDING data but wrong for a per-connection pragma — copied verbatim, FKs would be enforced only on the very first app launch and off forever after. Put the pragma unconditionally in beforeOpen; put seeding inside the wasCreated guard.

- https://drift.simonbinder.eu/docs/migrations/

- https://drift.simonbinder.eu/migrations/api/

### `PRAGMA foreign_keys` is a silent no-op inside a transaction, so FK-disabling during migration must happen outside it

*Confidence: high, **LOAD-BEARING***

SQLite: 'foreign key constraint enforcement may only be enabled or disabled when there is no pending BEGIN or SAVEPOINT.' It does not error — it does nothing. Drift docs' pattern: `await customStatement('PRAGMA foreign_keys = OFF'); await transaction(() async { /* migration */ }); await customStatement('PRAGMA foreign_keys = ON');`. This matters because `alterTable`/TableMigration works by create-copy-drop-rename, which FK enforcement would reject mid-flight. Docs recommend `PRAGMA foreign_key_check` after the migration to assert nothing was corrupted while enforcement was off.

- https://drift.simonbinder.eu/migrations/api/

- https://sqlite.org/forum/info/fd0b2d53bafc73f888069b3a0a3b15f35982c7e3fa910983b47db3e39ccabe18

### `stepByStep` / `Migrator.runMigrationSteps` API verified

*Confidence: high, **LOAD-BEARING***

Two forms. Terse: `onUpgrade: stepByStep(from1To2: (m, schema) async { await m.addColumn(schema.users, schema.users.birthdate); })`. Controllable: `onUpgrade: (m, from, to) async { ...pragma off...; await m.runMigrationSteps(from: from, to: to, steps: migrationSteps(from1To2: ...)); ...pragma on...; }`. Both from `database.steps.dart`. The second form is required for this project because of the FK-pragma bracket. Each callback receives a `schema` object frozen at that version, so migrations keep compiling even after tables are later deleted — this is why stepByStep beats hand-written onUpgrade for a project that must survive abandonment.

- https://drift.simonbinder.eu/migrations/step_by_step/

### TableMigration/alterTable handles what SQLite's ALTER TABLE cannot, via columnTransformer and newColumns

*Confidence: high*

`m.alterTable(TableMigration(schema.todos, columnTransformer: {schema.t.col: <SQL expression>}, newColumns: [schema.t.newCol]))`. columnTransformer maps a column to an expression evaluated against the OLD table during the copy (e.g. `schema.todos.category.cast<int>()`); newColumns declares non-nullable columns with no default that need a value for existing rows (`Constant('value for existing rows')`). Simple cases have direct APIs: `m.addColumn`, `m.createTable`, `m.deleteTable('users')`, `m.renameColumn(schema.t, 'old_name', schema.t.newCol)`.

- https://drift.simonbinder.eu/migrations/api/

### DateTime storage mode is a v1-only decision; changing it later is a real data migration

*Confidence: high, **LOAD-BEARING***

drift stores DateTime as unix timestamps by default; `store_date_time_values_as_text: true` in build.yaml switches to ISO-8601 text. Docs: toggling it 'is not compatible with existing database schemas' and requires a dedicated migration method + schemaVersion bump. There is even a recent drift_dev bugfix for schema exports ignoring this flag when Dart tables have default constraints — i.e. this option has had tooling sharp edges. Decide at v1 and never touch it.

- https://drift.simonbinder.eu/guides/datetime-migrations/

- https://pub.dev/packages/drift_dev/changelog

### In-memory test idiom requires `closeStreamsSynchronously: true` for widget tests

*Confidence: high, **LOAD-BEARING***

`AppDatabase(DatabaseConnection(NativeDatabase.memory(logStatements: true), closeStreamsSynchronously: true))` in setUp, `tearDown(() => database.close())`. Docs: 'By default, unsubscribing from a query stream created by drift will keep the stream open for one event loop iteration' — which trips widget tests with pending-timer errors. Stream testing: `expectLater(db.watchX(id).map(...), emitsInOrder(['first', 'changed']))` assigned to a variable BEFORE the mutating call, awaited after. Requires the database constructor to take an explicit QueryExecutor (`AppDatabase(super.e)`) rather than hardcoding one.

- https://drift.simonbinder.eu/testing/

### Opening the real AppDatabase in tests (not a bare connection) is what makes beforeOpen — and therefore FK enforcement — apply in tests

*Confidence: medium, **LOAD-BEARING***

beforeOpen is part of MigrationStrategy and runs on every open including NativeDatabase.memory(). So constructing the real AppDatabase in tests means tests run with the same FK enforcement as production. Testing against a hand-built raw connection would silently skip it and let FK-violating tests pass. This is a small architectural point with outsized value for a no-telemetry app.

- https://drift.simonbinder.eu/testing/

- https://drift.simonbinder.eu/migrations/api/

### `validateDatabaseSchema()` exists for runtime schema checking but importing it into lib/ promotes drift_dev to a real dependency

*Confidence: medium*

Docs show `beforeOpen: (details) async { if (kDebugMode) await validateDatabaseSchema(); }` with `import 'package:drift_dev/api/migrations_native.dart'`. It catches the classic 'I edited tables but forgot to bump schemaVersion' bug. But drift_dev belongs in dev_dependencies; importing it from lib/ (even under kDebugMode, which is a runtime not compile-time guard) makes it a shipped dependency. Prefer asserting this in a test instead.

- https://drift.simonbinder.eu/migrations/tests/

### Background isolates are explicitly not warranted at this scale

*Confidence: high, **LOAD-BEARING***

`NativeDatabase.createInBackground(file)` is the drop-in DriftIsolate wrapper. But drift's own docs say the tradeoff is real: 'the overall database is going to be slightly slower due to overhead involved in sending data between isolates, and if you're not running into dropped frames because of drift, using a background isolate is probably not necessary.' 12 tiles + a settings row will never drop a frame. Additionally `shareAcrossIsolates: true` is unnecessary here specifically because the Android QS TileService speaks from SharedPreferences with no Flutter engine — it never touches the DB, so there is no second isolate contending for it.

- https://drift.simonbinder.eu/isolates/

- https://pub.dev/packages/drift_flutter

### Storing absolute file paths for images/sounds breaks on iOS reinstall and restore

*Confidence: medium, **LOAD-BEARING***

The decision to keep images/sounds as files on disk with paths in the DB is right, but the iOS app container directory carries a UUID that changes across reinstall and device restore. An absolute path persisted in v1 becomes a dead path later — a tile with a missing image, silently. Store paths RELATIVE to the application documents directory and resolve against path_provider at read time. Not drift-specific, but it is a data-model decision that drift will faithfully persist forever.

- https://pub.dev/packages/drift_flutter

### `row` is a SQLite keyword; naming grid_slots columns `row`/`col` bare invites escaping trouble

*Confidence: medium*

Drift derives snake_case SQL column names from getter names and escapes known keywords, but ROW is a SQLite keyword (FOR EACH ROW) and this column sits in the composite PRIMARY KEY that the entire no-reflow guarantee rests on. The cost of naming them row_index/col_index is zero; the cost of being wrong is a schema you cannot cleanly migrate. Use `late final rowIndex = integer().named('row_index')()`.

- https://drift.simonbinder.eu/dart_api/tables/

### `autoIncrement()` implies PRIMARY KEY and cannot be combined with a `primaryKey` override

*Confidence: high, **LOAD-BEARING***

Composite PK is expressed as `@override Set<Column> get primaryKey => {boardId, rowIndex, colIndex};` — so GridSlots must NOT have an autoIncrement id. This is exactly what the project wants (position IS the key) but it is a compile-time conflict people hit when they add a surrogate id 'just in case'. Adding one later would destroy the structural no-reflow guarantee.

- https://drift.simonbinder.eu/dart_api/tables/

### Class-based Dart table definitions are the right style here over .drift files

*Confidence: medium*

Drift supports Dart classes, .drift SQL files, and mixes. Schema export, make-migrations, stepByStep and SchemaVerifier all work with either. Dart classes win on the project's own stated criterion — readable by a stranger — because a Flutter dev picking this up in 2028 reads Dart fluently and may never have seen drift's SQL dialect. `references(Buttons, #id, onDelete: KeyAction.setNull)` is also more self-documenting than a raw FK clause.

- https://drift.simonbinder.eu/dart_api/tables/

## Recommendations

- **[must]** Adopt `dart run drift_dev make-migrations` from commit #1, before there is any user data to lose. Add the `databases:`/`test_dir:`/`schema_dir:` block to build.yaml now.
  - It generates schema exports, the stepByStep helper, AND migration tests in one command. Retrofitting it after v1 ships means reconstructing a v1 schema JSON from memory — drift's own docs call manual migrations 'error-prone and can lead to data loss'. This is a two-minute setup that buys the entire safety net.
- **[must]** Commit `drift_schemas/*.json` to git. They are not regenerable from current source — they encode history.
  - `schema dump` reads the CURRENT database.dart. Once you have bumped to v2, the v1 JSON can never be regenerated from source; it exists only in git. Losing drift_schema_v1.json means you can no longer test the v1→v2 migration, which is the migration that real users on the App Store will actually run.
- **[must]** Enable `PRAGMA foreign_keys = ON` unconditionally in `beforeOpen`, NOT inside an `if (details.wasCreated)` guard, and assert it with a test.
  - FKs are off by default and per-connection. The docs' own example shows the pragma inside a wasCreated guard, which would enforce FKs only on first launch. Without FKs, `onDelete: KeyAction.setNull` on grid_slots.button_id silently does nothing and deleted buttons leave dangling ids — a blank tile with no error, in an app with no telemetry to report it.
- **[must]** Test that DATA survives every migration using `verifier.schemaAt(n)` + `--data-classes --companions`, not just `migrateAndValidate`.
  - migrateAndValidate checks schema shape only. A migration that rebuilds grid_slots perfectly but copies zero rows passes it. Given that hand-curated boards are irreplaceable and unmergeable, the assertion that must be green is 'the phrase text is still there and still correct', which only the schemaAt + versioned-data-class pattern can express.
- **[must]** Bracket `runMigrationSteps` with `PRAGMA foreign_keys = OFF` OUTSIDE any transaction, and run `PRAGMA foreign_key_check` afterwards, throwing if it returns rows.
  - The pragma is a silent no-op inside a transaction, so a naive placement fails invisibly. TableMigration works by create-copy-drop-rename, which live FK enforcement rejects. foreign_key_check is the only thing that proves you did not corrupt referential integrity while enforcement was off — and in this app a broken board_id link is a lost board.
- **[must]** Decide DateTime storage mode (`store_date_time_values_as_text`) at v1 and never change it.
  - Drift docs state toggling it is incompatible with existing schemas and requires a dedicated data migration plus version bump. It is a free decision today and an expensive, data-touching one after ship. Given the app barely needs timestamps at all, pick the default (unix) and stop thinking about it.
- **[must]** Give AppDatabase an explicit QueryExecutor constructor (`AppDatabase(super.e)`) and construct the REAL AppDatabase in tests over `NativeDatabase.memory()` with `closeStreamsSynchronously: true`.
  - Tests must exercise the real MigrationStrategy so beforeOpen — and therefore FK enforcement — applies. Testing against a bare connection would skip beforeOpen and let FK-violating code pass green. closeStreamsSynchronously avoids pending-timer failures in widget tests.
- **[must]** Write the three invariant tests that encode this project's architecture: (a) PRAGMA foreign_keys == 1, (b) two buttons cannot occupy one slot, (c) deleting a button nulls its slot without moving any other slot.
  - These are not hygiene tests, they are the executable statement of 'tile reflow is structurally impossible'. Test (c) in particular fails loudly if FKs are ever off — it converts the worst silent failure in the schema into a red test. With no telemetry, a test is the only thing that will ever tell you.
- **[should]** Use `drift_flutter`'s `driftDatabase(name: 'aac')` to open the DB. Skip DriftIsolate, computeWithDriftIsolate, and shareAcrossIsolates entirely.
  - Drift's own docs say a background isolate is unnecessary if you are not dropping frames because of the DB, and 12 tiles will never drop a frame. shareAcrossIsolates is specifically moot here because the Android QS TileService speaks from SharedPreferences with no Flutter engine and never opens the database. This is ceremony a solo dev on a 2-week MVP should decline.
- **[must]** Store image/sound paths RELATIVE to the application documents directory; resolve against path_provider at read time.
  - The iOS app container UUID changes on reinstall and on device restore, so an absolute path persisted today is a dead path after a user restores their phone. That surfaces as a tile whose image silently vanished — and unlike a crash, nothing about it is recoverable or even noticeable to the developer.
- **[should]** Name the grid_slots position columns `row_index`/`col_index`, not `row`/`col`.
  - ROW is a SQLite keyword, and these columns are the composite PRIMARY KEY the entire no-reflow guarantee rests on. Zero cost to rename now; renaming a PK column later is a TableMigration against live user data.
- **[should]** Commit the generated `.g.dart` / `.steps.dart` files rather than gitignoring them.
  - Standard Dart convention gitignores generated code, but this project's exit plan is abandonment plus open-source. In 2029, `dart run build_runner build` against a stale pubspec may simply not resolve. Committed generated files mean a stranger can clone and build with no codegen step at all. The usual argument against (merge conflicts on a team) does not apply to a solo dev.
- **[should]** Put `validateDatabaseSchema()` in a test, not in `beforeOpen` behind kDebugMode.
  - It catches the 'edited tables, forgot to bump schemaVersion' bug, which is worth catching. But it lives in package:drift_dev, and importing it from lib/ promotes a dev_dependency into a shipped dependency — kDebugMode is a runtime guard, not a compile-time one. A test gets the same signal with none of the dependency creep.
- **[should]** Use class-based Dart table definitions; do not introduce .drift SQL files.
  - All migration tooling works with either, so pick on the project's own criterion: readable by a stranger. A Flutter dev inheriting this reads Dart; they may never have seen drift's SQL dialect. `references(Buttons, #id, onDelete: KeyAction.setNull)` documents the no-reflow intent better than a raw FK clause.
- **[avoid]** Do not add a surrogate autoIncrement id to GridSlots.
  - autoIncrement() implies PRIMARY KEY and cannot coexist with the composite primaryKey override — so it will not even compile. But the deeper reason is that a surrogate key would permit two rows at the same (board_id, row, col), destroying the structural guarantee that position IS identity. The compile error is the architecture defending itself; do not work around it.
- **[avoid]** Do not hand-write `onUpgrade` with `if (from < 2)` chains, even though the docs still show that style.
  - The docs show it, and it works, but each branch references CURRENT table definitions — so deleting a table in v4 breaks the v1→v2 branch's compilation, and developers 'fix' that by editing history, which silently changes what old users' migrations do. stepByStep hands each callback a schema frozen at that version, making old migrations immutable. That property matters most precisely when the developer has stopped paying attention.

### build.yaml — enables make-migrations (do this first)

```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/data/database.dart
          test_dir: test/drift/
          schema_dir: drift_schemas/
          # DateTime storage: decide at v1, never change.
          # Omitted = unix timestamps (the default). Correct for this app.
```

Then: `dart run drift_dev make-migrations`. Commit drift_schemas/ — the v1 JSON can never be regenerated once you bump to v2.

### Table definitions matching this project's schema

```dart
import 'package:drift/drift.dart';

part 'database.g.dart';

class Boards extends Table {
  late final id = integer().autoIncrement()();
  late final name = text().withLength(min: 1, max: 100)();
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
}

/// Open Board Format semantics: `label` is what the tile SHOWS,
/// `vocalization` is what it SPEAKS. They are deliberately different.
/// Tile shows "Overwhelmed"; TTS says "I need to leave, I'm not able
/// to talk right now." If vocalization is null, speak the label.
class Buttons extends Table {
  late final id = integer().autoIncrement()();
  late final label = text().withLength(min: 1, max: 200)();
  late final vocalization = text().nullable()();
  late final imageId =
      integer().nullable().references(Images, #id, onDelete: KeyAction.setNull)();
  late final soundId =
      integer().nullable().references(Sounds, #id, onDelete: KeyAction.setNull)();
  late final backgroundColor = integer().nullable()();
}

/// Position IS identity. The composite primary key makes it structurally
/// impossible for a tile to move: there is no row identity independent of
/// (board, row, col), so nothing can reflow.
///
/// button_id is NULLABLE + ON DELETE SET NULL: deleting a button empties
/// its slot and leaves every other slot untouched.
/// NOTE: this depends entirely on PRAGMA foreign_keys = ON. See beforeOpen.
class GridSlots extends Table {
  late final boardId =
      integer().references(Boards, #id, onDelete: KeyAction.cascade)();
  // Named explicitly: `row` is a SQLite keyword and these columns are the PK.
  late final rowIndex = integer().named('row_index')();
  late final colIndex = integer().named('col_index')();
  late final buttonId =
      integer().nullable().references(Buttons, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column> get primaryKey => {boardId, rowIndex, colIndex};

  // Fixed 3x4 grid, enforced by the database rather than by discipline.
  @override
  List<String> get customConstraints => [
        'CHECK (row_index >= 0 AND row_index < 4)',
        'CHECK (col_index >= 0 AND col_index < 3)',
      ];
}

/// Files on disk, paths in the DB, never BLOBs.
/// Paths are RELATIVE to the application documents directory: the iOS
/// container UUID changes on reinstall/restore, so an absolute path
/// silently rots into a missing image.
class Images extends Table {
  late final id = integer().autoIncrement()();
  late final relativePath = text()();
  late final contentType = text().nullable()();
}

class Sounds extends Table {
  late final id = integer().autoIncrement()();
  late final relativePath = text()();
  late final durationMs = integer().nullable()();
}

/// Single-row settings table; CHECK pins it to exactly one row.
class AppSettings extends Table {
  late final id = integer().withDefault(const Constant(0))();
  late final voiceId = text().nullable()();
  late final pitch = real().withDefault(const Constant(1.0))();
  late final rate = real().withDefault(const Constant(0.5))();
  late final outputMode = text().withDefault(const Constant('speaker'))();
  late final themeMode = text().withDefault(const Constant('system'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 0)'];
}
```

GridSlots deliberately has no autoIncrement id — autoIncrement implies PRIMARY KEY and will not compile alongside the primaryKey override. That compile error is the architecture defending itself.

### Database class — migration strategy with the FK pragma bracket

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database.steps.dart'; // generated by make-migrations

@DriftDatabase(
  tables: [Boards, Buttons, GridSlots, Images, Sounds, AppSettings],
)
class AppDatabase extends _$AppDatabase {
  /// Explicit executor: this is what makes the DB testable in memory
  /// AND what lets tests run the real MigrationStrategy (and therefore
  /// the real FK enforcement).
  AppDatabase(super.e);

  /// Production. No isolate: 12 tiles will never drop a frame, and drift's
  /// own docs advise against isolates when you aren't janking.
  AppDatabase.defaults() : super(driftDatabase(name: 'aac'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // MUST be outside any transaction: PRAGMA foreign_keys is a silent
          // no-op while a BEGIN/SAVEPOINT is pending. TableMigration works by
          // create-copy-drop-rename, which live FK enforcement would reject.
          await customStatement('PRAGMA foreign_keys = OFF');

          await transaction(() async {
            await m.runMigrationSteps(
              from: from,
              to: to,
              steps: migrationSteps(
                // from1To2: (m, schema) async {
                //   await m.addColumn(schema.buttons, schema.buttons.someCol);
                // },
              ),
            );
          });

          // Prove we didn't corrupt referential integrity while FKs were off.
          // A dangling board_id here is a lost board.
          final violations =
              await customSelect('PRAGMA foreign_key_check').get();
          if (violations.isNotEmpty) {
            throw StateError(
              'Migration $from->$to left FK violations: '
              '${violations.map((r) => r.data).toList()}',
            );
          }

          await customStatement('PRAGMA foreign_keys = ON');
        },
        beforeOpen: (details) async {
          // UNCONDITIONAL. Not inside `if (details.wasCreated)`.
          // FKs are off by default and the setting is PER-CONNECTION, so this
          // must run on every single open. The docs' own example puts this
          // inside a wasCreated guard, which would enforce FKs only on the
          // first-ever launch — and then never again.
          await customStatement('PRAGMA foreign_keys = ON');

          if (details.wasCreated) {
            await _seedDefaultBoard(); // seeding IS correctly wasCreated-gated
          }
        },
      );

  Future<void> _seedDefaultBoard() async {
    final boardId =
        await into(boards).insert(BoardsCompanion.insert(name: 'Home'));
    // Materialize all 12 slots up front, empty. Slots always exist;
    // only their button_id changes. Nothing is ever inserted or deleted
    // at runtime, so nothing can reflow.
    await batch((b) {
      for (var r = 0; r < 4; r++) {
        for (var c = 0; c < 3; c++) {
          b.insert(
            gridSlots,
            GridSlotsCompanion.insert(boardId: boardId, rowIndex: r, colIndex: c),
          );
        }
      }
    });
  }

  Stream<List<GridSlot>> watchSlots(int boardId) {
    return (select(gridSlots)
          ..where((s) => s.boardId.equals(boardId))
          ..orderBy([
            (s) => OrderingTerm(expression: s.rowIndex),
            (s) => OrderingTerm(expression: s.colIndex),
          ]))
        .watch();
  }
}
```

The pragma bracket is the single most important block in this file. Both halves are load-bearing: OFF-outside-transaction because the pragma is otherwise a silent no-op, and ON-unconditionally-in-beforeOpen because it is per-connection.

### Migration test — DATA integrity, not just schema shape (the one that matters)

```dart
// test/migration_test.dart
//
// Generate the fixtures with:
//   dart run drift_dev schema generate --data-classes --companions \
//       drift_schemas/ test/drift/generated/
// (make-migrations does this for you.)

import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';

import 'package:offline_aac/data/database.dart';

import 'drift/generated/schema.dart';
import 'drift/generated/schema_v1.dart' as v1;
import 'drift/generated/schema_v2.dart' as v2;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  // Schema-shape check for every hop. Necessary but NOT sufficient:
  // a migration that rebuilds the table perfectly and copies zero rows
  // passes this test.
  group('schema shape', () {
    for (final (from, to) in const [(1, 2)]) {
      test('migrates v$from -> v$to', () async {
        final connection = await verifier.startAt(from);
        final db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, to);
        await db.close();
      });
    }
  });

  // THE test. A botched migration here is the loss of someone's voice,
  // and with no telemetry this assertion is the only thing that will
  // ever tell us it broke.
  test('v1 -> v2 preserves hand-curated phrases and their positions', () async {
    final schema = await verifier.schemaAt(1);

    // --- Write real user data using v1-era classes ---
    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    final boardId = await oldDb.into(oldDb.boards).insert(
          v1.BoardsCompanion.insert(name: 'Home'),
        );
    final buttonId = await oldDb.into(oldDb.buttons).insert(
          v1.ButtonsCompanion.insert(
            label: 'Overwhelmed',
            vocalization: const Value(
              "I need to leave, I'm not able to talk right now",
            ),
          ),
        );
    await oldDb.into(oldDb.gridSlots).insert(
          v1.GridSlotsCompanion.insert(
            boardId: boardId,
            rowIndex: 2,
            colIndex: 1,
            buttonId: Value(buttonId),
          ),
        );
    await oldDb.close();

    // --- Run the real migration against that data ---
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    await db.close();

    // --- Read it back with v2-era classes and assert it's still CORRECT ---
    final migrated = v2.DatabaseAtV2(schema.newConnection());

    final button = await migrated.select(migrated.buttons).getSingle();
    expect(button.label, 'Overwhelmed');
    expect(
      button.vocalization,
      "I need to leave, I'm not able to talk right now",
      reason: 'The vocalization is the whole point. Losing it is losing speech.',
    );

    final slot = await migrated.select(migrated.gridSlots).getSingle();
    expect(slot.rowIndex, 2, reason: 'A tile that moved is a tile mis-tapped.');
    expect(slot.colIndex, 1);
    expect(slot.buttonId, buttonId);

    await migrated.close();
  });
}
```

`schemaAt(n)` (not `startAt`) is the entry point for data tests: `schema.newConnection()` can be called repeatedly against the same underlying bytes, which is what lets the v1 writer, the real AppDatabase, and the v2 reader all see the same database.

### Query tests — including the invariants that encode the architecture

```dart
// test/database_test.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import 'package:test/test.dart';

import 'package:offline_aac/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // The REAL AppDatabase, so beforeOpen (and thus FK enforcement) applies.
    // A bare connection here would silently skip it and let FK bugs pass green.
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true, // avoids pending-timer test failures
      ),
    );
  });

  tearDown(() => db.close());

  test('foreign keys are actually enforced', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(
      row.data.values.first,
      1,
      reason: 'FKs off => ON DELETE SET NULL silently does nothing => '
          'grid_slots.button_id dangles => blank tile, no error, no telemetry.',
    );
  });

  test('seeds exactly 12 empty slots', () async {
    final slots = await db.select(db.gridSlots).get();
    expect(slots, hasLength(12));
    expect(slots.every((s) => s.buttonId == null), isTrue);
  });

  test('a slot cannot be occupied twice — reflow is structurally impossible',
      () async {
    // The 12 slots already exist from seeding; re-inserting (0,0) must fail
    // on the composite primary key.
    await expectLater(
      db.into(db.gridSlots).insert(
            GridSlotsCompanion.insert(boardId: 1, rowIndex: 0, colIndex: 0),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('the 3x4 grid bounds are enforced by the database', () async {
    await expectLater(
      db.into(db.gridSlots).insert(
            GridSlotsCompanion.insert(boardId: 1, rowIndex: 9, colIndex: 9),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a button empties its slot without moving any other tile',
      () async {
    final buttonId = await db.into(db.buttons).insert(
          ButtonsCompanion.insert(
            label: 'Overwhelmed',
            vocalization: const Value("I need to leave"),
          ),
        );
    await (db.update(db.gridSlots)
          ..where((s) => s.rowIndex.equals(2) & s.colIndex.equals(1)))
        .write(GridSlotsCompanion(buttonId: Value(buttonId)));

    await (db.delete(db.buttons)..where((b) => b.id.equals(buttonId))).go();

    final slots = await db.select(db.gridSlots).get();
    expect(slots, hasLength(12), reason: 'The slot must survive its button.');

    final emptied =
        slots.firstWhere((s) => s.rowIndex == 2 && s.colIndex == 1);
    expect(
      emptied.buttonId,
      isNull,
      reason: 'This is ON DELETE SET NULL working. If FKs were off, this '
          'would still be $buttonId — a dangling id pointing at nothing.',
    );
  });

  test('watchSlots emits after an edit', () async {
    final buttonId = await db.into(db.buttons).insert(
          ButtonsCompanion.insert(label: 'Yes'),
        );

    // Set up the expectation BEFORE the mutation, await it after.
    final expectation = expectLater(
      db.watchSlots(1).map(
            (slots) => slots.where((s) => s.buttonId != null).length,
          ),
      emitsInOrder([0, 1]),
    );

    await (db.update(db.gridSlots)
          ..where((s) => s.rowIndex.equals(0) & s.colIndex.equals(0)))
        .write(GridSlotsCompanion(buttonId: Value(buttonId)));

    await expectation;
  });
}
```

The FK-enforcement test and the delete-button test are a pair: the second one is the behavioural consequence, the first tells you WHY it broke when it does. Both are cheap and both guard a silent failure.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PROJECT THESE PRACTICES ARE FOR ===

An offline AAC (augmentative & alternative communication) app for autistic adults with situational/part-time speech loss. Flutter, Android-first, iOS later. Solo developer. Today is 2026-07-15; Flutter stable is 3.44.0, Dart 3.x.

The app: ONE screen — a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface + on-device TTS. A "show text" full-screen mode. An explicit edit mode. Settings (voice/pitch/rate/output mode/theme). No accounts, no server, no network.

DECISIONS ALREADY MADE (from a prior deep research pass — do not re-litigate these, design practices AROUND them):
- **drift** (SQLite) for local DB. Schema: boards / buttons / grid_slots / images / sounds / settings. Critically, `grid_slots` has PRIMARY KEY (board_id, row, col) with a NULLABLE button_id — position IS the primary key, so tile reflow is structurally impossible. Data model borrows Open Board Format semantics (label != vocalization: the tile SHOWS "Overwhelmed" but SPEAKS "I need to leave, I'm not able to talk right now").
- **flutter_riverpod** for state — explicitly acknowledged as NOT load-bearing (12 tiles and a text field; ValueNotifier would work). Chosen for a testable seam between repository and UI, and to react to MediaQuery a11y flags + TTS voice-availability changes.
- **flutter_tts** wrapped behind an abstract `SpeechService` (speak/stop/voices), with a `voice_filter` (Android network_required check + setVoice return-value check — flutter_tts returns 0 with only a Log.d on failure, which would silently give a user in crisis NO SPEECH) and an `audio_session` config (iOS .playback + duckOthers; NEVER .ambient).
- Native platform channels needed for: Personal Voice (iOS), an Android Quick Settings TileService (Kotlin, speaks natively from SharedPreferences with NO Flutter engine on that path), an iOS 18 ControlWidget (Swift).
- Images/sounds are FILES ON DISK with paths in the DB, never BLOBs.

=== THE CONSTRAINTS THAT MAKE THIS PROJECT'S ENGINEERING UNUSUAL ===

1. **NO TELEMETRY, EVER.** No Firebase, no Crashlytics, no Sentry, no analytics — the privacy promise forbids it and the audience reads privacy labels adversarially. THE DEVELOPER WILL NEVER LEARN THAT THE APP CRASHED IN THE FIELD. Tests are the ONLY safety net. This should raise the bar on testing dramatically and change what is worth testing. There is a planned on-device-only, user-exportable crash log.
2. **A BOTCHED DB MIGRATION IS THE LOSS OF SOMEONE'S VOICE.** Users hand-curate phrase boards over months; that data is irreplaceable and unmergeable. Migration testing is a safety property, not hygiene.
3. **ACCESSIBILITY IS CORRECTNESS, NOT POLISH.** An inaccessible accessibility app is a total failure. Semantics on every tile; iOS Switch Control / Android Switch Access / VoiceOver / TalkBack must work; TextScaler must be honored at 200%+ and never clamped. This must be enforced by TESTS and lints, not by discipline.
4. **A SILENT FAILURE IS THE WORST BUG CLASS.** An unchecked setVoice return, a voice that vanished, an audio session misconfigured to .ambient so the silent switch mutes the app — each means a user taps a tile mid-shutdown and NOTHING happens. Error handling must make silence impossible.
5. **The developer may abandon this** (it is app #N of a 50-app challenge). The offline architecture means it keeps working unmaintained; open-sourcing is the exit plan. So the code must be READABLE BY A STRANGER and the docs must let someone else pick it up.
6. **Solo dev, ~2-week MVP.** Practices must be proportionate. Ceremony that a team needs and a solo dev doesn't is a real cost. Be honest about what to SKIP.
7. Zero animation is a design rule (distress + latency). Deterministic UI.

Today's date: 2026-07-15. Prefer 2025-2026 sources. Flutter and its ecosystem move fast — a 2022 blog post is probably wrong.


YOUR DIMENSION: drift — correct usage, and testing DB code + migrations. A botched migration here loses someone's irreplaceable hand-curated phrase board.

Research with WebSearch/WebFetch: drift.simonbinder.eu (the official docs), pub.dev/packages/drift, the drift GitHub repo, migration docs specifically.

- Current drift version and the 2026 API. Table definition styles (class-based vs .drift files vs `drift_dev` codegen). Which for this project?
- `build_runner` workflow: `dart run build_runner build --delete-conflicting-outputs`, watch mode, what's generated (.g.dart), .gitignore or commit generated files? (argue)
- **Migrations, in depth**: `schemaVersion`, `MigrationStrategy`, `onCreate`, `onUpgrade`, `beforeOpen`, `stepByStep` / `Migrator.stepByStep` (verify this API), `m.addColumn`, `m.createTable`, `m.alterTable`/TableMigration for changes SQLite can't do natively.
- **Schema snapshot testing — the crown jewel**: `drift_dev schema dump`, `drift_dev schema generate`, `drift_dev schema steps`, the generated `schema_v1.dart`... files, `SchemaVerifier`, `verifier.migrateAndValidate()`, `verifier.startAt(n)`, `expectedSchema`. Get the EXACT current commands and test code. Show a complete, real migration test.
- Does drift have a way to test that DATA survives a migration (not just the schema shape)? (I believe there's something about validating data integrity — find it.) THIS IS THE ONE THAT MATTERS: schema correctness is not enough; the user's phrases must still be there and still be correct afterward.
- Testing queries: `NativeDatabase.memory()`, in-memory DB in tests, `setUp`/`tearDown`, logStatements. Show the idiom.
- Is there a `drift_flutter` package now? What's the current recommended way to open a DB in a Flutter app (path_provider + NativeDatabase.createInBackground?)? Isolates/background — `DriftIsolate`, `computeWithDriftIsolate`? Is it worth it for 12 tiles?
- Reactive queries: `.watch()`, `.watchSingle()`. Correct usage and testing them (expectLater with emitsInOrder).
- Constraints/indexes: how to express the (board_id,row,col) PK and FK constraints in drift. Are FKs even ON by default in SQLite? (`PRAGMA foreign_keys` — VERIFY, drift may not enable them by default; that's a real footgun.)
- Transactions and batch.
- What are drift's known footguns?

Give complete, current, compiling code for: table defs matching this project's schema, a migration test, a query test.
````

</details>
