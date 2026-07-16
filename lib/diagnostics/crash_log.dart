import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The marker a redacted phrase is replaced with. Fixed, so a reader can tell a
/// scrub from an empty string, and short, so it never itself pushes the file
/// past its ceiling.
const String _redactionMarker = '[redacted]';

/// A redaction source that knows no phrases. The default, and never null: a
/// nullable source would be dereferenced inside an error handler one day and
/// throw there, which is the one place a throw recurses. At startup, before the
/// board is read, this is also the CORRECT source — nothing is loaded to leak.
Set<String> _noRedactions() => const <String>{};

/// The on-device, user-exportable diagnostic log.
///
/// This app ships no telemetry and never will, so this file is the only line
/// of sight into the field that will ever exist. A user who taps a tile, gets
/// silence, and closes the app will not file a bug report; the only way anyone
/// learns what happened is if that user chooses to send this file.
///
/// The API is exactly two members: [open] and [record]. [redactWith] is wiring,
/// not surface — it points the net at a source of phrases, once, at startup.
final class CrashLog {
  CrashLog._(this._file);

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
  CrashLog.discard() : _file = null;

  /// A log backed by an explicit file, bypassing the directory lookup.
  ///
  /// The only reason this is not private: the redaction guarantee — that no
  /// phrase text ever reaches the log — is a property nothing else can verify.
  /// A test must be able to point the log at a file it can then read back and
  /// assert against, and to seed the [redactions] source with a known phrase so
  /// the net can be exercised. It writes through the same [record] as
  /// production; only the location differs.
  CrashLog.atFile(File file, {Set<String> Function()? redactions})
    : _file = file,
      _redactions = redactions ?? _noRedactions;

  /// The log file, or null when the path could not be resolved.
  ///
  /// Null is a working log that drops every entry rather than a broken one
  /// that throws: [open] runs before the error handlers are installed, so a
  /// throw here would be the invisible-forever crash this class exists to
  /// prevent.
  final File? _file;

  /// The set of strings that must never appear in the file, evaluated fresh on
  /// every [record] so it tracks the live board without this class holding a DB
  /// handle. Defaults to [_noRedactions] — empty, never null.
  Set<String> Function() _redactions = _noRedactions;

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
  ///
  /// The redaction source is wired later, via [redactWith], because it reads the
  /// database and this runs before the database is open. Until then the source
  /// is empty, which is correct: nothing is loaded to leak.
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
      return CrashLog._(null);
    }
  }

  /// Point the redaction net at a live source of phrases.
  ///
  /// Called once, after the database is up, with a function that returns every
  /// phrase currently on the board. Separate from construction because [open]
  /// runs before the database exists; a source that reached into the DB from
  /// here would have nothing to read. A command, not a property — a setter would
  /// demand a dead getter exposing the net's internals.
  // ignore: use_setters_to_change_properties
  void redactWith(Set<String> Function() source) => _redactions = source;

  /// Records one entry. Synchronous, flushed, bounded, redacted, cannot throw.
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
  /// Redaction happens HERE, not at the call sites. Call-site discipline —
  /// logging a fixed message, or a `SpeakFailure`'s `logLine` rather than its
  /// `spokenText` — is the primary defence, but it fails silently the first
  /// time someone interpolates an exception whose `toString()` embeds a phrase
  /// (a drift `SqliteException` carries the statement text; a `PlatformException`
  /// echoes the utterance). This is the single choke point that catches that
  /// class for handlers this file did not write.
  ///
  /// NEVER pass phrase text: no `spokenText`, no `Button.vocalization`, no
  /// label, no `display_text`, no compose-field contents. The net is a net, not
  /// a licence to log the words on purpose.
  void record(String message, StackTrace? stack) {
    final file = _file;
    if (file == null) return;
    try {
      // Scrub INSIDE the try: a redaction source that throws must be swallowed
      // like any other failure here, never allowed to escape the error handler.
      // Both the message and the RENDERED stack are scrubbed — a phrase can ride
      // in through a frame's argument text or an error's own trace string, not
      // only the message.
      final phrases = _redactions();
      final entry = StringBuffer()
        ..write(_separator)
        ..writeln(DateTime.now().toIso8601String())
        ..writeln(_scrub(message, phrases));
      if (stack != null) entry.writeln(_scrub(stack.toString(), phrases));

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

  /// Replaces every occurrence of every known phrase in [text] with the fixed
  /// marker. Empty phrases are skipped: `replaceAll('', marker)` would splice
  /// the marker between every character.
  static String _scrub(String text, Set<String> phrases) {
    var out = text;
    for (final phrase in phrases) {
      if (phrase.isEmpty) continue;
      out = out.replaceAll(phrase, _redactionMarker);
    }
    return out;
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

/// The set of phrases [CrashLog]'s net must never spell out, held in memory
/// because [CrashLog.record] is synchronous and cannot query the async database.
///
/// Populated from the live board — every label, vocalization and display_text,
/// hidden buttons included — so that if an exception's `toString()` ever smuggles
/// one of those phrases into a log line, the net scrubs it before the bytes hit
/// disk. This is defence in depth: logging `logLine` rather than `spokenText`,
/// and fixed messages rather than interpolated exceptions, is the primary guard.
class RedactionRegistry {
  final Set<String> _phrases = <String>{};

  /// The current snapshot, in the shape `CrashLog.redactionSource` expects.
  /// Returns the live set (never a copy and never null): `record` reads it
  /// synchronously with no await, so it cannot observe a half-applied
  /// [replaceWith].
  Set<String> snapshot() => _phrases;

  /// Replace the whole set with [phrases]. Called on every board change, so a
  /// tile a user just deleted stops being a phrase the net protects and a tile
  /// they just added starts. Empty strings are dropped — see [CrashLog._scrub].
  void replaceWith(Iterable<String> phrases) {
    _phrases
      ..clear()
      ..addAll(phrases.where((p) => p.isNotEmpty));
  }
}

/// Unwraps an error that merely wraps another, so the log records the real cause
/// and not the wrapper.
///
/// Riverpod 3 rethrows provider failures wrapped in `ProviderException`; logging
/// the wrapper flattens every provider error to the same useless line and
/// destroys the one diagnostic that exists. This app pins flutter_riverpod to
/// 2.x, which does not export that type — so the wrapper is recognised by SHAPE
/// (an error exposing a differently-typed `exception`) rather than by an import
/// that is neither available here nor forward-safe. A real `ProviderException`,
/// which carries `.exception`, unwraps through this unchanged if the pin ever
/// moves.
///
/// Bounded, so a self-referential wrapper cannot spin.
Object unwrapError(Object error) {
  var current = error;
  for (var depth = 0; depth < 8; depth++) {
    final inner = _wrappedCause(current);
    if (inner == null) break;
    current = inner;
  }
  return current;
}

Object? _wrappedCause(Object error) {
  Object? inner;
  try {
    // Shape check: read `.exception` if it exists. Riverpod's ProviderException
    // (and any similarly-shaped wrapper) exposes the underlying error there.
    inner = (error as dynamic).exception as Object?;
    // The NoSuchMethodError from probing an absent getter IS the signal that
    // this error is not a wrapper — the one place catching an Error is correct.
    // ignore: avoid_catching_errors
  } on NoSuchMethodError {
    return null; // No `exception` member: this error is not a wrapper.
  }
  // `identical` stops a wrapper whose `.exception` returns itself; the loop
  // bound in [unwrapError] stops any longer cycle. A wrapper wrapping another of
  // the SAME type (a nested ProviderException) is legitimate and must unwrap.
  if (inner == null || identical(inner, error)) return null;
  return inner;
}
