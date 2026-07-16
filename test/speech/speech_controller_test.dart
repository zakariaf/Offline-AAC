import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/diagnostics/crash_log.dart';
import 'package:offline_aac/speech/speech_controller.dart';

import '../support/fake_speech_service.dart';

/// The speak path, unit-tested without a widget in sight. Every environment the
/// engine can present is driven through [SpeechController] and the one question
/// is asked each time: did the words reach the speaker, or the screen? Never
/// neither. This is the suite that stands in for the crash reports this app will
/// never receive.
void main() {
  late FakeSpeechService speech;
  late List<String> shown;
  late CrashLog log;
  late File logFile;
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('reed_speech_ctrl');
    logFile = File('${tmp.path}/log.txt');
    log = CrashLog.atFile(logFile);
    speech = FakeSpeechService();
    shown = [];
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  SpeechController controller({void Function(String)? showText}) =>
      SpeechController(
        speech: speech,
        log: log,
        showText: showText ?? shown.add,
      );

  // Pumps the microtasks the void speakNow schedules so its Future resolves.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  const phrase = 'I need a minute';

  group('a failure always puts the words on screen', () {
    // One case per detectable failure environment, so a new SpeechEnv value is a
    // compile error until it is decided here whether it surfaces text.
    for (final env in SpeechEnv.detectable) {
      test('$env shows the phrase', () async {
        speech.env = env;
        controller().speakNow(phrase);
        await settle();
        expect(
          shown,
          contains(phrase),
          reason:
              '$env produced neither speech nor on-screen text — the worst '
              'outcome the app can produce, and no user will report it',
        );
      });
    }
  });

  test('a successful utterance shows nothing', () async {
    // reportedSuccessButSilent is the fake believing it spoke. From the speak
    // path's view that is success, so no text is shown — which is exactly why
    // the real silent-success can only be caught by the manual device pass.
    speech.env = SpeechEnv.reportedSuccessButSilent;
    controller().speakNow(phrase);
    await settle();
    expect(shown, isEmpty);
  });

  test('a throwing showText does not escape, and is logged', () async {
    // showText is a callback into the UI; if it throws, the speak path must not
    // let that propagate to PlatformDispatcher.onError detached from the tap.
    speech.env = SpeechEnv.speakReturnsZero;
    controller(showText: (_) => throw StateError('render failed')).speakNow(
      phrase,
    );
    await settle();
    final logged = logFile.existsSync() ? logFile.readAsStringSync() : '';
    expect(
      logged,
      contains('speak path threw:'),
      reason: 'a throw inside the fallback must be recorded, not swallowed',
    );
  });

  test('no phrase ever reaches the log', () async {
    // Across every failure, the log carries engine facts and voice names only.
    // The log is user-exported; a phrase in it is a voice mailed to a stranger.
    for (final env in SpeechEnv.detectable) {
      speech.env = env;
      controller().speakNow(phrase);
      await settle();
    }
    final logged = logFile.existsSync() ? logFile.readAsStringSync() : '';
    expect(
      logged.contains(phrase),
      isFalse,
      reason: 'the phrase leaked into the exportable log',
    );
  });

  group('barge-in', () {
    test('every speak is preceded by a stop, in order', () async {
      final c = controller()..speakNow('first');
      await settle();
      c.speakNow('second');
      await settle();
      // A re-tap means "say it again / I need this NOW", so speak must never sit
      // behind an if-running guard. Stop-then-speak, twice.
      expect(speech.calls, equals(['stop', 'speak', 'stop', 'speak']));
    });

    test('the engine receives the exact text passed', () async {
      // The sentence, not the tile's shorter label. Nothing in the type system
      // distinguishes two Strings, so this is asserted directly.
      controller().speakNow('the whole sentence, verbatim');
      await settle();
      expect(speech.spoken, equals(['the whole sentence, verbatim']));
    });
  });

  test('an outcome that arrives after dispose is ignored', () async {
    controller()
      ..speakNow(phrase)
      ..dispose();
    await settle();
    // The utterance resolved after teardown; its result must not drive a UI that
    // is gone. Nothing shown, nothing thrown.
    expect(shown, isEmpty);
  });
}
