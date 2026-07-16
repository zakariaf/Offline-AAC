import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/responsive_grid.dart';
import 'package:offline_aac/ui/core/tokens.dart';

import '../support/fonts.dart';

/// Unit coverage for the two functions the board's responsive layout turns on,
/// tested against the real font because their answers are font metrics. The
/// widget suites prove the plane USES them; this proves the functions are right
/// in isolation, including the edges a full-board test never reaches.
void main() {
  // A pure-`test` file: nothing initializes the binding for us the way
  // testWidgets would, and loadAppFonts reaches for the asset bundle.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  const dir = TextDirection.ltr;
  const style = AacType.tile;
  const wide = <String>['Yes', 'No', 'Give me a minute', 'I need to leave'];

  group('chooseColumns', () {
    test('keeps every requested column when the labels fit', () {
      // A roomy plane at the default text size: nothing forces a reduction.
      final cols = chooseColumns(
        contentWidth: 360,
        maxCols: 3,
        labels: wide,
        style: style,
        scaler: TextScaler.noScaling,
        direction: dir,
      );
      expect(cols, 3);
    });

    test('reduces columns as text scale grows', () {
      int at(double scale) => chooseColumns(
        contentWidth: 312, // a 360dp phone less its margins
        maxCols: 3,
        labels: wide,
        style: style,
        scaler: TextScaler.linear(scale),
        direction: dir,
      );
      // Monotonic: larger text never yields MORE columns.
      expect(at(1) >= at(1.5), isTrue);
      expect(at(1.5) >= at(3), isTrue);
      // And by the largest scale the tightest board is a single column.
      expect(at(3), 1);
    });

    test('never returns fewer than one, even on an absurd width', () {
      final cols = chooseColumns(
        contentWidth: 10,
        maxCols: 3,
        labels: wide,
        style: style,
        scaler: const TextScaler.linear(3),
        direction: dir,
      );
      expect(cols, 1);
    });

    test('an empty board keeps its full column count', () {
      // No labels means nothing to overflow; the shell must not collapse.
      final cols = chooseColumns(
        contentWidth: 312,
        maxCols: 3,
        labels: const <String>[],
        style: style,
        scaler: const TextScaler.linear(3),
        direction: dir,
      );
      expect(cols, 3);
    });
  });

  group('minTileHeight', () {
    test('grows with text scale', () {
      double at(double scale) => minTileHeight(
        contentWidth: 312,
        cols: 1,
        labels: wide,
        style: style,
        scaler: TextScaler.linear(scale),
        direction: dir,
      );
      expect(at(2), greaterThan(at(1)));
    });

    test('is at least the two insets even with no labels', () {
      final height = minTileHeight(
        contentWidth: 312,
        cols: 3,
        labels: const <String>[],
        style: style,
        scaler: TextScaler.noScaling,
        direction: dir,
      );
      expect(height, 2 * Geom.tileInset);
    });
  });
}
