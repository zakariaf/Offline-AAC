# E10-T01 — The accessibility test suite

| | |
|---|---|
| **Epic** | E10 — Verification |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E05-T07 |
| **Blocks** | Nothing |

**Skills:** `reed-a11y-testing` · `reed-a11y-coding` · `reed-testing-strategy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A user mid-shutdown who scans to a tile with Switch Access and hears "button1", or who waits 8 seconds for TalkBack to reach "I need to leave" because traversal fell back to row-major, has no way to tell you. No lint enforces any of this: `flutter_lints` and `very_good_analysis` ship zero a11y rules, and the only free candidate (`accessibility_lint`) is abandoned. So the accessibility promise is enforced in `test/` or it is enforced by discipline — and discipline is exactly what a no-telemetry app cannot rely on. An inaccessible accessibility app is a total failure.

## Scope

Build `test/ui/a11y_test.dart` with five tests, in this order of authority: the geometry gate, the label gate, the traversal guard, the anti-clamp guard, and — last and explicitly advisory — the built-in guidelines.

**(1) Geometry — the real tap-target gate.** Deliberately NOT `meetsGuideline`. Pin the device first (`tester.useDevice(Device.seLike)`), pump at `TextScaler.linear(2.0)`, then loop `kTestTiles` and assert via `tester.getSize(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')))` that width and height are each `greaterThanOrEqualTo(76.0)`, with a `reason:` naming the tile and its actual dp.

**(2) Label correctness — the check no guideline makes.** For each tile, `tester.getSemantics(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')))` and assert:

```dart
expect(node, isSemantics(
  label: t.label, isButton: true, hasEnabledState: true,
  isEnabled: true, isFocusable: true, hasTapAction: true,
));
expect(node.label, isNot(contains(t.vocalization)),
  reason: 'tile "${t.label}" leaks its vocalization into the semantic label; '
      'a screen reader user would hear the whole sentence on every scan step');
```

`isSemantics`, never `containsSemantics` — the latter is deprecated after v3.40.0-1.0.pre and virtually every tutorial predates that.

**(3) Traversal order — a regression guard on intent.** The lower-centre arc holds the highest-priority phrases for thumb reach; under Flutter's default row-major traversal that makes "I need to leave" the 8th-to-11th thing TalkBack reads — 8–11 seconds under linear autoscan at 1s/step. The fix is one argument, `Semantics(sortKey: OrdinalSortKey(button.priority.toDouble()))`, and this test exists so nobody silently reverts it.

```dart
final Iterable<SemanticsNode> ordered =
    tester.semantics.simulatedAccessibilityTraversal(
  startNode: find.semantics.byLabel(kByPriority.first.label),
  endNode: find.semantics.byLabel(kByPriority.last.label),
);
expect(ordered.map((SemanticsNode n) => n.label).toList(),
    kByPriority.map((TestTile t) => t.label).toList());
expect(ordered.map((SemanticsNode n) => n.label).toList(),
    isNot(kTestTiles.map((TestTile t) => t.label).toList()),
    reason: 'Traversal collapsed back to row-major layout order. '
        'Someone dropped the sortKey.');
```

`startNode:`/`endNode:` take `FinderBase<SemanticsNode>` — hence `find.semantics.byLabel`. `start:`/`end:` are deprecated after v3.15.0-15.2.pre.

**(4) Anti-clamp.** On `Device.small`, measure `tester.getSize(find.text('Overwhelmed')).height` at default scale, re-pump at `TextScaler.linear(2.0)`, and assert `scaled > base * 1.8`. The 1.8, not 2.0, tolerates line-height rounding while still failing hard on a clamp. No guideline catches this: contrast and tap target both stay green while the text quietly stops growing.

**(5) Advisory tripwires.** Pin `Device.seLike`, pump at `TextScaler.linear(2.0)` with `accessibleNavigation: true`, then:

```dart
await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
await expectLater(tester, meetsGuideline(aacTapTargetGuideline));
```

with the stricter guideline constructed directly at the top of the file — `MinimumTapTargetGuideline` has a public const constructor and is `@visibleForTesting`, so this is the sanctioned path, no subclass:

```dart
const AccessibilityGuideline aacTapTargetGuideline = MinimumTapTargetGuideline(
  size: Size(76, 76), // logical px: the guideline divides by devicePixelRatio
  link: 'https://github.com/you/offline-aac/wiki/tap-targets',
);
```

**Document the ceiling in the file itself.** A header comment on `a11y_test.dart` stating what these five tests are and are not:

- Automated checks catch a **small minority** of real accessibility issues here. Flutter ships **four** guidelines — roughly the trivially machine-checkable subset — and one is known-broken. Do not quote the 57% figure; that is axe-core's ~100 **web** rules, a different thing entirely.
- `MinimumTapTargetGuideline` skips every node flush with the view edge (`_isAtBoundary`, `_kMinimumGapToBoundary = 0.001`, returns `Evaluation.pass()` without measuring). On a full-bleed 3×4 grid **10 perimeter tiles are skipped and only the 2 interior tiles are measured** — which is precisely why test (1), not test (5), is the gate.
- `textContrastGuideline` has an open, unfixed false negative: it screenshots the layer and partitions foreground/background by naive light/dark histogram, so white (`0xffffff`) on `0xfafafa` **passes**. It is not in this file at all; contrast is asserted on colour values in `test/ui/contrast_test.dart`.
- `labeledTapTargetGuideline` only checks the label is non-empty — a tile labelled `button1` passes, and a tile leaking its whole vocalization passes.
- **Switch Access / Switch Control cannot be tested automatically at all.** No API simulates scanning, group selection, or point scanning. Traversal order is a weak proxy: point scanning is coordinate-based with no order; group selection reaches any of 12 items in ⌈log₂12⌉ = 4 presses regardless of order; scanning targets *actionable* elements while semantics traversal enumerates non-actionable nodes too.
- Manual-only, each guarding a top-severity failure: TalkBack/VoiceOver announcing the display label and speaking the vocalization on double-tap; empty slots not announced as buttons; the scan highlight visible against every theme including high contrast; exiting edit mode and the text field using only a switch.

**Out of scope.** The contrast unit test (`test/ui/contrast_test.dart`, pure-Dart ratio over `kAllThemes`) — separate file, separate task. Custom `AccessibilityGuideline` subclasses; reconfiguring beats subclassing, and anything expressible as a direct `expect` on a `SemanticsNode` gives a better failure message. `CustomMinimumContrastGuideline` — same pixel mis-attribution defect. Espresso `AccessibilityChecks` (walks the Android **View** hierarchy; Flutter is one opaque `FlutterView`, it sees no tiles). CI a11y via `flutter drive` (semantics tree not exposed without a pre-enabled accessibility service; days of work, near-zero signal). Accessibility Scanner and Xcode Accessibility Inspector do work but are manual and on-device — they belong to the pre-release checklist.

## Acceptance criteria

- [ ] `flutter test test/ui/a11y_test.dart` passes, and the file contains exactly five `testWidgets` — geometry, label, traversal, anti-clamp, advisory.
- [ ] The geometry test asserts `>= 76.0` on both axes for all 12 entries of `kTestTiles`, under `Device.seLike` at `TextScaler.linear(2.0)`.
- [ ] Deleting `sortKey:` from `PhraseTile` turns the traversal test red on both assertions. Verify by doing it, then reverting.
- [ ] Setting a tile's semantic `label` to its `vocalization` turns the label test red. Verify by doing it, then reverting.
- [ ] Wrapping the grid in `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, …)` turns the anti-clamp test red while tests (1), (2), (3) and (5) stay green. Verify, then revert. (E05-T07's source-grep policy test also fires — that is the intended second net.)
- [ ] `grep -n 'containsSemantics\|start:\|end:' test/ui/a11y_test.dart` returns nothing.
- [ ] Every `meetsGuideline` call site is `await expectLater`; `grep -n 'expect(tester, meetsGuideline' test/ui/a11y_test.dart` returns nothing.
- [ ] Every `testWidgets` that measures geometry calls `tester.useDevice(...)` before `pumpApp`.
- [ ] No `find.byType` for a tile anywhere in the file.
- [ ] The header comment states the minority-of-issues ceiling, names the boundary skip and the 10-of-12 number, and lists the manual-only checks. No comment, test name, or commit message in this task claims the suite "tests accessibility".
- [ ] `flutter analyze` clean; the whole suite still runs under 30 s.

## Traps

- **`expect()` on a `meetsGuideline` matcher.** It returns an `AsyncMatcher`. A plain `expect()` compiles, passes, and checks nothing — it does not do what it looks like it does. `await expectLater` is mandatory.
- **Resting the tap-target claim on `meetsGuideline`.** The boundary skip means 10 of your 12 tiles are never measured. The test goes green while checking almost nothing. This is the single highest-probability failure of this task: it feels done and it is not.
- **Reaching for `textContrastGuideline` or `MinimumTextContrastGuidelineAAA` to "cover contrast here."** Both inherit the histogram sampling defect; AAA is one line and equally wrong. Also, the guideline only sees text findable via `find.text`, so a `CustomPainter` label is invisible to it.
- **`containsSemantics`.** Deprecated after v3.40.0-1.0.pre. Every tutorial you find will use it. `isSemantics`.
- **`start:`/`end:` on `simulatedAccessibilityTraversal`.** Deprecated after v3.15.0-15.2.pre. `startNode:`/`endNode:`, taking `FinderBase<SemanticsNode>`.
- **Adding `tester.ensureSemantics()` "to make semantics work."** `testWidgets` takes `bool semanticsEnabled = true` and calls it for you, auto-disposing. A manual handle is a redundant second reference-counted handle — harmless, optional, and the usual explanation for it is wrong. It is load-bearing only with `semanticsEnabled: false` or inside a plain `test()`. When genuinely needed, `addTearDown(handle.dispose)` — never a trailing `handle.dispose()`, which teardown survives a throwing `expect()` and a trailing call does not; a leaked `SemanticsHandle` is itself a flake source.
- **Skipping `tester.useDevice(...)`.** The default 800×600 logical surface is wider than any phone. The geometry test passes there and the app breaks on an SE.
- **Writing the traversal test as if it proves Switch Access works.** It does not. Group selection is order-independent; point scanning has no order. It is a regression guard on intent. State that in the comment, not just in your head.
- **The traversal test that only asserts priority order.** Without the `isNot(kTestTiles…)` assertion, a board whose layout order happens to equal priority order passes with the `sortKey` deleted. The negative assertion is the point of the test.
- **Reaching for `find.byType` on a tile.** `find.bySemanticsLabel` for behaviour, `ValueKey('slot_r_c')` for geometry — position IS the primary key.
- **Softening the anti-clamp test to `>= base`.** Then a `FittedBox` or a computed `fontSize` passes. The threshold is `base * 1.8`.
- **Growing the file to "improve a11y coverage."** The widget budget is ~60 tests across board, overflow matrix and a11y combined, inside a ~135-test, under-30-second suite. Extra `meetsGuideline` variants buy nothing; the four here are already advisory.

## Files

- Creates `test/ui/a11y_test.dart`.
- Reads `test/support/harness.dart` (`pumpApp`, `useDevice`, `Device.seLike`, `Device.small`) and `test/support/tiles.dart` (`kTestTiles`, `kByPriority`, `TestTile`). Add `kByPriority` there if E05-T07 did not.
- Touches nothing in `lib/`.

## Done when

`flutter test test/ui/a11y_test.dart` is green, deleting the `sortKey` or swapping a label for a vocalization turns it red, and the file says in its own header exactly how little of real accessibility it covers.
