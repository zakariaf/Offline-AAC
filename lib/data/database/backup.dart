import 'dart:io';

import 'package:offline_aac/data/crash_log.dart';

/// Copies the database file aside before a schema upgrade runs.
///
/// A migration test proves the migration you thought of works. This copy
/// survives the one you did not: if an upgrade corrupts the file, the `.bak`
/// beside it is the user's board — months of hand-curated phrases, irreplaceable
/// and unmergeable — from the moment before the migration touched it. About
/// fifteen lines with a higher safety-per-line ratio than the entire migration
/// suite.
///
/// It NEVER throws. A backup is a safety net for the upgrade path; if the net
/// itself fails, the app must still open, because a user who cannot launch has
/// no voice at all. On failure it records a single line and returns null, and
/// the caller proceeds with the upgrade unbacked — a worse position, but not a
/// dead one.
///
/// Returns the backup file on success, or null if there was nothing to back up
/// or the copy failed.
Future<File?> backupDatabaseFile({
  required File source,
  required File destination,
  required CrashLog log,
}) async {
  // Nothing to back up is not a failure: a fresh install has no file yet, and
  // the first open creates it. Silent by design — logging "no database to back
  // up" on every fresh launch is noise that trains a reader to ignore the log.
  if (!source.existsSync()) return null;

  try {
    return await source.copy(destination.path);
  } on Object catch (_, stack) {
    // A FIXED message, never the exception. The log is user-exported, and while
    // an IO exception here carries a path rather than phrase text, the rule is
    // that only chosen strings reach this file — an exception's `toString` is
    // not a chosen string.
    log.record('database backup before upgrade failed', stack);
    return null;
  }
}
