import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/harness.dart';

/// The board must hold at every device and every text scale, bold or not,
/// without a single label overflowing — because a tile that overflows at speak
/// time is silence for exactly the users (large text, low vision) this app is
/// for. A RenderFlex overflow fails a widget test by default; nothing here
/// suppresses that, so a green run is a real guarantee.
///
/// The board reflows to fewer columns and scrolls as text grows, so this is now
/// the coarse net — "no configuration the layout picks ever flex-overflows" —
/// and label_fit is the fine one that proves the reflow actually kept every
/// word. 1.3 and 1.5 sit in the list because nonlinear device scaling makes the
/// mid-range the non-obvious part; 3.0 is Larger Accessibility Sizes territory.
/// TextScaler.linear over-approximates on purpose: Android 14+ scales large text
/// LESS than linear, so this stresses big labels harder than a device would.
///
/// 3 devices x 5 scales x 2 bold = 30 cases.
void main() {
  const scales = <double>[1, 1.3, 1.5, 2, 3];

  for (final device in Device.all) {
    for (final scale in scales) {
      for (final bold in <bool>[false, true]) {
        testWidgets(
          '${device.name} @${scale}x ${bold ? 'bold' : 'regular'}: no overflow',
          (tester) async {
            tester.useDevice(device);
            await tester.pumpApp(textScale: scale, boldText: bold);
            expect(find.byType(PhraseTile), findsNWidgets(12));
            expect(
              tester.takeException(),
              isNull,
              reason:
                  'a label overflowed on ${device.name} at ${scale}x '
                  '${bold ? "bold" : ""} — that is silence for a large-text user',
            );
          },
        );
      }
    }
  }
}
