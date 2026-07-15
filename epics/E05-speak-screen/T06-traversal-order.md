# E05-T06 — Traversal order

| | |
|---|---|
| **Epic** | E05 — The speak screen |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E00-T06, E05-T02 |
| **Blocks** | Nothing |

**Skills:** `reed-a11y-coding` · `reed-a11y-testing` · `reed-tile-anatomy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

The high-priority phrases sit in the lower-centre arc because that is where a thumb lands. Under Flutter's default row-major semantic traversal, that same placement makes "I need to leave" the **8th-to-11th** thing TalkBack reads — 8–11 seconds away under Switch Access linear autoscan at 1s/step, for someone who needs to leave a room right now. The thumb-reach optimisation *actively pessimises* every screen-reader and switch user. Traversal order is a design decision; inheriting it from layout is not a decision, it is an accident, and nobody will ever report it.

## Scope

Decouple traversal from visual position. Author it from `priority`, and assert it.

**In `PhraseTile` (the filled-slot branch):**

```dart
return Semantics(
  container: true,
  button: true,
  label: button.label,                                   // display label, NOT the vocalization
  sortKey: OrdinalSortKey(button.priority.toDouble()),   // priority, NOT layout
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => onSpeak(slot.row, slot.col),
    child: ExcludeSemantics(child: _TileFace(...)),
  ),
);
```

`OrdinalSortKey` takes a `double`; `priority` is an `int` on the button model, so `.toDouble()` is required, not cosmetic. Lower ordinal is visited first — priority 1 is the first tile TalkBack reads. Confirm the priority field's polarity against the schema before wiring it: if lower priority number means *less* important in the data, the sort key must be inverted, and a silent polarity flip is the worst possible outcome here.

**The empty slot keeps no node at all.** `const ExcludeSemantics(child: SizedBox.expand())` — not `enabled: false`, which still burns a scan step on nothing. It still holds its space; it never collapses and pulls the next tile into its position. In edit mode the same cell becomes a full target (keyline, `+`, full semantics), so make the exclusion mode-dependent.

**The test — `test/ui/a11y_test.dart`, test (3) in `reed-a11y-testing`:**

```dart
testWidgets('the screen reader visits the 12 tiles in priority order',
    (WidgetTester tester) async {
  await tester.pumpApp();

  // startNode:/endNode: — start:/end: are DEPRECATED after v3.15.0-15.2.pre.
  // They take FinderBase<SemanticsNode>, hence find.semantics.byLabel.
  final Iterable<SemanticsNode> ordered =
      tester.semantics.simulatedAccessibilityTraversal(
    startNode: find.semantics.byLabel(kByPriority.first.label),
    endNode: find.semantics.byLabel(kByPriority.last.label),
  );

  expect(
    ordered.map((SemanticsNode n) => n.label).toList(),
    kByPriority.map((TestTile t) => t.label).toList(),
    reason: 'Tile traversal order changed. This rewires muscle memory for '
        'people who cannot correct it verbally.',
  );

  // The point of the whole test: traversal must NOT have been inherited
  // from the lower-centre arc by accident.
  expect(ordered.map((SemanticsNode n) => n.label).toList(),
      isNot(kTestTiles.map((TestTile t) => t.label).toList()),
      reason: 'Traversal collapsed back to row-major layout order. Someone '
          'dropped the sortKey.');
});
```

The second assertion is the load-bearing one. A test that only checks "equals priority order" passes trivially if the fixture's priority order happens to equal its layout order — so `kByPriority` in `test/support/tiles.dart` (from E00-T06) **must differ from `kTestTiles` layout order**, with at least one high-priority tile placed low in the grid. That divergence is what makes the test capable of failing.

**Out of scope:** `FocusTraversalPolicy` / `Tab`-key ordering for physical keyboards (a fine companion test, not this task); the focus ring geometry; edit-mode traversal; the type-to-speak field's position in the order; anything about the lit state or contrast.

## Acceptance criteria

- [ ] `flutter test test/ui/a11y_test.dart` passes, including both assertions in the traversal test.
- [ ] Deleting `sortKey:` from `PhraseTile` makes the traversal test go **red** — verify this by hand once, then restore. A test that passes both with and without the sort key is testing nothing.
- [ ] `kByPriority` order is not equal to `kTestTiles` layout order in `test/support/tiles.dart`, and at least one priority-1..3 tile sits in the bottom two rows of the fixture grid.
- [ ] Every filled tile's `Semantics` carries `sortKey: OrdinalSortKey(button.priority.toDouble())`; empty slots carry no semantics node (`ExcludeSemantics`), asserted with `isSemantics(...)` — never `containsSemantics(...)`, deprecated after v3.40.0-1.0.pre.
- [ ] The traversal test uses `startNode:`/`endNode:`, not the deprecated `start:`/`end:`.
- [ ] Manual, on a real device: TalkBack swipe-right from the top of the grid reaches the highest-priority phrase **first**, not eighth. Recorded in the manual checklist, because no automation covers it.

## Traps

- **Inheriting order by accident and never knowing.** No lint checks this. `flutter_lints` and `very_good_analysis` ship zero a11y rules; `accessibility_lint` is abandoned. The widget and `test/ui/` are the entire enforcement mechanism.
- **A fixture whose priority order equals its layout order.** The test then passes with the `sortKey` deleted. This is the single most likely way this task ships broken-but-green.
- **`OrdinalSortKey` only orders siblings within the same `SemanticsSortKey` grouping.** If a wrapper introduces its own sort key or a new semantics container between the grid and the tiles, the ordinals get scoped to that subtree and the tiles silently re-sort row-major. If the test goes red after an unrelated layout refactor, look for a new container, not a new sort key.
- **`ExcludeSemantics` around `_TileFace` is not optional.** Without it the label is announced twice — the `Semantics` node above already carries it.
- **Sorting by anything other than priority.** Not by row-major, not by "reading order", not by category. The label is the display label; the sort key is the priority.
- **Overselling the test.** Switch Access **group selection reaches any of 12 items in ⌈log₂12⌉ = 4 presses regardless of order**, and point scanning is coordinate-based with no order at all — only linear scanners depend on `sortKey`. Flutter publishes no Switch Access support statement and no API simulates scanning. This test is a regression guard on *intent*, never conformance evidence. Do not write a commit message claiming traversal is "accessibility tested".
- **Assuming focus ring == scan highlight.** Touch, switch, and screen reader are three different channels. Switch Access draws its own highlight, user-configurable in colour and thickness, and in group selection the highlighter colours change on every press. The `focus` ring serves keyboard and TalkBack only.
- **An unpinned test surface.** The default 800×600 logical surface is wider than any phone. `tester.useDevice(...)` before anything geometric — though traversal itself is geometry-independent, the harness pump is shared.

## Files

- `lib/ui/speak/phrase_tile.dart` — add `sortKey: OrdinalSortKey(button.priority.toDouble())` to the tile's `Semantics`; confirm empty slots stay `ExcludeSemantics`.
- `test/ui/a11y_test.dart` — the traversal test.
- `test/support/tiles.dart` — `kByPriority` and `kTestTiles`; ensure the two orders diverge.
- The manual pre-release checklist — the TalkBack swipe-order check.

## Done when

Every filled tile carries a priority-derived `OrdinalSortKey`, and a test that fails when the sort key is removed asserts the screen reader's traversal equals priority order and is not equal to layout order.
