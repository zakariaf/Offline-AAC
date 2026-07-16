import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/edit/tile_editor.dart';
import 'package:offline_aac/ui/strings.dart';

import '../support/harness.dart';
import '../support/tiles.dart';

/// The editor is where a user configures their own voice; an editor a
/// screen-reader or switch user cannot drive means someone else picks the words
/// that come out of their mouth — the exact dynamic this product refuses. These
/// tests hold the mode-dependent semantics and the no-clamp form. What they
/// CANNOT hold — a focus trap, a switch run, the scan highlight — is stated in
/// the manual checklist, not implied by a green suite.
void main() {
  Finder tileAt(int row, int col) => find.byWidgetPredicate(
    (w) => w is PhraseTile && w.row == row && w.col == col,
  );

  testWidgets(
    'an empty slot is absent from the speak tree and a button in edit mode',
    (tester) async {
      final grid = fixtureGrid(emptyAt: (0, 2));

      tester.useDevice(Device.small);
      await tester.pumpApp(grid: grid);
      expect(
        find.bySemanticsLabel(addPhraseLabel),
        findsNothing,
        reason: 'no wasted scan step on an empty socket in speak mode',
      );

      await tester.pumpApp(grid: grid, editing: true);
      expect(
        tester.getSemantics(tileAt(0, 2)),
        isSemantics(
          isButton: true,
          label: addPhraseLabel,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
        reason: 'a switch user must be able to reach and fill an empty slot',
      );
    },
  );

  testWidgets('the edit-mode tile label never contains the spoken sentence', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(editing: true);
    final tile = kTestTiles.firstWhere((t) => t != null && t.row == 1)!;
    expect(tile.vocalization, isNot(tile.label));

    // The edit-face node is labelled "Edit <handle>", never the sentence.
    final node = tester.getSemantics(
      find.bySemanticsLabel('Edit ${tile.label}'),
    );
    expect(node.label, contains(tile.label));
    expect(
      node.label.contains(tile.vocalization),
      isFalse,
      reason: 'a scanning user hears the handle, never the whole utterance',
    );
  });

  testWidgets('the editor form lays out at 200% on the smallest phone', (
    tester,
  ) async {
    tester.useDevice(Device.seLike);
    await tester.pumpApp(editing: true, textScale: 2);
    await tester.tap(tileAt(0, 0));
    await tester.pump();
    expect(find.byType(TileEditor), findsOneWidget);
    // Let text wrap and the form scroll; a clamp is banned and would be the
    // silent fix a red overflow tempts.
    expect(tester.takeException(), isNull);
  });

  testWidgets('an editor field label scales with text size, never clamped', (
    tester,
  ) async {
    Future<double> labelHeight(double scale) async {
      tester.useDevice(Device.small);
      await tester.pumpApp(editing: true, textScale: scale);
      await tester.tap(tileAt(0, 0));
      await tester.pump();
      return tester.getSize(find.text(whatYouSeeLabel)).height;
    }

    final base = await labelHeight(1);
    final scaled = await labelHeight(2);
    // 1.8, not 2.0, tolerates line-height rounding while still failing hard on a
    // clamp (which would leave scaled == base).
    expect(scaled, greaterThan(base * 1.8));
  });

  testWidgets('a 20-character label shows an announced counter', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(editing: true);
    await tester.tap(tileAt(0, 0));
    await tester.pump();

    await tester.enterText(
      find.byType(TextField).first,
      '12345678901234567890',
    );
    await tester.pump();
    // The cap is 16; the count is stated plainly, in a live region, not a red
    // alarm. The field holds 16, the counter says so — never a silent truncate.
    expect(find.text('16 of 16 characters'), findsOneWidget);
  });

  testWidgets('the edit-mode surface passes the labelled-tap-target tripwire', (
    tester,
  ) async {
    // An ADVISORY tripwire, not proof of accessibility: Flutter's guidelines
    // check a trivially machine-checkable subset, and labeledTapTargetGuideline
    // only checks a label is non-empty. It catches a control that lost its label
    // entirely; it does not catch an editor a switch user cannot escape. The
    // real coverage is the manual Switch Access / TalkBack passes.
    tester.useDevice(Device.small);
    await tester.pumpApp(editing: true);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}
