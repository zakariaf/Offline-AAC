import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/edit/tile_editor.dart';
import 'package:offline_aac/ui/strings.dart';

import '../../support/harness.dart';

/// The editor's UI contract: the two fields named exactly this way, "What it
/// says" collapsed until opened, and a cap on the label that refuses rather than
/// truncates. What it WRITES (user_edited, NULL vocalization, curly quotes) is
/// proven at the repository level; this holds the surface the user touches.
void main() {
  BoardGrid oneTile({required String label, required String vocalization}) {
    return BoardGrid(
      boardId: 1,
      rows: 1,
      cols: 1,
      tiles: <Tile?>[
        Tile(
          buttonId: 1,
          row: 0,
          col: 0,
          label: label,
          vocalization: vocalization,
          displayText: vocalization,
          hidden: false,
          isSystem: false,
          priority: 1,
        ),
      ],
    );
  }

  Future<void> openEditor(WidgetTester tester, BoardGrid grid) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(grid: grid, editing: true);
    await tester.tap(find.byType(PhraseTile));
    await tester.pump();
    expect(find.byType(TileEditor), findsOneWidget);
  }

  testWidgets('the two fields are named "What you see" and "What it says"', (
    tester,
  ) async {
    await openEditor(tester, oneTile(label: 'Yes', vocalization: 'Yes'));
    expect(find.text(whatYouSeeLabel), findsOneWidget);
    expect(find.text(whatItSaysLabel), findsOneWidget);
  });

  testWidgets('"What it says" is collapsed for a mirroring tile', (
    tester,
  ) async {
    // vocalization == label ⇒ mirroring ⇒ only the label field is a TextField;
    // "What it says" is the collapsed opener, not a second input.
    await openEditor(tester, oneTile(label: 'Yes', vocalization: 'Yes'));
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(openWhatItSaysChrome), findsOneWidget);
  });

  testWidgets('"What it says" is open for a tile whose speech diverges', (
    tester,
  ) async {
    await openEditor(
      tester,
      oneTile(label: 'Yes', vocalization: 'Yes, of course'),
    );
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('the 17th label character is refused, not truncated after', (
    tester,
  ) async {
    await openEditor(tester, oneTile(label: 'Hi', vocalization: 'Hi'));
    await tester.enterText(find.byType(TextField).first, '12345678901234567890');
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.controller!.text, '1234567890123456');
    expect(field.controller!.text.length, 16);
    expect(field.controller!.text.contains('…'), isFalse);
  });

  testWidgets('"What it says" is uncapped — 200 characters all remain', (
    tester,
  ) async {
    await openEditor(
      tester,
      oneTile(label: 'Hi', vocalization: 'Hi there'),
    );
    final long = 'a' * 200;
    await tester.enterText(find.byType(TextField).last, long);
    final says = tester.widget<TextField>(find.byType(TextField).last);
    expect(says.controller!.text.length, 200);
  });

  testWidgets('the editor is inline — no dialog anywhere', (tester) async {
    await openEditor(tester, oneTile(label: 'Yes', vocalization: 'Yes'));
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
