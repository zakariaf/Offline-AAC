import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/data/crash_log.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/fake_speech_service.dart';
import '../support/harness.dart';
import '../support/tiles.dart';

/// The lit state: one signal doing two jobs — the confirmation that a tap landed
/// and the indicator that a phrase is in the air. It must appear when a tile is
/// pressed, persist for a floor of 120ms so a fast tap is never imperceptible,
/// clear the instant speech ends OR fails, and — because a stuck-lit tile is the
/// app lying with no telemetry to report it — force-clear on a guard timer when
/// an OEM engine accepts an utterance and never says it finished.
///
/// The barge-in order (`stop, speak, stop, speak`) and the never-silent property
/// have their own suites; this one owns the LATCH.
void main() {
  Finder tileAt(Tile t) => find.byWidgetPredicate(
    (w) => w is PhraseTile && w.row == t.row && w.col == t.col,
  );

  String? litValue(WidgetTester tester, Tile t) =>
      tester.getSemantics(tileAt(t)).value;

  final first = kByPriority.first;
  final second = kByPriority[1];

  testWidgets('a pressed tile announces the speaking state', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: FakeSpeechService());

    expect(litValue(tester, first), isEmpty, reason: 'nothing lit at rest');

    await tester.tap(tileAt(first));
    await tester.pump();

    expect(
      litValue(tester, first),
      kSpeakingValue,
      reason: 'the lit state is exposed through semantics, never colour alone',
    );
  });

  testWidgets('the light holds for at least 120ms on a fast tap', (
    tester,
  ) async {
    // The engine resolves immediately; without the floor the tile would light
    // and clear inside one frame — imperceptible to the user who most needs to
    // know the tap landed.
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: FakeSpeechService());

    await tester.tap(tileAt(first));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 119));
    expect(
      litValue(tester, first),
      kSpeakingValue,
      reason: 'cleared before 120ms — a fast tap must still be seen',
    );

    await tester.pump(const Duration(milliseconds: 2));
    expect(
      litValue(tester, first),
      isEmpty,
      reason: 'the hold is a floor, not a fixed duration; it clears once past',
    );
  });

  testWidgets('pressing the lit tile stops it and does not speak again', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);

    await tester.tap(tileAt(first));
    await tester.pump();
    expect(speech.calls, equals(<String>['stop', 'speak']));

    // The lit tile IS the stop control. Tapping it stops; it must not speak the
    // phrase a second time to a stranger.
    await tester.tap(tileAt(first));
    await tester.pump();

    expect(
      speech.calls,
      equals(<String>['stop', 'speak', 'stop']),
      reason: 'a re-tap on the lit tile stops — one more stop, no second speak',
    );
    expect(speech.spoken, hasLength(1));
    expect(litValue(tester, first), isEmpty, reason: 'stop clears the latch');
  });

  testWidgets('a failing engine clears the latch and shows the words', (
    tester,
  ) async {
    // Every detectable failure must both put the words on screen AND darken the
    // tile. A board that says "speaking" while the screen says "not spoken" is
    // the exact contradiction the sealed outcome exists to prevent.
    for (final env in SpeechEnv.detectable) {
      final speech = FakeSpeechService(env: env);
      tester.useDevice(Device.small);
      await tester.pumpApp(speech: speech);

      await tester.tap(tileAt(first));
      await tester.pump();
      // Past the hold and the immediate failure.
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        litValue(tester, first),
        isEmpty,
        reason: '$env left the tile lit after failing — a lie about speaking',
      );
      expect(
        find.text(first.vocalization),
        findsOneWidget,
        reason: '$env dropped the words instead of showing them',
      );
    }
  });

  testWidgets('a completion handler that never fires cannot leave a tile lit', (
    tester,
  ) async {
    // The worst OEM case: speak() is accepted and never reports done. The seam's
    // own 8s call timeout does not cover this — the CALL returned fine. Only the
    // independent latch guard clears it, and it must leave one line behind.
    final logFile = File(
      '${Directory.systemTemp.createTempSync('reed_lit').path}/crash_log.txt',
    );
    addTearDown(() {
      if (logFile.parent.existsSync()) logFile.parent.deleteSync(recursive: true);
    });

    final speech = FakeSpeechService(hangSpeak: true);
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech, crashLog: CrashLog.atFile(logFile));

    await tester.tap(tileAt(first));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(
      litValue(tester, first),
      kSpeakingValue,
      reason: 'the guard has not fired yet — the tile is still honestly lit',
    );

    // Past the 10s guard.
    await tester.pump(const Duration(seconds: 6));

    expect(
      litValue(tester, first),
      isEmpty,
      reason: 'the guard force-clears a latch the engine abandoned',
    );
    expect(
      logFile.readAsStringSync(),
      contains('force-cleared'),
      reason: 'the force-clear is recorded — it is the only trace that exists',
    );
  });

  testWidgets('switching tiles leaves only the new one lit', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: FakeSpeechService(hangSpeak: true));

    await tester.tap(tileAt(first));
    await tester.pump();
    await tester.tap(tileAt(second));
    await tester.pump();

    expect(litValue(tester, first), isEmpty, reason: 'the old tile goes dark');
    expect(litValue(tester, second), kSpeakingValue, reason: 'the new tile lit');
  });

  testWidgets('a tap schedules no animation frame', (tester) async {
    // Zero animation is a policy: state changes settle in one frame. A scheduled
    // frame after the tap settles means something is animating that must not.
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: FakeSpeechService());

    await tester.tap(tileAt(first));
    await tester.pump();

    expect(
      tester.binding.hasScheduledFrame,
      isFalse,
      reason: 'lighting "${first.label}" scheduled a frame — something animates',
    );
  });
}
