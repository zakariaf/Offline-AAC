import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:offline_aac/speech/speech_controller.dart';

import '../support/fake_speech_service.dart';

/// The crash log is the only line of sight into the field this app will ever
/// have — and it is user-exportable, so it must be safe to mail to a stranger.
/// These tests hold it to five promises: it never spells out a phrase, it
/// flushes synchronously, it stays bounded, it cannot throw, and it records the
/// real cause of a wrapped error rather than the wrapper.
void main() {
  late Directory tmp;
  late File logFile;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('reed_crash_log_test');
    logFile = File('${tmp.path}/crash_log.txt');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  String bytes() => logFile.existsSync() ? logFile.readAsStringSync() : '';

  group('redaction', () {
    testWidgets('a phrase spoken through the real speak path never reaches the '
        'file — the by-construction half', (tester) async {
      // The sentence a user says when they cannot speak. If this reaches a log
      // they mail to a maintainer, the app has leaked their voice.
      const phrase = 'I need to leave, I’m not able to talk right now';

      // The REAL speak path, with an empty redaction net on purpose: this proves
      // the split between spokenText (on screen) and logLine (engine facts only)
      // holds without the net's help. The engine rejects the utterance, so the
      // failure arm runs and logs.
      final log = CrashLog.atFile(logFile);
      final speech = FakeSpeechService(env: SpeechEnv.speakReturnsZero);
      final settled = Completer<void>();
      final controller = SpeechController(
        speech: speech,
        showText: (_) {},
        log: log,
        onSettled: settled.complete,
      );
      addTearDown(controller.dispose);

      controller.speakNow(phrase);
      await settled.future;

      final logged = bytes();
      expect(
        logged,
        contains('engine rejected'),
        reason:
            'the failure must be recorded — an empty file would pass the '
            'no-phrase assertion trivially',
      );
      expect(
        logged.contains(phrase),
        isFalse,
        reason:
            'logLine carries engine facts only; spokenText never reaches '
            'record()',
      );
      // The characters of the phrase, not just the whole string: a partial leak
      // (the first clause) is still the user's words.
      expect(logged.contains('I need to leave'), isFalse);
    });

    test('a phrase riding inside an exception toString() is scrubbed by the net '
        'inside record()', () {
      // The leak nobody writes on purpose: a drift SqliteException embeds the
      // failing statement text, and a reviewer scanning call sites sees
      // `record('saveTile failed: $e', s)` and passes it. The net inside record
      // is the only thing that catches this class.
      const phrase = 'I am being hurt';
      final log = CrashLog.atFile(logFile, redactions: () => <String>{phrase});

      // Exactly the shape of SqliteException.toString(): the statement, with the
      // user's phrase inside it.
      const exceptionText =
          'SqliteException(1): near "$phrase": syntax error, statement: '
          'INSERT INTO buttons (vocalization)';
      log.record('saveTile failed: $exceptionText', StackTrace.current);

      final logged = bytes();
      expect(
        logged.contains(phrase),
        isFalse,
        reason:
            'the phrase must be scrubbed even though the call site '
            'interpolated an exception — redaction lives in record(), not at '
            'the call site',
      );
      expect(logged, contains('[redacted]'));
      // The engine/SQL facts around it survive, so the entry is still useful.
      expect(logged, contains('syntax error'));
    });

    test('redaction scrubs the rendered stack, not only the message', () {
      const phrase = 'call my sister';
      // A stack whose text carries the phrase (a frame argument rendering can).
      CrashLog.atFile(logFile, redactions: () => <String>{phrase}).record(
        'write failed',
        StackTrace.fromString('#0 frobnicate ($phrase)'),
      );

      expect(bytes().contains(phrase), isFalse);
      expect(bytes(), contains('[redacted]'));
    });
  });

  test('the write is flushed and readable synchronously, with no await between '
      'record() and the read', () {
    // The trap this guards: an IOSink or a writeAsString without flush passes a
    // test that awaits — the buffer drains before the read — and on device loses
    // the entry written microseconds before the process dies. Read it back with
    // NO await between, the way a crash on the first frame would.
    CrashLog.atFile(logFile).record(
      'startup crash before first frame',
      StackTrace.current,
    );
    expect(
      logFile.readAsStringSync(),
      contains('startup crash before first frame'),
      reason:
          'record() must flush synchronously; a buffered write loses '
          'exactly the crash you needed',
    );
  });

  test('the file stays under its byte ceiling; the newest entry survives and '
      'the oldest is gone', () {
    final log = CrashLog.atFile(logFile);

    // A distinctive first and last marker so we can prove the direction of the
    // trim. Between them, enough bulk to blow well past the 64 KiB ceiling.
    const first = 'OLDEST_ENTRY_MARKER_alpha';
    const last = 'NEWEST_ENTRY_MARKER_omega';
    final filler = 'x' * 700;

    log.record(first, null);
    for (var i = 0; i < 300; i++) {
      log.record('entry $i $filler', null);
    }
    log.record(last, null);

    final size = logFile.lengthSync();
    expect(
      size,
      lessThanOrEqualTo(64 * 1024),
      reason:
          'nothing watches a user disk fill; the log is bounded on every '
          'write',
    );
    final logged = bytes();
    expect(
      logged.contains(last),
      isTrue,
      reason: 'the newest entry is the crash the user is about to report',
    );
    expect(
      logged.contains(first),
      isFalse,
      reason:
          'the oldest entries are dropped from the FRONT; keeping them and '
          'losing the newest is the wrong-end trim',
    );
  });

  test('record() on an unwritable path returns normally and records nothing — '
      'no throw, no recursion', () {
    // A file whose PARENT is itself a file, so the append can never create it: a
    // deterministic FileSystemException from inside record()'s write.
    final blocker = File('${tmp.path}/blocker')..writeAsStringSync('x');
    final unwritable = File('${blocker.path}/nested/crash_log.txt');
    final log = CrashLog.atFile(unwritable);

    // The whole promise: this call completes rather than throwing out of what,
    // in production, is FlutterError.onError — where a throw re-enters the
    // handler and recurses until the app dies.
    expect(
      () => log.record(
        'a crash while the disk is unwritable',
        StackTrace.current,
      ),
      returnsNormally,
    );
    expect(
      unwritable.existsSync(),
      isFalse,
      reason: 'the write failed, so nothing was recorded — and nothing threw',
    );
  });

  group('ProviderException unwrapping', () {
    test('logs the wrapped cause, not the wrapper', () {
      final log = CrashLog.atFile(logFile);
      final cause = StateError('the real cause: DB open failed at v2');
      final wrapped = _ProviderException(cause);

      // The main() handler unwraps before recording; this is that composition.
      log.record(unwrapError(wrapped).toString(), StackTrace.current);

      final logged = bytes();
      expect(
        logged,
        contains('the real cause: DB open failed at v2'),
        reason:
            'Riverpod wraps provider failures; the log must carry the cause',
      );
      expect(
        logged.contains('ProviderException'),
        isFalse,
        reason:
            'logging the wrapper flattens every entry to the same useless '
            'line and destroys the only diagnostic there is',
      );
    });

    test('unwraps through nested wrappers to the root cause', () {
      const cause = FormatException('unterminated string');
      final wrapped = _ProviderException(_ProviderException(cause));
      expect(identical(unwrapError(wrapped), cause), isTrue);
    });

    test('leaves a plain error unchanged', () {
      final plain = StateError('not wrapped');
      expect(identical(unwrapError(plain), plain), isTrue);
    });
  });

  group('RedactionRegistry', () {
    test('replaceWith drops empty strings and tracks the live board', () {
      final registry = RedactionRegistry()
        ..replaceWith(<String>['Overwhelmed', '', 'I need a break']);
      expect(registry.snapshot(), <String>{'Overwhelmed', 'I need a break'});

      // A tile deleted stops being protected; a tile added starts.
      registry.replaceWith(<String>['Water please']);
      expect(registry.snapshot(), <String>{'Water please'});
    });

    test('wiring the registry into a log scrubs a board phrase from a leaked '
        'exception line', () {
      final registry = RedactionRegistry()
        ..replaceWith(<String>['I need to leave']);
      CrashLog.atFile(logFile)
        ..redactWith(registry.snapshot)
        ..record('board read failed: bad row "I need to leave"', null);

      expect(bytes().contains('I need to leave'), isFalse);
      expect(bytes(), contains('[redacted]'));
    });
  });
}

/// A stand-in for Riverpod 3's `ProviderException`, which this app's pinned 2.x
/// riverpod does not export. Same shape — a public `exception` carrying the real
/// cause — so [unwrapError]'s by-shape detection recognises it exactly as it
/// would the real type.
class _ProviderException {
  _ProviderException(this.exception);

  final Object exception;

  @override
  String toString() => 'ProviderException: $exception';
}
