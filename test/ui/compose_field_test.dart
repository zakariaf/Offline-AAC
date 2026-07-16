import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/fake_speech_service.dart';
import '../support/harness.dart';

/// The type-to-speak field: no keyboard ambush at launch, the sentence spoken
/// exactly as typed, and the field growing never moving a tile.
void main() {
  testWidgets('no keyboard at cold launch', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    expect(
      tester.testTextInput.isVisible,
      isFalse,
      reason:
          'a keyboard covering the grid at launch is catastrophic for '
          'someone opening the app mid-shutdown',
    );
  });

  testWidgets('speaks the typed text exactly, unmodified', (tester) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);

    // A deliberate ellipsis and no trailing period — rewriting a character under
    // someone's cursor is hostile; this is their sentence.
    const typed = 'give me a sec…';
    await tester.enterText(find.byType(TextField), typed);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(
      speech.spoken,
      equals(<String>[typed]),
      reason: 'no trim, no case change, no appended period',
    );
  });

  testWidgets('whitespace-only submit speaks nothing and shows no error', (
    tester,
  ) async {
    final speech = FakeSpeechService();
    tester.useDevice(Device.small);
    await tester.pumpApp(speech: speech);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(
      speech.spoken,
      isEmpty,
      reason: 'there is no accusation to make for typing nothing',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing a whole sentence never moves a tile', (tester) async {
    // The field is fixed-height on purpose: it is the fallback surface for
    // failed speech, and a field that grew with its content would shove the grid
    // down under a user's muscle memory mid-sentence. Text size reflows the board
    // deliberately (see label_fit); the field's own content must not. At one
    // scale the grid is frozen.
    tester.useDevice(Device.small);
    await tester.pumpApp();

    final before = <(int, int), Offset>{};
    for (final tile in tester.widgetList<PhraseTile>(find.byType(PhraseTile))) {
      before[(tile.row, tile.col)] = tester.getTopLeft(
        find.byWidgetPredicate(
          (w) => w is PhraseTile && w.row == tile.row && w.col == tile.col,
        ),
      );
    }

    await tester.enterText(
      find.byType(TextField),
      'a much longer sentence than the field can show on one line at once',
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    for (final entry in before.entries) {
      final (r, c) = entry.key;
      final now = tester.getTopLeft(
        find.byWidgetPredicate(
          (w) => w is PhraseTile && w.row == r && w.col == c,
        ),
      );
      expect(
        now,
        equals(entry.value),
        reason: 'tile ($r, $c) moved when the field filled with text',
      );
    }
  });
}
