import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/model/board_grid.dart';

import '../support/harness.dart';
import '../support/tiles.dart';

/// Traversal order is a design decision, and this is where it is verified. The
/// most-needed phrases sit in the lower-centre thumb arc, which a naive
/// row-major reader visits last; the sort key is what makes a screen reader
/// reach them first. Delete the sort key from PhraseTile and this test goes red
/// — a test that passes with and without it is testing nothing.
void main() {
  testWidgets('the screen reader visits tiles by priority, not by layout', (
    tester,
  ) async {
    // The fixture's priority order is deliberately not its layout order, and
    // priority-1 sits in the bottom row.
    final layoutOrder = kTestTiles.whereType<Tile>().map((t) => t.buttonId);
    expect(
      kByPriority.map((t) => t.buttonId).toList(),
      isNot(equals(layoutOrder.toList())),
      reason: 'if the fixture priority equalled layout, this proves nothing',
    );
    expect(
      kByPriority.first.row,
      equals(3),
      reason:
          'the highest-priority tile must sit low, where a row-major reader '
          'would otherwise reach it last',
    );

    tester.useDevice(Device.small);
    await tester.pumpApp();
    final handle = tester.ensureSemantics();

    // The order a screen reader actually visits nodes, sort keys respected.
    final visited = tester.semantics
        .simulatedAccessibilityTraversal()
        .map((n) => n.label)
        .toList();

    // Keep only the tile labels, in the order they were announced.
    final byLabel = {for (final t in kByPriority) t.label};
    final tileOrder = visited.where(byLabel.contains).toList();

    expect(
      tileOrder,
      equals(kByPriority.map((t) => t.label).toList()),
      reason: 'tiles must be announced in priority order; got $tileOrder',
    );

    handle.dispose();
  });
}
