import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/fake_speech_service.dart';
import '../support/pump_app.dart';

/// A tap while a phrase is in flight means "switch to this one, NOW", not
/// "queue" and not "ignored". Every speak is preceded by a stop, so speaking a
/// second tile barges in — which is only possible because there is no
/// if-running guard, the guard that would turn that urgent switch into silence.
void main() {
  testWidgets('speaking two tiles produces stop, speak, stop, speak', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech, tiles: 2);

    final tiles = find.byType(PhraseTile);
    // Two DIFFERENT tiles: the second barges in on the first mid-utterance.
    await tester.tap(tiles.at(0));
    await tester.pump();
    await tester.tap(tiles.at(1));
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      speech.calls,
      equals(<String>['stop', 'speak', 'stop', 'speak']),
      reason:
          'each speak barges in with a stop; nothing is queued behind an '
          'in-flight utterance',
    );
  });
}
