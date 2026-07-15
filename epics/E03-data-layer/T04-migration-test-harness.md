# E03-T04 — Migration test harness

| | |
|---|---|
| **Epic** | E03 — Data layer |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E03-T01 |
| **Blocks** | Nothing |

**Skills:** `reed-migration-testing` · `reed-codegen-workflow` · `reed-drift-schema`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A user's board is months of hand-curated phrases. It is unmergeable, irreplaceable, and it is their voice. If a `schemaVersion` bump drops rows in the field, no crash report arrives, no telemetry fires, and no user who cannot speak files a bug — they uninstall. This harness is the only mechanism that will ever tell anyone a migration ate a board, and it has to say so **before** the build ships, not after.

## Scope

Three things, in this order: the snapshot workflow, the shape loop, and the content test that is the actual deliverable.

### 1. The snapshot workflow and its committed output

`build.yaml` at the repo root already declares the database (E03-T01). Confirm it reads exactly:

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

Without the `databases:` block, `dart run drift_dev make-migrations` hard-errors with **"No databases found in the build.yaml file"** and the whole chain — dumps, step helpers, migration tests — is unreachable. Do not rename `test_dir` or `schema_dir`; they are drift's defaults, written out only so a stranger knows where things land.

Three commands. Re-run **all three on every `schemaVersion` bump**:

```bash
# 1. Export the schema for the CURRENT schemaVersion.
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/

# 2. Era-correct classes. --data-classes --companions is LOAD-BEARING.
dart run drift_dev schema generate --data-classes --companions \
  drift_schemas/ test/drift/generated/

# 3. Step-by-step helpers.
dart run drift_dev schema steps drift_schemas/ lib/data/database/schema_versions.dart
```

`--data-classes --companions` is not a style flag. Without it `schema generate` emits bare table shapes; with it, it emits `DatabaseAtV1` / `DatabaseAtV2` with era-correct data classes and companions — `v1.ButtonsCompanion`, `v2.Button`, `v2.GridSlot`. Those classes are the **only** mechanism that lets a test write rows in the v1 world and read them back in the v2 world. Drop the flag and the content test in part 3 cannot be written at all — only shape tests remain, and shape tests are the ones that lie.

`schema steps` exists so each migration callback gets a schema **frozen at its version**. A v1→v2 migration that references a table deleted in v4 keeps compiling — which matters most precisely when nobody is paying attention to the old migration any more.

`dart run drift_dev make-migrations` consolidates all three behind one command, driven by the same `build.yaml`. The three explicit commands are verified on drift_dev 2.31+; prefer them unless `make-migrations` is confirmed working on the pinned version.

**Ordering: dump before bump.** `schema dump` reads the Dart source and writes a snapshot for **whatever `schemaVersion` currently says**.

1. Before touching `tables.dart`, confirm `drift_schemas/` already holds a snapshot for the current `schemaVersion`. If not, dump it now on unmodified source and commit that alone.
2. Then edit the tables **and** bump `schemaVersion` — same commit, never one without the other.
3. Then dump again, producing the snapshot for the new version.

**Commit `drift_schemas/`.** Not for recoverability — commit it so a schema delta shows up as a **reviewable diff in the PR**, and so no future migration starts with git archaeology.

Add the CI gate that catches a board-losing bug touching zero lines of migration code — the schema changed, `schemaVersion` did not, so no migration runs at all on the user's device:

```bash
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
if ! git diff --exit-code -- drift_schemas/; then
  echo "::error::You changed the schema without bumping schemaVersion + dumping."
  echo "::error::Shipping this means NO MIGRATION RUNS and users lose their boards."
  exit 1
fi
```

Re-dump and diff: a dirty `drift_schemas/` after a dump means the committed snapshot does not describe the shipped code.

### 2. The shape loop — every pair, including the skips

Adjacent hops are not enough. A user who ignored updates for six months upgrades **v1 → v3 directly**, running v2's path never. That is a code path nobody exercised, and with no telemetry their board vanishes silently. Write the nested loop so skip paths cannot be forgotten on the next bump:

```dart
group('schema shape', () {
  for (int from = 1; from < kLatestSchemaVersion; from++) {
    for (int to = from + 1; to <= kLatestSchemaVersion; to++) {
      test('v$from -> v$to', () async {
        final DatabaseConnection connection = await verifier.startAt(from);
        final AppDatabase db = AppDatabase(connection);
        await verifier.migrateAndValidate(db, to);
        await db.close();
      });
    }
  }
});
```

Never hand-write `v1 -> v2` and `v2 -> v3` as two separate tests.

### 3. The test that actually matters

`migrateAndValidate` extracts `CREATE` statements from `sqlite_schema` and compares them to a reference built by `Migrator.createAll`. **It is a shape comparison. It never looks at a single row.** A migration that rebuilds `grid_slots` perfectly and copies **zero rows** passes it, green. Shape tests are necessary, never sufficient. Never mark a migration done because `migrateAndValidate` passes.

Write rows at v(n) with era-correct classes, run the real migration, read back at v(n+1), assert the phrases are **still there, still correct, and still in the same grid slots**. Reproduce this shape for every new version pair, and for every skip pair (v1→v3 gets its own content test, not just a shape hop).

```dart
// test/drift/migration_test.dart
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:test/test.dart';

import 'package:offline_aac/data/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// A hostile, realistic board. NOT "test1"/"test2" — those survive everything.
const List<(String, String)> _torture = <(String, String)>[
  ('Overwhelmed', "I need to leave, I'm not able to talk right now"), // apostrophe
  ('Nej', 'Nej tack — jag kan inte prata just nu'), // non-ASCII + em dash
  ('🚻', 'I need the toilet'), // emoji label
  ('Quote', 'She said "no" — and I agree; see: a\\b'), // quotes + backslash
  ('Blank-ish', ' '), // whitespace-only
];

void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 -> v2 preserves every phrase, byte for byte, in place', () async {
    final InitializedSchema schema = await verifier.schemaAt(1);

    // --- Write real user data with v1-era classes -------------------------
    // schema.newConnection() may be called repeatedly against the SAME bytes,
    // which is what lets three different-era database objects see one database.
    final v1.DatabaseAtV1 old = v1.DatabaseAtV1(schema.newConnection());
    final int boardId =
        await old.into(old.boards).insert(v1.BoardsCompanion.insert(name: 'Home'));

    for (int i = 0; i < _torture.length; i++) {
      final (String label, String vocalization) = _torture[i];
      final int buttonId = await old.into(old.buttons).insert(
            v1.ButtonsCompanion.insert(
              label: label,
              vocalization: Value<String>(vocalization),
            ),
          );
      await old.into(old.gridSlots).insert(
            v1.GridSlotsCompanion.insert(
              boardId: boardId,
              rowIndex: i ~/ 3,
              colIndex: i % 3,
              buttonId: Value<int>(buttonId),
            ),
          );
    }
    // An EMPTY slot must survive as an empty slot — not vanish, not collapse,
    // not pull the next tile into its position.
    await old.into(old.gridSlots).insert(
          v1.GridSlotsCompanion.insert(boardId: boardId, rowIndex: 3, colIndex: 2),
        );
    await old.close();

    // --- Run the REAL migration against that data -------------------------
    final AppDatabase db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2); // shape only

    // Prove we did not corrupt referential integrity while FKs were off during
    // the migration. A dangling board_id is a lost board.
    final List<QueryRow> violations =
        await db.customSelect('PRAGMA foreign_key_check').get();
    expect(violations, isEmpty,
        reason: 'migration left FK violations: '
            '${violations.map((QueryRow r) => r.data).toList()}');
    await db.close();

    // --- Read back with v2-era classes and assert CONTENT ------------------
    final v2.DatabaseAtV2 now = v2.DatabaseAtV2(schema.newConnection());
    final List<v2.Button> buttons = await now.select(now.buttons).get();
    final List<v2.GridSlot> slots = await now.select(now.gridSlots).get();

    expect(slots, hasLength(_torture.length + 1), reason: 'a slot disappeared');
    expect(slots.where((v2.GridSlot s) => s.buttonId == null), hasLength(1),
        reason: 'the empty slot must survive as an empty slot');

    for (int i = 0; i < _torture.length; i++) {
      final (String label, String vocalization) = _torture[i];
      final v2.GridSlot slot = slots.firstWhere(
          (v2.GridSlot s) => s.rowIndex == i ~/ 3 && s.colIndex == i % 3);
      final v2.Button button =
          buttons.firstWhere((v2.Button b) => b.id == slot.buttonId);

      expect(button.label, label);
      expect(
        button.vocalization,
        vocalization,
        reason: 'The vocalization is the whole point. Losing it is losing '
            'speech. Truncation, re-encoding and quote-mangling all land here.',
      );
    }
    await now.close();
  });
}
```

**The skip case gets the same treatment.** When v3 exists, write `v1 -> v3 preserves every phrase, byte for byte, in place`: `schemaAt(1)`, write the torture fixture with v1-era classes, `migrateAndValidate(db, 3)`, read back with `v3.DatabaseAtV3`. This is the six-months-of-ignored-updates user. Their device runs a composition of migration steps that no single hop test covers, and it is the only run of that code path that will ever happen.

#### What each part defends, so none of it gets "cleaned up"

| Element | Why it must stay |
|---|---|
| `_torture` fixture | Apostrophes, em dashes, emoji, quotes and backslashes are exactly where a `columnTransformer` expression or a hand-rolled `INSERT ... SELECT` mangles someone's sentence. A mangled sentence passes every shape check. `'test1'` survives everything and proves nothing. |
| `schemaAt(1)` + repeated `newConnection()` | Three different-era database objects read the **same bytes**. Without it there is no way to hand v1-written data to the v2 world. |
| The extra empty slot | Reflow is the silent disaster: the migration "works", but every tile shifts one position. A user reaching for the tile that has been at (2,1) for a year now taps something else, mid-shutdown. Assert emptiness survives *as emptiness*. |
| `PRAGMA foreign_key_check` after migrating | FKs are off during migration. A dangling `board_id` is a lost board, and SQLite reports nothing. |
| Position assertions via `rowIndex`/`colIndex` | Row count alone does not catch reordering. Look each slot up by coordinate, not by list index. |
| `reason:` on every expect | The failure message is the whole debugging session. There is no crash report coming. |

### Running these tests

`flutter test` runs in a plain Dart VM, where `sqlite3_flutter_libs` does nothing. macOS falls back to the system `libsqlite3` (older than the bundled one — real version-skew risk). Linux CI needs `apt-get install -y libsqlite3-dev` **before** `flutter test`, or every DB test fails and a stranger concludes the repo is broken. Put that step in the workflow now.

### Out of scope

- Designing tables or columns — that is E03-T01's schema, not this task's.
- `backup.dart` (copy the `.sqlite` to `board_backup_v{oldVersion}.sqlite` before `onUpgrade`, keep the last two, "Restore previous board" in settings) and its four tests. It outranks this harness in safety-per-line and is its own task. Never treat a passing migration suite as a reason to skip the backup, and never treat the backup as a reason to skip the content test — they are complements.
- Writing any actual v1→v2 migration. At `schemaVersion = 1` there are no migrations to test. This task builds the harness, the commands, the committed v1 snapshot, and the CI gate — the content test above is the template the first real bump fills in.

## Acceptance criteria

- [ ] `build.yaml` at the repo root contains the `databases: app_database: lib/data/database/app_database.dart` block; `dart run drift_dev make-migrations` does not error with "No databases found in the build.yaml file".
- [ ] `dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/` produces a snapshot for the current `schemaVersion`, and it is committed.
- [ ] `dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/drift/generated/` emits `DatabaseAtV1` with `v1.ButtonsCompanion`, `v1.GridSlotsCompanion` and `v1.Button` — grep the output for `class BoardsCompanion` and `class Button ` to prove the flags took effect.
- [ ] `dart run drift_dev schema steps drift_schemas/ lib/data/database/schema_versions.dart` produces the step helper, and it is committed.
- [ ] `test/drift/migration_test.dart` exists with the `_torture` fixture verbatim (apostrophe, non-ASCII + em dash, emoji label, quotes + backslash, whitespace-only) and no `test1`/`test2` rows anywhere: `grep -rn "test1" test/drift/` returns nothing.
- [ ] The shape group is the nested `for (from) for (to)` loop bounded by `kLatestSchemaVersion` — not hand-enumerated adjacent pairs. `grep -c "test('v" test/drift/migration_test.dart` does not grow when a version is added.
- [ ] The content test asserts `hasLength(_torture.length + 1)` on slots and exactly one `buttonId == null` slot.
- [ ] The content test runs `PRAGMA foreign_key_check` after `migrateAndValidate` and asserts `isEmpty`.
- [ ] Every `expect` in the content test carries a `reason:`.
- [ ] `analysis_options.yaml` excludes `test/drift/generated/**` (plus `**/*.g.dart`, `**/*.drift.dart`, `**/generated_plugin_registrant.dart`); `flutter analyze --fatal-infos` is green.
- [ ] CI runs the dump-and-diff gate and fails with a non-zero exit when the schema moved without a `schemaVersion` bump. Prove it: add a column to `tables.dart` without bumping, run the gate locally, see it exit 1, revert.
- [ ] CI installs `libsqlite3-dev` before `flutter test`.
- [ ] `flutter test test/drift/` passes on a clean checkout.

## Traps

- **`migrateAndValidate` is blind to rows.** It diffs `CREATE` statements out of `sqlite_schema`. A migration that rebuilds `grid_slots` perfectly and copies zero rows passes it green. A green shape suite is not evidence the board survived. The content test is the deliverable; the shape loop is the cheap part.
- **`make-migrations` writes a test that lies.** Its generated data-integrity test uses `SchemaVerifier.testWithDataIntegrity` and leaves `final oldButtonsData = <v1.Button>[]; final expectedNewButtonsData = <v2.Button>[]; // TODO: Fill these lists`. With both lists empty the test **passes vacuously** — it inserts nothing and asserts `[] == []`. The result is a green test named *"migration from v1 to v2 does not corrupt data"* that verified precisely nothing, and that tick is the only thing between a user and a permanently empty board. Fill the lists in the same commit that generates the test. If they cannot be filled now, delete the test — a test that lies is worse than an absent one.
- **Dump after edit, before bump, overwrites v1's snapshot with v2's shape.** Nothing errors. `drift_schemas/` now contains a fiction — a file claiming v1 had columns v1 never had — and every migration test from then on validates against that fiction. Meanwhile on the user's device no migration runs at all: `onUpgrade` is never called, the old database is opened against new query code, every board silently fails to load. Two shell commands in the wrong order, highest-cost bug in the codebase.
- **A dump producing a diff on a snapshot for a version that already shipped is not a stale file to commit.** It is proof that either `schemaVersion` was not bumped or the historical snapshot is already wrong. Stop and reconcile the shape before writing anything.
- **Forgetting `--data-classes --companions`.** You get bare table shapes, the content test is unwritable, and the natural response is to settle for shape tests — which is exactly the failure mode this whole task exists to prevent.
- **Only testing adjacent hops.** v1→v3 is a real device path and a code path nobody ran. Hand-written pair tests always miss it on the next bump; the nested loop cannot.
- **`PRAGMA foreign_keys` is a no-op inside a transaction.** It does not error, it does nothing. Disable FKs **outside** the transaction in `onUpgrade`, and re-enable them **unconditionally in `beforeOpen`** — the pragma is per-connection and must run on every open. Only seeding belongs inside `if (details.wasCreated)`.
- **Testing against a Map-backed fake instead of `NativeDatabase.memory()`.** A fake happily accepts a row the real composite PK `(board_id, row_index, col_index)` rejects, and never executes a migration step at all.
- **Asserting slots by list index.** Row count alone does not catch reordering, and neither does `slots[i]`. Look each slot up by `rowIndex`/`colIndex`.
- **Dropping the empty slot from the fixture as "noise".** It is the reflow canary. Without it a migration that collapses empty cells and shifts every tile one position passes.
- **`--delete-conflicting-outputs` omitted from `build_runner build`.** Every output is committed to git, so build_runner refuses to overwrite outputs it did not write this run. The wall of "conflicting outputs" text is not a bug — do not go hunting for one.
- **Hand-editing generated output.** The next build silently reverts it and takes the fix with it. If codegen and the analyzer disagree, the disk is behind: regenerate and restart the analysis server rather than "fixing" the call site.
- **macOS local green, Linux CI red.** `flutter test` runs in a plain Dart VM; `sqlite3_flutter_libs` does nothing there. macOS silently falls back to the system `libsqlite3`, which is older than the bundled one. Without `libsqlite3-dev` on Linux every DB test fails.

## Files

- `build.yaml` — verify/extend the `drift_dev` `databases:` block.
- `drift_schemas/` — committed JSON snapshot(s), one per `schemaVersion`.
- `lib/data/database/schema_versions.dart` — generated `stepByStep` helper, committed.
- `test/drift/generated/` — generated era-correct classes (`schema.dart`, `schema_v1.dart`, …), committed.
- `test/drift/migration_test.dart` — the shape loop and the content test.
- `analysis_options.yaml` — add the `test/drift/generated/**` exclude.
- `.gitattributes` — `*.g.dart linguist-generated=true`, `*.drift.dart linguist-generated=true`.
- The CI workflow — `libsqlite3-dev` install, the dump-and-diff gate, the `build_runner` freshness gate.

## Done when

`flutter test test/drift/` passes on a clean Linux checkout, the CI dump-and-diff gate exits non-zero on a schema change without a `schemaVersion` bump, and a content test proves the torture-fixture phrases and the empty slot survive a migration byte for byte at their original coordinates — including across a v1→v3 skip.
