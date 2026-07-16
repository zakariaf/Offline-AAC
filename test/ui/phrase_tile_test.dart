import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_aac/model/board_grid.dart';
import 'package:offline_aac/ui/app.dart';
import 'package:offline_aac/ui/board/phrase_tile.dart';
import 'package:offline_aac/ui/core/tokens.dart';
import 'package:offline_aac/ui/strings.dart';

import '../support/tiles.dart';

/// The tile in isolation: its semantics, its whole-rectangle hit target, and
/// the empty slot's deliberate absence from the accessibility tree. Pumped bare
/// (no board, no providers) so a failure points at the widget, not the wiring.
void main() {
  Widget host(Widget child, {bool boldText = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(boldText: boldText),
      child: Theme(
        data: aacThemeData(AacPalette.ink),
        child: Scaffold(
          body: Center(child: SizedBox(width: 120, height: 140, child: child)),
        ),
      ),
    ),
  );

  final tile = kByPriority.first; // priority 1, 'I can’t talk'

  testWidgets('a filled tile is a labelled button', (tester) async {
    await tester.pumpWidget(
      host(
        PhraseTile(
          row: tile.row,
          col: tile.col,
          tile: tile,
          lit: false,
          onPressed: (_, _) {},
          onEdit: (_, _) {},
        ),
      ),
    );
    final node = tester.getSemantics(find.byType(PhraseTile));
    expect(
      node,
      isSemantics(isButton: true, label: tile.label),
      reason: 'a tile a screen reader cannot see as a button is unusable',
    );
  });

  testWidgets('the semantics label is the tile label, not the sentence', (
    tester,
  ) async {
    // The two differ on purpose: a scanning user hears the short handle on every
    // step, not the whole utterance.
    expect(tile.label, isNot(equals(tile.vocalization)));
    await tester.pumpWidget(
      host(
        PhraseTile(
          row: tile.row,
          col: tile.col,
          tile: tile,
          lit: false,
          onPressed: (_, _) {},
          onEdit: (_, _) {},
        ),
      ),
    );
    final node = tester.getSemantics(find.byType(PhraseTile));
    expect(node, isSemantics(label: tile.label));
    expect(find.bySemanticsLabel(tile.vocalization), findsNothing);
  });

  testWidgets('a lit tile announces its state through semantics, not colour', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        PhraseTile(
          row: tile.row,
          col: tile.col,
          tile: tile,
          lit: true,
          onPressed: (_, _) {},
          onEdit: (_, _) {},
        ),
      ),
    );
    final node = tester.getSemantics(find.byType(PhraseTile));
    expect(
      node,
      isSemantics(value: kSpeakingValue),
      reason:
          'the lit state must reach a screen reader; a luminance step '
          'alone is invisible to one',
    );
  });

  testWidgets('tapping a corner far from the glyphs still fires onSpeak once', (
    tester,
  ) async {
    var calls = 0;
    (int, int)? got;
    await tester.pumpWidget(
      host(
        PhraseTile(
          row: tile.row,
          col: tile.col,
          tile: tile,
          lit: false,
          onPressed: (r, c) {
            calls++;
            got = (r, c);
          },
          onEdit: (_, _) {},
        ),
      ),
    );
    // 4dp inside the top-left corner — far from the bottom-anchored label.
    final rect = tester.getRect(find.byType(PhraseTile));
    await tester.tapAt(rect.topLeft + const Offset(4, 4));
    expect(
      calls,
      equals(1),
      reason: 'the whole rect is the target, not the painted shape',
    );
    expect(
      got,
      equals((tile.row, tile.col)),
      reason: 'the coordinate is passed, never a captured phrase',
    );
  });

  group('the edit-mode remove control', () {
    Tile systemTile() => const Tile(
      buttonId: 99,
      row: 0,
      col: 0,
      label: 'Repair',
      vocalization: 'I need a moment',
      displayText: 'I need a moment',
      hidden: false,
      isSystem: true,
      priority: 1,
    );

    testWidgets('a non-system tile offers Remove and passes its button id', (
      tester,
    ) async {
      int? removed;
      await tester.pumpWidget(
        host(
          PhraseTile(
            row: tile.row,
            col: tile.col,
            tile: tile,
            lit: false,
            editing: true,
            onPressed: (_, _) {},
            onEdit: (_, _) {},
            onRemove: (id) => removed = id,
          ),
        ),
      );
      final remove = find.bySemanticsLabel('Remove ${tile.label}');
      expect(remove, findsOneWidget, reason: 'a full board frees a slot here');
      await tester.tap(remove);
      expect(
        removed,
        tile.buttonId,
        reason: 'the button id is passed, never captured content',
      );
    });

    testWidgets('the system repair phrase is never offered Remove', (
      tester,
    ) async {
      final system = systemTile();
      await tester.pumpWidget(
        host(
          PhraseTile(
            row: system.row,
            col: system.col,
            tile: system,
            lit: false,
            editing: true,
            onPressed: (_, _) {},
            onEdit: (_, _) {},
            onRemove: (_) {},
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Remove ${system.label}'),
        findsNothing,
        reason: 'the repair phrase is undeletable — no control at all, not a '
            'disabled one',
      );
    });
  });

  group('the empty slot', () {
    const empty = PhraseTile(
      row: 1,
      col: 2,
      tile: null,
      lit: false,
      onPressed: _noop,
      onEdit: _noop,
    );

    testWidgets('has no semantics node in speak mode', (tester) async {
      await tester.pumpWidget(host(empty));
      final handle = tester.ensureSemantics();
      // No node at all — excluded, not a disabled one that burns a scan step.
      expect(
        find.descendant(
          of: find.byType(PhraseTile),
          matching: find.byType(Semantics),
        ),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('invokes no callback when tapped', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        host(
          PhraseTile(
            row: 1,
            col: 2,
            tile: null,
            lit: false,
            onPressed: (_, _) => calls++,
            onEdit: (_, _) {},
          ),
        ),
      );
      await tester.tap(find.byType(PhraseTile), warnIfMissed: false);
      expect(
        calls,
        isZero,
        reason: 'a socket with nothing installed is not a target',
      );
    });

    testWidgets('still occupies its full cell', (tester) async {
      await tester.pumpWidget(host(empty));
      final size = tester.getSize(find.byType(PhraseTile));
      expect(
        size,
        equals(const Size(120, 140)),
        reason:
            'a collapsed empty cell drags the next tile into a position '
            'muscle memory has claimed',
      );
    });

    testWidgets('survives 200% text scale (there is no text)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SizedBox(width: 120, height: 140, child: empty),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('in edit mode it becomes a labelled Add-phrase button', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const PhraseTile(
            row: 1,
            col: 2,
            tile: null,
            lit: false,
            editing: true,
            onPressed: _noop,
            onEdit: _noop,
          ),
        ),
      );
      // The single highest-severity failure this flip prevents: a `+` that
      // paints but is not in the tree, so switch access can never fill a slot.
      expect(
        tester.getSemantics(find.byType(PhraseTile)),
        isSemantics(isButton: true, label: addPhraseLabel),
      );
    });

    testWidgets('the edit-mode + passes its coordinate to onEdit', (
      tester,
    ) async {
      (int, int)? edited;
      await tester.pumpWidget(
        host(
          PhraseTile(
            row: 1,
            col: 2,
            tile: null,
            lit: false,
            editing: true,
            onPressed: _noop,
            onEdit: (r, c) => edited = (r, c),
          ),
        ),
      );
      await tester.tap(find.byType(PhraseTile));
      expect(edited, equals((1, 2)));
    });

    testWidgets('the empty cell occupies the same rect in both modes', (
      tester,
    ) async {
      await tester.pumpWidget(host(empty));
      final resting = tester.getRect(find.byType(PhraseTile));

      await tester.pumpWidget(
        host(
          const PhraseTile(
            row: 1,
            col: 2,
            tile: null,
            lit: false,
            editing: true,
            onPressed: _noop,
            onEdit: _noop,
          ),
        ),
      );
      final editingRect = tester.getRect(find.byType(PhraseTile));

      expect(
        editingRect,
        equals(resting),
        reason: 'the + must not collapse or pull the next tile in',
      );
    });
  });
}

void _noop(int row, int col) {}
