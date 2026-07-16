import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/board/board_screen.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/core/tokens.dart';

import '../support/harness.dart';
import '../support/tiles.dart';

/// The grid: fixed slot count, unequal gutters that are the composition, and a
/// flat surface with nothing that reads as 2014 — no card, no shadow, no
/// divider. Everything here is a rule that goes silently wrong if "tidied".
void main() {
  BoardGrid grid2x3() => BoardGrid(
    boardId: 1,
    rows: 2,
    cols: 3,
    tiles: List<Tile?>.generate(
      6,
      (i) => kTestTiles[i],
    ),
  );

  testWidgets('renders exactly 12 cells at 4x3', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    expect(find.byType(PhraseTile), findsNWidgets(12));
  });

  testWidgets('renders exactly 6 cells at 2x3', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(grid: grid2x3());
    expect(find.byType(PhraseTile), findsNWidgets(6));
  });

  testWidgets('the gutters are unequal — 14 across, 22 down', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();

    final widths = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .map((s) => s.width)
        .whereType<double>()
        .toSet();
    final heights = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .map((s) => s.height)
        .whereType<double>()
        .toSet();

    expect(
      widths,
      contains(Geom.gapColumn),
      reason: 'column gap 14 is missing',
    );
    expect(heights, contains(Geom.gapRow), reason: 'row gap 22 is missing');
    expect(
      Geom.gapColumn,
      isNot(equals(Geom.gapRow)),
      reason:
          'equal gutters read as a spreadsheet; a "tidy" to 16/16 deletes '
          'the composition and nothing else would catch it',
    );
  });

  testWidgets('the board is flat: no card, shadow, divider, or elevation', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    expect(find.byType(Card), findsNothing);
    expect(find.byType(Divider), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is Material && w.elevation > 0,
      ),
      findsNothing,
      reason: 'any elevation reads as 2014 and is banned',
    );
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).boxShadow != null,
      ),
      findsNothing,
      reason: 'a BoxShadow is the depth system this app refuses',
    );
  });

  testWidgets('the scaffold is ground, full-bleed, non-resizing', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp();
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final theme = AacTheme.of(tester.element(find.byType(BoardScreen)));
    expect(scaffold.backgroundColor, equals(theme.ground));
    expect(
      scaffold.resizeToAvoidBottomInset,
      isFalse,
      reason:
          'the keyboard covering the grid is the design; padding it up '
          'moves tiles a user reaches for by muscle memory',
    );
  });
}
