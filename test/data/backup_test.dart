import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/database/backup.dart';
import 'package:offline_aac/diagnostics/crash_log.dart';

/// The backup is the last line of defence for the one asset the app cannot
/// regenerate: a board of hand-curated phrases. These tests hold it to two
/// promises — it copies the bytes exactly, and when it cannot, it fails quietly
/// without taking the startup path down or leaking the user's phrases into a
/// log they might mail to a stranger.
void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('reed_backup_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('copies an existing database byte for byte', () async {
    final source = File('${tmp.path}/app.sqlite')
      ..writeAsBytesSync([1, 2, 3, 4, 5]);
    final dest = File('${tmp.path}/app.sqlite.bak');

    final result = await backupDatabaseFile(
      source: source,
      destination: dest,
      log: CrashLog.discard(),
    );

    expect(result, isNotNull, reason: 'a successful backup returns the file');
    expect(dest.existsSync(), isTrue);
    expect(
      dest.readAsBytesSync(),
      equals(source.readAsBytesSync()),
      reason: 'the backup must be an exact copy, not a truncated one',
    );
  });

  test('a missing source is not a failure and logs nothing', () async {
    final logFile = File('${tmp.path}/log.txt');
    final result = await backupDatabaseFile(
      source: File('${tmp.path}/does-not-exist.sqlite'),
      destination: File('${tmp.path}/x.bak'),
      log: CrashLog.atFile(logFile),
    );
    expect(result, isNull);
    expect(
      logFile.existsSync(),
      isFalse,
      reason:
          'a fresh install has no file yet; logging that on every launch '
          'is noise that trains a reader to ignore the log',
    );
  });

  test(
    'a backup failure does not throw and records exactly one line',
    () async {
      final source = File('${tmp.path}/app.sqlite')
        ..writeAsBytesSync([9, 9, 9]);
      // Destination inside a path whose parent is a FILE, so the copy cannot
      // create it — a deterministic IO failure.
      final blocker = File('${tmp.path}/blocker')..writeAsStringSync('x');
      final dest = File('${blocker.path}/nested.bak');
      final logFile = File('${tmp.path}/log.txt');

      // The whole point: this await completes rather than throwing out of what
      // would be the startup path.
      final result = await backupDatabaseFile(
        source: source,
        destination: dest,
        log: CrashLog.atFile(logFile),
      );

      expect(
        result,
        isNull,
        reason: 'a failed backup returns null, not an error',
      );
      expect(
        logFile.existsSync(),
        isTrue,
        reason:
            'the failure must leave a trace: it is the only signal there is',
      );
      final entries = logFile
          .readAsStringSync()
          .split('---')
          .where((e) => e.trim().isNotEmpty);
      expect(
        entries.length,
        equals(1),
        reason: 'exactly one line — not zero (silent) and not a recursion',
      );
    },
  );

  test('a backup failure never leaks phrase text into the log', () async {
    // A source "database" whose bytes contain the kind of intimate phrase a real
    // board holds. Even while backing this up and failing, the log must not
    // contain any of it — the log is user-exported.
    const torture = 'I am being hurt';
    final source = File('${tmp.path}/app.sqlite')
      ..writeAsStringSync('sqlite header ... $torture ... more rows');
    final blocker = File('${tmp.path}/blocker')..writeAsStringSync('x');
    final logFile = File('${tmp.path}/log.txt');

    await backupDatabaseFile(
      source: source,
      destination: File('${blocker.path}/nested.bak'),
      log: CrashLog.atFile(logFile),
    );

    expect(
      logFile.readAsStringSync().contains(torture),
      isFalse,
      reason:
          'the backup reads the DB bytes; none of them may reach a log '
          'the user might mail to a stranger',
    );
  });
}
