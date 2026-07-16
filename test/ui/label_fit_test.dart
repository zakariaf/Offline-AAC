import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/harness.dart';
import '../support/tiles.dart';

/// The fine net under the overflow matrix, and the one that catches the failure
/// no RenderFlex ever reports: a label clamped to [kMaxLabelLines] and quietly
/// missing its last words. `maxLines` drops the overflowing lines with no
/// exception, no ellipsis, and a green test — unreadable words on a real phone.
/// The responsive grid exists to prevent exactly this by widening tiles and
/// scrolling; this proves it worked, at every scale, on the tightest device.
///
/// `didExceedMaxLines` is the assertion the whole design turns on: true means a
/// line was dropped. It must be false for every tile at every supported scale.
/// The harness loads the shipped font, so these line counts are the phone's, not
/// Ahem's.
void main() {
  // The exact ladder the acceptance names: 1.3 and 1.5 catch the nonlinear
  // mid-range, 3.0 is Larger Accessibility Sizes.
  const scales = <double>[1, 1.3, 1.5, 2, 3];

  Finder tileFinder(int row, int col) => find.byWidgetPredicate(
    (w) => w is PhraseTile && w.row == row && w.col == col,
  );

  for (final scale in scales) {
    testWidgets('no label loses a word at ${scale}x', (tester) async {
      // 360x800 at 3x: the tightest board the app ships, where a tile is
      // narrowest and a label is likeliest to lose its tail.
      tester.useDevice(Device.small);
      await tester.pumpApp(textScale: scale);

      // The coarse net first: if any tile flex-overflowed, that is a separate
      // and louder bug, and it would make the paragraph reads below meaningless.
      expect(tester.takeException(), isNull);

      for (final tile in kByPriority) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: tileFinder(tile.row, tile.col),
            matching: find.text(tile.label),
          ),
        );
        expect(
          paragraph.didExceedMaxLines,
          isFalse,
          reason:
              '"${tile.label}" lost a line at ${scale}x — the grid should have '
              'dropped a column or grown the tile so every word stayed visible',
        );
      }
    });
  }

  testWidgets('the default board is a clean 3-column grid', (tester) async {
    // Replaces a golden: at the default text size every tile in a row shares a
    // top and every tile in a column shares a left. Reflow that nudges one tile
    // out of alignment moves it under someone's muscle memory, and a human can
    // read this failure where a pixel diff needs decoding.
    tester.useDevice(Device.small);
    await tester.pumpApp();

    for (var row = 0; row < 4; row++) {
      final top = tester.getRect(tileFinder(row, 0)).top;
      for (var col = 1; col < 3; col++) {
        expect(
          tester.getRect(tileFinder(row, col)).top,
          moreOrLessEquals(top, epsilon: 0.5),
          reason: 'tile ($row,$col) broke its row baseline',
        );
      }
    }
    for (var col = 0; col < 3; col++) {
      final left = tester.getRect(tileFinder(0, col)).left;
      for (var row = 1; row < 4; row++) {
        expect(
          tester.getRect(tileFinder(row, col)).left,
          moreOrLessEquals(left, epsilon: 0.5),
          reason: 'tile ($row,$col) broke its column',
        );
      }
    }
  });

  testWidgets('an empty slot still occupies its cell', (tester) async {
    // grid_slots.button_id is nullable; a collapsed empty cell drags the next
    // tile into a coordinate muscle memory has already claimed.
    tester.useDevice(Device.small);
    await tester.pumpApp(grid: fixtureGrid(emptyAt: (0, 0)));

    final size = tester.getSize(tileFinder(0, 0));
    expect(size.width, greaterThan(0));
    expect(size.height, greaterThan(0));
  });

  testWidgets('a label scales with the user text size, never clamped', (
    tester,
  ) async {
    // The grep in no_text_clamping_test catches the named clamping APIs; this
    // catches a clamp built by hand. 'Yes' stays one line at both sizes, so its
    // height is pure scale. 1.8 not 2.0 tolerates line-height rounding while
    // still failing hard on any clamp.
    const label = 'Yes';
    tester.useDevice(Device.small);

    await tester.pumpApp();
    final base = tester.getSize(find.text(label)).height;

    await tester.pumpApp(textScale: 2);
    final scaled = tester.getSize(find.text(label)).height;

    expect(scaled, greaterThan(base * 1.8));
  });
}
