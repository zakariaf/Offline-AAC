import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';

import '../support/harness.dart';
import '../support/tiles.dart';

/// Reorder and hide, expressed as labelled controls a screen reader and a switch
/// user can reach — never a drag, which both are locked out of. The boundary
/// controls are ABSENT, not disabled, so a tap never lands on a control that
/// does nothing.
void main() {
  // Fixture labels, so the semantic-label assertions never drift from the tiles.
  String labelAt(int row, int col) => kTestTiles
      .firstWhere((t) => t != null && t.row == row && t.col == col)!
      .label;

  testWidgets('a mid-board tile exposes Move up, Move down, and Hide', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(editing: true);

    final label = labelAt(1, 0); // 'I can hear you' — row 1 of a 4-row board
    expect(find.bySemanticsLabel('Move $label up'), findsOneWidget);
    expect(find.bySemanticsLabel('Move $label down'), findsOneWidget);
    expect(find.bySemanticsLabel('Hide $label'), findsOneWidget);
  });

  testWidgets('the labels use the DISPLAY label, not the sentence', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(editing: true);
    final tile = kTestTiles.firstWhere((t) => t != null && t.row == 1)!;
    expect(tile.vocalization, isNot(tile.label));
    // The move control names the short handle; a scanning user must not hear the
    // whole sentence on every step.
    expect(find.bySemanticsLabel('Move ${tile.vocalization} up'), findsNothing);
  });

  testWidgets('row 0 has no Move up and the last row has no Move down', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(editing: true);

    // Absence of the node, not a disabled-looking pixel.
    expect(find.bySemanticsLabel('Move ${labelAt(0, 0)} up'), findsNothing);
    expect(find.bySemanticsLabel('Move ${labelAt(3, 0)} down'), findsNothing);
  });

  testWidgets('a hidden tile is absent from the speak tree, present in edit', (
    tester,
  ) async {
    final grid = _gridWith(
      _fixtureTile(0, 0).copyWith(hidden: true),
    );

    // Speak mode: the hidden tile renders exactly like an empty slot — no node,
    // no label anywhere in the tree.
    tester.useDevice(Device.small);
    await tester.pumpApp(grid: grid);
    expect(find.byType(PhraseTile), findsOneWidget, reason: 'the cell is there');
    expect(
      find.bySemanticsLabel(_fixtureTile(0, 0).label),
      findsNothing,
      reason: 'a hidden tile is silent to a screen reader in speak mode',
    );

    // Edit mode: it is visible and offers Unhide, named by its display label.
    await tester.pumpApp(grid: grid, editing: true);
    expect(
      find.bySemanticsLabel('Unhide ${_fixtureTile(0, 0).label}'),
      findsOneWidget,
    );
  });

  testWidgets('the repair phrase has no Hide control', (tester) async {
    final systemTile = _fixtureTile(0, 0).copyWith(isSystem: true);
    tester.useDevice(Device.small);
    await tester.pumpApp(grid: _gridWith(systemTile), editing: true);

    expect(find.bySemanticsLabel('Hide ${systemTile.label}'), findsNothing);
    // But it can still be moved and edited — is_system only blocks hiding.
    expect(find.bySemanticsLabel('Edit ${systemTile.label}'), findsOneWidget);
  });

  testWidgets('the edit grid renders at 200% with controls and no overflow', (
    tester,
  ) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(editing: true, textScale: 2);
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Move ${labelAt(1, 0)} up'), findsOneWidget);
  });

  testWidgets('tapping a control schedules no animation frame', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(editing: true);
    await tester.tap(find.bySemanticsLabel('Move ${labelAt(1, 0)} up'));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}

Tile _fixtureTile(int row, int col) =>
    kTestTiles.firstWhere((t) => t != null && t.row == row && t.col == col)!;

/// A 1x1 board holding one tile, for the hidden / system single-cell cases.
BoardGrid _gridWith(Tile tile) => BoardGrid(
  boardId: 1,
  rows: 1,
  cols: 1,
  tiles: <Tile?>[tile.copyWith(row: 0, col: 0)],
);
