import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/fake_speech_service.dart';
import '../support/pump_app.dart';

/// The end-to-end proof of the app's one promise: a tile tap yields speech OR
/// the words on screen, never neither. Driven through the real board, the real
/// controller, and the real fallback surface — the only thing faked is the
/// engine, because the engine is the thing that fails in the field where no
/// crash report will ever reach the developer.
void main() {
  const phrase = 'I need a minute';

  for (final env in SpeechEnv.detectable) {
    testWidgets('$env: a tap is never silent', (tester) async {
      final speech = FakeSpeechService(env: env);
      tester.useDevice(Device.small);
      await tester.pumpApp(speech: speech);

      await tester.tap(find.byType(PhraseTile));
      // Let the void speak path resolve and the fallback surface, plus a clock
      // advance to fire the controller's minimum-hold timer.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final spoke = speech.spoken.contains(phrase);
      final shown = find.text(phrase).evaluate().isNotEmpty;
      expect(
        spoke || shown,
        isTrue,
        reason:
            '$env produced neither speech nor visible text — silence, the '
            'one outcome this app exists to make impossible',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a failing engine shows the exact sentence, not the label', (
    tester,
  ) async {
    // The screen reader announces the tile's label; the engine and the fallback
    // carry the sentence. A test with distinct strings so a swap cannot pass.
    final speech = FakeSpeechService(env: SpeechEnv.setVoiceReturnsZero);
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);

    await tester.tap(find.byType(PhraseTile));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.text(phrase),
      findsOneWidget,
      reason: 'the fallback must show the full sentence',
    );
    expect(
      find.text('Minute'),
      findsWidgets,
      reason: 'the tile still shows its short label',
    );
  });
}
