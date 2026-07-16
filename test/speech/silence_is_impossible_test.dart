import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/fake_speech_service.dart';
import '../support/harness.dart';
import '../support/tiles.dart';

/// The end-to-end proof of the app's one promise: a tile tap yields speech OR
/// the words on screen, never neither. Driven through the real board, the real
/// controller, and the real fallback surface — only the engine is faked,
/// because the engine is what fails in the field where no crash report reaches
/// the developer.
void main() {
  // A known tile from the fixture: what it shows, and the sentence it speaks.
  final tile = kByPriority.first; // priority 1, 'I can’t talk'
  final phrase = tile.vocalization;

  Finder tileFinder(WidgetTester tester) => find.byWidgetPredicate(
    (w) => w is PhraseTile && w.row == tile.row && w.col == tile.col,
  );

  for (final env in SpeechEnv.detectable) {
    testWidgets('$env: a tap is never silent', (tester) async {
      final speech = FakeSpeechService(env: env);
      tester.useDevice(Device.small);
      await tester.pumpApp(speech: speech);

      await tester.tap(tileFinder(tester));
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
    final speech = FakeSpeechService(env: SpeechEnv.setVoiceReturnsZero);
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);

    await tester.tap(tileFinder(tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.text(phrase),
      findsWidgets,
      reason: 'the fallback shows the full sentence',
    );
    expect(
      find.text(tile.label),
      findsWidgets,
      reason: 'the tile still shows its short label',
    );
  });
}
