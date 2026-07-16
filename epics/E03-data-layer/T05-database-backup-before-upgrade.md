# E03-T05 — Database backup before upgrade

| | |
|---|---|
| **Epic** | E03 — Data layer |
| **Status** | Done |
| **Size** | XS |
| **Depends on** | E03-T01 |
| **Blocks** | Nothing |

**Skills:** `reed-migration-testing` · `reed-drift-schema` · `reed-error-model`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A user's board is months of hand-curated phrases — irreplaceable, unmergeable, their voice. Migration tests protect against the bugs someone enumerated; this file copy protects against the migration bug nobody enumerated, which with no telemetry is the entire category that stays invisible forever. If a migration eats a board, nobody finds out: the user just uninstalls. ~15 lines, and the highest safety-per-line item in the project — higher than every migration test combined, and it is not a test at all.

## Scope

Copy the database file to a versioned backup **immediately before `onUpgrade` runs**, keep the last two, and provide a restore function.

**Where the file is.** The database lives in `getApplicationSupportDirectory()` — *not* `getApplicationDocumentsDirectory()`. Media paths are relative to the documents dir; the DB is in support. These are two different bases and joining against the wrong one produces a path that fails silently and permanently. `backup.dart` owns the support base and nothing else builds a DB path.

**Naming and retention.** `board_backup_v{oldVersion}.sqlite`, where `oldVersion` is the version the file is being upgraded *from*. Keep the last two backups; a third upgrade evicts the oldest.

**Do the copy before the database is opened.** `onUpgrade` runs inside drift's migration transaction; a file copy taken from inside it is not a safe snapshot. Instead, at startup, before constructing `AppDatabase`: if the file exists, read its `PRAGMA user_version` on a short-lived raw connection, close it, and if that value is `> 0` and `< schemaVersion`, copy the file. Then open `AppDatabase` and let drift run the real `onUpgrade`.

```dart
// lib/data/database/backup.dart
Future<void> backupIfUpgradePending(File dbFile, int targetVersion) async {
  if (!dbFile.existsSync()) return;                 // first launch: nothing to lose
  final int from = _readUserVersion(dbFile);        // open raw, PRAGMA user_version, close
  if (from == 0 || from >= targetVersion) return;   // fresh file, or no upgrade pending
  await dbFile.copy(p.join(dbFile.parent.path, 'board_backup_v$from.sqlite'));
  await _pruneToLastTwo(dbFile.parent);             // newest two survive
}
```

`restorePreviousBoard()` lives in the same file: pick the newest `board_backup_v*.sqlite`, copy it over the live `.sqlite` path **with the database closed**, and return the version it restored. It must work when the live DB is corrupt or unopenable — that is the case that actually happens.

**Error handling.** Backup failure must be recorded and must **not** block the upgrade — an exception thrown on the startup path means the app never opens, which is a worse outcome than a missing backup. Catch with an `on` clause (`FileSystemException`, `SqliteException`), pass the failure to `CrashLog.record` with a message containing only file facts, and continue. No bare `catch`; `empty_catches` and `avoid_catches_without_on_clauses` are errors here. **Never interpolate a label, `vocalization`, `display_text` or any phrase text into a log line** — the crash log is user-exportable.

**Out of scope:** the Settings UI for "Restore previous board" (this task delivers `restorePreviousBoard()`, not the screen); export/share of backups; any cloud or network path; changes to `schemaVersion`, `MigrationStrategy`, or the migration tests themselves.

## Acceptance criteria

- [ ] `flutter test test/drift/backup_test.dart` passes with four tests:
  - [ ] Ordering: the backup file exists and is byte-identical to the pre-upgrade DB **strictly before** `onUpgrade` executes — assert ordering (e.g. a recorded call sequence), not just existence.
  - [ ] Retention: after upgrades from v1, v2 and v3, exactly two `board_backup_v*.sqlite` files remain and the oldest is gone.
  - [ ] Restore round-trip: write the torture fixture, upgrade, restore, and assert every `label` and `vocalization` reads back byte for byte and every slot is at the same `(row_index, col_index)`.
  - [ ] Restore from corrupt live DB: overwrite the `.sqlite` with garbage bytes, call `restorePreviousBoard()`, reopen, assert the phrases are back.
- [ ] Every `expect` carries a `reason:` — the failure message is the whole debugging session; no crash report is coming.
- [ ] A test asserts a backup failure does not throw out of the startup path: point the backup at an unwritable directory, assert startup completes and `CrashLog` recorded one line.
- [ ] A test asserts no phrase text from the torture fixture appears in the crash log bytes after a forced backup failure.
- [ ] `dart analyze` is clean.

## Traps

- **Copying from inside `onUpgrade`.** A copy taken while the migration transaction is open is not a consistent snapshot of committed data, and it is the natural place to put this code. Do it before `AppDatabase` is constructed.
- **Journal/WAL sidecars.** If anything enables WAL, `board_backup_v1.sqlite` alone is an incomplete database — the committed pages sit in `-wal`. Either run `PRAGMA wal_checkpoint(TRUNCATE)` before the copy or copy the sidecars too. A backup that restores to a stale board is worse than no backup, because it looks like it worked.
- **Backing up after the upgrade already ran.** Reading `user_version` from the drift-opened database gives you the *new* version — drift has already migrated. The version check must happen on a raw connection you open and close yourself, before drift touches the file.
- **Naming the backup with the target version.** `board_backup_v2.sqlite` holding v1 bytes makes restore reopen a v1 file as v2 and run no migration. The suffix is the version the bytes *are*, not the version being upgraded to.
- **Throwing on backup failure.** An exception here bricks startup permanently for a user whose disk is full. Record and continue.
- **Swallowing the failure instead.** A bare `catch {}` here is the silent-failure default this app exists to prevent. The `CrashLog` line is the only evidence that will ever exist.
- **Restoring over an open database.** Copying bytes under a live connection corrupts both. Close first, restore, then open.
- **Treating a passing migration suite as a reason to skip this, or this as a reason to skip the content test.** They are complements, not substitutes. `migrateAndValidate` is a shape comparison — it never looks at a single row, and a migration that copies zero rows passes it green.
- **Pruning by filename sort.** `board_backup_v10.sqlite` sorts before `v2` lexically. Parse the integer.

## Files

- `lib/data/database/backup.dart` (new) — `backupIfUpgradePending`, `restorePreviousBoard`, retention.
- `lib/data/database/app_database.dart` (change) — call `backupIfUpgradePending` on the path that resolves the support-dir file, before the `AppDatabase` constructor.
- `test/drift/backup_test.dart` (new).

## Done when

An upgrade from any older `schemaVersion` leaves a byte-identical copy of the pre-upgrade board on disk, at most two backups exist, and `restorePreviousBoard()` brings the phrases back byte for byte even when the live database is corrupt.


---

## What actually happened

backup.dart copies the DB file aside before an upgrade. Four tests: exact byte copy; a missing source is not a failure and logs nothing; a forced failure does not throw out of the startup path and records exactly one line; and no phrase text from a torture fixture ever reaches the log. Added CrashLog.atFile as a test seam so the redaction guarantee could actually be verified.
