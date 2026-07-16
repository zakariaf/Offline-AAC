import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The on-device, user-exportable diagnostic log.
///
/// This app ships no telemetry and never will, so this file is the only line
/// of sight into the field that will ever exist. A user who taps a tile, gets
/// silence, and closes the app will not file a bug report; the only way anyone
/// learns what happened is if that user chooses to send this file.
///
/// The API is exactly two members. Nothing else belongs here.
final class CrashLog {
  const CrashLog._(this._file);

  /// A log that accepts every entry and writes nothing.
  ///
  /// For tests, and for any caller that must hold a [CrashLog] before one can
  /// exist on disk. This is the same null-file state [open] falls back to, not
  /// a second code path — a test-only variant of [record] would be a test of
  /// itself.
  ///
  /// It exists because the alternative was worse: with only a private
  /// constructor, no widget test could build a tree that reads the log, so the
  /// startup path — the one place a swallowed error is invisible forever — was
  /// the one path with no test coverage.
  const CrashLog.discard() : _file = null;

  /// A log backed by an explicit file, bypassing the directory lookup.
  ///
  /// The only reason this is not private: the redaction guarantee — that no
  /// phrase text ever reaches the log — is a property nothing else can verify.
  /// A test must be able to point the log at a file it can then read back and
  /// assert against. It writes through the same [record] as production; only
  /// the location differs.
  const CrashLog.atFile(File file) : _file = file;

  /// The log file, or null when the path could not be resolved.
  ///
  /// Null is a working log that drops every entry rather than a broken one
  /// that throws: [open] runs before the error handlers are installed, so a
  /// throw here would be the invisible-forever crash this class exists to
  /// prevent.
  final File? _file;

  /// The byte ceiling. Nothing is watching a user's disk fill, so the file is
  /// bounded on every write. 64 KiB holds far more entries than any single
  /// report needs and is small enough to attach to an email.
  static const int _maxBytes = 64 * 1024;

  /// How much of the file survives a trim. Trimming to exactly [_maxBytes]
  /// would re-trim on the very next write; dropping to half amortises the
  /// read-rewrite cost across many entries.
  static const int _keepBytes = _maxBytes ~/ 2;

  static const String _separator = '\n---\n';

  /// Opens the log. Called FIRST in `main()`, before anything that can throw.
  ///
  /// The file is not created here — [record] appends, which creates on demand.
  /// That keeps the only failure surface in [open] the directory lookup, and
  /// keeps an app that never crashes from leaving an empty file on disk.
  static Future<CrashLog> open() async {
    try {
      // Application *support*, matching the database: internal, not surfaced
      // in the OS file browser where a user could delete it to save space.
      final dir = await getApplicationSupportDirectory();
      return CrashLog._(File(p.join(dir.path, 'crash_log.txt')));
    } on Object {
      // A log that cannot find its directory must still hand main() a usable
      // object. Degrading to dropped entries keeps launch alive; throwing here
      // would kill it before either error handler exists.
      return const CrashLog._(null);
    }
  }

  /// Records one entry. Synchronous, flushed, bounded, and cannot throw.
  ///
  /// Synchronous and flushed are the feature, not a tuning knob: the entry
  /// that matters most is the one written microseconds before the process
  /// dies. An IOSink, a `writeAsString` without `flush: true`, or any buffer
  /// drained later all pass their tests — the test awaits, the buffer drains —
  /// and on device lose exactly the startup crash you needed.
  ///
  /// It is `void` on purpose. Making it return a Future forces every call site
  /// into `unawaited(...)` and reopens the buffering problem.
  ///
  /// NEVER pass phrase text: no `spokenText`, no `Button.vocalization`, no
  /// label, no `display_text`, no compose-field contents. This file is
  /// user-exportable, and a user mailing it to a stranger must not mail their
  /// voice with it. Log a failure's `logLine`, which is written to carry only
  /// engine facts and voice names — that is why it exists separately from the
  /// text shown on screen.
  void record(String message, StackTrace? stack) {
    final file = _file;
    if (file == null) return;
    try {
      final entry = StringBuffer()
        ..write(_separator)
        ..writeln(DateTime.now().toIso8601String())
        ..writeln(message);
      if (stack != null) entry.writeln(stack);

      file.writeAsStringSync(
        entry.toString(),
        mode: FileMode.append,
        flush: true,
      );
      _trim(file);
      // The reason for the suppression is the block below, kept with the
      // suppression so it can never travel without it.
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      // INTENTIONAL bare catch, INTENTIONALLY discarded.
      //
      // This runs inside FlutterError.onError and PlatformDispatcher.onError.
      // If it throws, the error handler's error re-enters the error handler
      // and recurses until the app dies with nothing on disk.
      //
      // Effective Dart says never silently discard from a bare catch. This is
      // the one place in this codebase where that rule is wrong. Do NOT "fix"
      // this by rethrowing, by adding an `on` clause, or by logging the
      // failure to this same file.
    }
  }

  /// Drops the OLDEST entries once the file exceeds [_maxBytes].
  ///
  /// The direction is load-bearing. Truncating the newest would keep a perfect
  /// record of the first crash the user ever hit and none of the one they are
  /// writing to you about.
  ///
  /// Sizes are measured in BYTES, never in String length: the two differ the
  /// moment an entry carries a non-ASCII character, and a ceiling enforced in
  /// the wrong unit is not a ceiling. Cuts land on entry boundaries so the
  /// file never opens mid-stack-trace.
  ///
  /// Called only from inside [record]'s try block, which owns the catch.
  static void _trim(File file) {
    if (file.lengthSync() <= _maxBytes) return;

    final entries = file.readAsStringSync().split(_separator)
      ..removeWhere((e) => e.isEmpty);

    // Newest first, keeping until the budget runs out.
    final kept = <String>[];
    var size = 0;
    for (final entry in entries.reversed) {
      final bytes = utf8.encode(entry).length + _separator.length;
      // Always keep the newest entry whole, however large: half a stack trace
      // diagnoses nothing, and it is the entry the user is reporting.
      if (kept.isNotEmpty && size + bytes > _keepBytes) break;
      kept.add(entry);
      size += bytes;
    }

    file.writeAsStringSync(
      kept.reversed.map((e) => '$_separator$e').join(),
      flush: true,
    );
  }
}
