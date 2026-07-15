---
name: reed-migration-testing
description: Proving stored rows survive a schemaVersion bump — write-at-v1/read-at-v2 content tests, the every-pair shape loop, migrateAndValidate's row-blindness, foreign_key_check, and the pre-onUpgrade board backup. Use when bumping schemaVersion, writing onUpgrade/MigrationStrategy/stepByStep/columnTransformer code, touching drift_schemas/ or schema_versions.dart, calling SchemaVerifier, or reviewing a diff that could drop saved phrases, boards, or grid_slots. Not for designing the table or column itself, and not for the codegen commands.
---

# Migration testing: the phrases, not the schema

A user's board is months of hand-curated phrases. It is irreplaceable, unmergeable, and it is their voice. There is no telemetry — if a migration eats a board, nobody ever finds out. The user just uninstalls. Every rule below exists for that.

## The gap that makes green migrations dangerous

`migrateAndValidate` extracts `CREATE` statements from `sqlite_schema` and compares them to a reference built by `Migrator.createAll`. **It is a shape comparison. It never looks at a single row.**

A migration that rebuilds `grid_slots` perfectly and copies **zero rows** passes it, green.

So: shape tests are **necessary, never sufficient**. Never mark a migration done because `migrateAndValidate` passes. The content test below is the deliverable.

## Setup — do this before there is data to lose

```yaml
# build.yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/data/database/app_database.dart
          test_dir: test/drift/
          schema_dir: drift_schemas/
```

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

**Why `--data-classes --companions` is load-bearing:** without it, `schema generate` emits bare table shapes. With it, it emits `DatabaseAtV1` / `DatabaseAtV2` with era-correct data classes and companions — `v1.ButtonsCompanion`, `v2.Button`, `v2.GridSlot`. Those classes are the *only* mechanism that lets a test **write rows using the v1 world and read them back using the v2 world**. Drop the flag and the content test cannot be written at all; only shape tests remain, and shape tests are the ones that lie.

**Why `schema steps`:** each migration callback gets a schema **frozen at its version**. A v1→v2 migration that references a table deleted in v4 keeps compiling. That matters most precisely when nobody is paying attention to the old migration anymore.

Newer `drift_dev` consolidates all three behind `dart run drift_dev make-migrations`, driven by the same `build.yaml`. The three explicit commands are verified on 2.31+; prefer them unless `make-migrations` is confirmed working on the pinned version.

**Commit `drift_schemas/`.** Not for recoverability — `schema dump` reads the Dart source, so any tag can be regenerated. Commit it so a schema delta shows up as a **reviewable diff in the PR**, and so no future migration starts with git archaeology.

## The CI gate

This catches a board-losing bug that touches zero lines of migration code: the schema changed, `schemaVersion` did not, so **no migration runs at all** on the user's device.

```bash
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
if ! git diff --exit-code -- drift_schemas/; then
  echo "::error::You changed the schema without bumping schemaVersion + dumping."
  echo "::error::Shipping this means NO MIGRATION RUNS and users lose their boards."
  exit 1
fi
```

Re-dumping in CI and diffing is the whole trick: a dirty `drift_schemas/` after a dump means the committed snapshot does not describe the shipped code.

## Shape, every hop — including the skips

Adjacent hops are not enough. A user who ignored updates for six months upgrades **v1 → v3 directly**, which is a code path nobody ran. With no telemetry their boards vanish silently. Nested loop, ~10 lines, covers every pair forever:

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

Never hand-write `v1 -> v2` and `v2 -> v3` as two tests. Write the loop, so the skip paths cannot be forgotten on the next bump.

## The test that actually matters

Write rows at v(n) with era-correct classes, run the real migration, read back at v(n+1), assert the phrases are **still there, still correct, and still in the same grid slots**. Reproduce this shape for every new version pair.

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

### What each part is defending, so none of it gets "cleaned up"

| Element | Why it must stay |
|---|---|
| `_torture` fixture | Apostrophes, em dashes, emoji, quotes and backslashes are exactly where a `columnTransformer` expression or a hand-rolled `INSERT ... SELECT` mangles someone's sentence. A mangled sentence passes every shape check. `'test1'` survives everything and proves nothing. |
| `schemaAt(1)` + repeated `newConnection()` | Three different-era database objects read the **same bytes**. Without it there is no way to hand v1-written data to the v2 world. |
| The extra empty slot | Reflow is the silent disaster: the migration "works", but every tile shifts one position. A user reaching for the tile that has been at (2,1) for a year now taps something else, mid-shutdown. Assert emptiness survives *as emptiness*. |
| `PRAGMA foreign_key_check` after migrating | FKs are off during migration. A dangling `board_id` is a lost board, and SQLite reports nothing. |
| Position assertions via `rowIndex`/`colIndex` | Row count alone does not catch reordering. Look each slot up by coordinate, not by list index. |
| `reason:` on every expect | The failure message is the whole debugging session. There is no crash report coming. |

### Migration mechanics that fail silently

- `PRAGMA foreign_keys` **is a no-op inside a transaction** — it does not error, it does nothing. Disable FKs **outside** the transaction in `onUpgrade`.
- Run `PRAGMA foreign_key_check` after the migration body, not just in tests.
- Re-enable FKs **unconditionally in `beforeOpen`**. The pragma is per-connection and must run on every open. Only seeding belongs inside `if (details.wasCreated)`.

### Running these tests

`flutter test` runs in a plain Dart VM, where `sqlite3_flutter_libs` does nothing. macOS falls back to the system `libsqlite3` (older than the bundled one — real version-skew risk). Linux needs `apt-get install -y libsqlite3-dev` **before** `flutter test`, or every DB test fails and a stranger concludes the repo is broken.

## The 15 lines that beat every migration test

Copy the `.sqlite` file to `board_backup_v{oldVersion}.sqlite` **immediately before `onUpgrade` runs**. Keep the last two. Expose "Restore previous board" in settings.

~15 lines, and the highest safety-per-line item in the project — higher than every migration test combined, and it is not a test at all. Migration tests protect against the bugs that were enumerated. The backup protects against the migration bug that was **not** enumerated, which with no telemetry is the entire category that stays invisible forever.

They are complements, not substitutes. Never treat a passing migration suite as a reason to skip the backup, and never treat the backup as a reason to skip the content test.

Then test the backup path itself — four tests:

1. The backup happens **strictly before** `onUpgrade` (assert ordering, not just existence).
2. Last-two retention: a third upgrade evicts the oldest.
3. Restore round-trip: restore reproduces the phrases byte for byte.
4. Restore when the live DB is corrupt — the case that actually happens.

## Checklist for any schema change

- [ ] `schemaVersion` bumped in `app_database.dart`.
- [ ] All three `drift_dev schema` commands re-run; `drift_schemas/` and `schema_versions.dart` committed in the same change.
- [ ] The shape loop still covers every pair up to `kLatestSchemaVersion`.
- [ ] A new content test for the new pair, with the torture fixture, an empty slot, `foreign_key_check`, and per-coordinate assertions.
- [ ] FK pragma disabled outside the transaction, re-enabled in `beforeOpen`.
- [ ] Backup-before-`onUpgrade` still intact.
