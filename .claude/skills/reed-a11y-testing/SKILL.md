---
name: reed-a11y-testing
description: Reed's automated accessibility assertions — isSemantics, getSemantics, simulatedAccessibilityTraversal with startNode/endNode, meetsGuideline and its boundary-skip defect, the 76dp tap-target getSize loop, OrdinalSortKey traversal order. Use when writing test/ui/a11y_test.dart, asserting a tile is a button or announces its display label not its vocalization, or claiming accessibility is covered. Not for authoring Semantics in lib/, the four-palette contrast gate, or textScaler overflow matrices.
---

# Accessibility testing for Reed

An inaccessible accessibility app is a total failure — accessibility is a correctness property here, not polish. No lint enforces any of it: `flutter_lints` and `very_good_analysis` ship zero a11y rules, and the free `accessibility_lint` package is abandoned. So the promise is enforced in `test/` or it is enforced by discipline, and discipline is exactly what a no-telemetry app cannot rely on. A user mid-shutdown who taps a tile and hears nothing does not file a bug report.

## State the honest ceiling before writing a line

Automated checks catch a **small minority** of real accessibility issues here. Do not repeat the widely-quoted 57% figure — that is for axe-core's roughly 100 **web** rules. Flutter ships **four** guidelines, roughly the trivially machine-checkable subset, and one is known-broken. Never write a commit message, comment, or report claiming the suite "tests accessibility." Overclaiming here is precisely how an inaccessible accessibility app ships green.

## The four built-in guidelines and what each is actually worth

| Constant | Threshold | Real value |
|---|---|---|
| `androidTapTargetGuideline` | `Size(48, 48)` | Near-zero on this grid — see boundary skip |
| `iOSTapTargetGuideline` | `Size(44, 44)` | Same |
| `labeledTapTargetGuideline` | label non-empty | Near-zero — `button1` passes |
| `textContrastGuideline` | 4.5 normal / 3.0 large | Known false-negative; do not trust |

Three defects, each load-bearing:

**(a) `MinimumTapTargetGuideline` silently skips every node flush with the view edge.** Its `_isAtBoundary` check uses `_kMinimumGapToBoundary = 0.001` on all four sides and returns `Evaluation.pass()` without measuring. On a full-bleed 3×4 grid **the 10 perimeter tiles are skipped and only the 2 interior tiles are measured.** The test goes green while checking almost nothing. It also skips any node that is a link, hidden, or has neither a tap nor a long-press action.

**(b) `textContrastGuideline` has an open, unfixed false negative.** It screenshots the layer and picks foreground/background by naive light/dark colour histogram partitioning, mis-attributing background in low-variance regions: white text (`0xffffff`) on `0xfafafa` **passes**. It also only sees text findable via `find.text`, so a `CustomPainter` label is invisible to it. `MinimumTextContrastGuidelineAAA` exists and is one line, but inherits the same sampling defect.

**(c) `labeledTapTargetGuideline` only checks the label is non-empty.** A tile leaking its entire vocalization into its label passes.

Keep all four as one-line tripwires against catastrophic regression. **They are never the gate.**

## Two API facts that are commonly got wrong

`meetsGuideline` returns an `AsyncMatcher`. **`await expectLater(...)` is mandatory** — a plain `expect()` is wrong and will not do what it looks like it does.

Semantics is **ON by default** in widget tests: `testWidgets` takes `bool semanticsEnabled = true` and calls `ensureSemantics()` for you, auto-disposing the handle. The manual `tester.ensureSemantics()` / `handle.dispose()` pair is a redundant second reference-counted handle — harmless, optional, and the usual explanation for it is wrong. It is only load-bearing with `semanticsEnabled: false` or inside a plain `test()`. When it is needed, register it as `addTearDown(handle.dispose)`, never a trailing `handle.dispose()`: teardown survives a throwing `expect()` and a leaked `SemanticsHandle` is itself a flake source.

## The tests that are the gate

```dart
// test/ui/a11y_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';
import '../support/tiles.dart'; // kTestTiles: (row, col, label, vocalization, priority)

/// MinimumTapTargetGuideline has a PUBLIC const constructor and is
/// @visibleForTesting, so instantiating it in test/ is the sanctioned path —
/// no subclass, no lint. It inherits the boundary skip, which is exactly why
/// the geometry test below, not this, is the gate.
const AccessibilityGuideline aacTapTargetGuideline = MinimumTapTargetGuideline(
  size: Size(76, 76), // logical px: the guideline divides by devicePixelRatio
  link: 'https://github.com/you/offline-aac/wiki/tap-targets', // shown on failure
);

void main() {
  // (1) GEOMETRY — the real tap-target gate. Deliberately NOT meetsGuideline,
  //     which skips the 10 of 12 tiles that touch the view edge.
  testWidgets('every tile is >= 76x76 dp at 200% on the smallest phone',
      (WidgetTester tester) async {
    tester.useDevice(Device.seLike);
    await tester.pumpApp(textScaler: const TextScaler.linear(2.0));

    for (final TestTile t in kTestTiles) {
      final Size size =
          tester.getSize(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')));
      expect(size.width, greaterThanOrEqualTo(76.0),
          reason: '"${t.label}" is ${size.width}dp wide; minimum is 76dp');
      expect(size.height, greaterThanOrEqualTo(76.0),
          reason: '"${t.label}" is ${size.height}dp tall; minimum is 76dp');
    }
  });

  // (2) LABEL CORRECTNESS — the check NO guideline makes.
  testWidgets('every tile announces its DISPLAY label, never its vocalization',
      (WidgetTester tester) async {
    await tester.pumpApp();

    for (final TestTile t in kTestTiles) {
      final SemanticsNode node = tester
          .getSemantics(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')));

      // isSemantics — NOT containsSemantics, which is deprecated after
      // v3.40.0-1.0.pre. Virtually every tutorial predates this.
      expect(
        node,
        isSemantics(
          label: t.label,
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );

      expect(
        node.label,
        isNot(contains(t.vocalization)),
        reason: 'tile "${t.label}" leaks its vocalization into the semantic '
            'label; a screen reader user would hear the whole sentence on '
            'every scan step',
      );
    }
  });

  // (3) TRAVERSAL ORDER — priority, NOT layout.
  testWidgets('the screen reader visits the 12 tiles in priority order',
      (WidgetTester tester) async {
    await tester.pumpApp();

    // start:/end: are DEPRECATED after v3.15.0-15.2.pre. Use startNode:/endNode:,
    // which take FinderBase<SemanticsNode> — hence find.semantics.byLabel.
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

  // (4) ANTI-CLAMP. No guideline catches this: contrast and tap target both
  //     still pass while the text quietly stops growing.
  testWidgets('text scale is honored, never clamped', (WidgetTester tester) async {
    tester.useDevice(Device.small);

    await tester.pumpApp();
    final double base = tester.getSize(find.text('Overwhelmed')).height;

    await tester.pumpApp(textScaler: const TextScaler.linear(2.0));
    final double scaled = tester.getSize(find.text('Overwhelmed')).height;

    // 1.8, not 2.0: tolerate line-height rounding, still fail hard on a clamp.
    expect(scaled, greaterThan(base * 1.8),
        reason: 'Text did not grow at 2.0x. Someone clamped TextScaler to keep '
            'the fixed grid tidy. 200%+ must be honored.');
  });

  // (5) ADVISORY. Cheap tripwire. Never the gate.
  testWidgets('meets built-in guidelines (advisory)', (WidgetTester tester) async {
    tester.useDevice(Device.seLike);
    await tester.pumpApp(
      textScaler: const TextScaler.linear(2.0),
      accessibleNavigation: true, // Switch Access / VoiceOver on
    );

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(aacTapTargetGuideline));
  });
}
```

**Why traversal is asserted at all.** The highest-value phrases sit in the lower-centre arc for thumb reach. Under Flutter's default row-major traversal that makes "I need to leave" the 8th-to-11th thing TalkBack reads — 8–11 seconds under linear autoscan at 1s/step. The fix costs one argument: `Semantics(sortKey: OrdinalSortKey(tile.priority.toDouble()))`. Traversal order is a design decision; inheriting it from layout is not a decision. Assert priority order so nobody silently reverts it.

**Finder rule.** `find.bySemanticsLabel` for behaviour (tap, speak) — it names behaviour, not tree structure. `ValueKey('slot_r_c')` for geometry — position IS the primary key. Never `find.byType` for a tile.

## Contrast: a pure-Dart unit test, because the guideline false-passes

```dart
// test/ui/contrast_test.dart
import 'dart:ui';
import 'package:test/test.dart';

double contrastRatio(Color fg, Color bg) {
  final double l1 = fg.computeLuminance();
  final double l2 = bg.computeLuminance();
  final double hi = l1 > l2 ? l1 : l2;
  final double lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // WCAG AA is 4.5 normal / 3.0 large (large = 18px, or 14px bold). AAA is
  // 7.0 / 4.5 — defensible for an app used in distress and low light.
  // No screenshots, no histogram: this cannot false-pass the way the
  // built-in contrast guideline does.
  for (final AacTheme theme in kAllThemes) {
    test('${theme.name}: tile label on tile background meets WCAG AAA', () {
      expect(contrastRatio(theme.tileLabel, theme.tileBackground),
          greaterThanOrEqualTo(7.0));
    });

    test('${theme.name}: show-text mode meets WCAG AAA for large text', () {
      expect(contrastRatio(theme.showText, theme.showTextBackground),
          greaterThanOrEqualTo(4.5));
    });
  }
}
```

Assert contrast on **colour values**, never on rendered pixels. Every new palette must be added to `kAllThemes` — the loop is the enforcement.

## Custom guidelines: the API supports them, but usually don't

`AccessibilityGuideline` is a public abstract class with a const constructor, `FutureOr<Evaluation> evaluate(WidgetTester tester)` and `String get description`. Subclassing is fully sanctioned. `Evaluation` has `Evaluation.pass()`, `Evaluation.fail([reason])`, and an `operator +` that accumulates failures — so an `evaluate` typically folds a `result` across the semantics tree.

Two options before writing one:

- **Reconfiguring beats subclassing.** For a stricter tap target, construct `MinimumTapTargetGuideline(size:, link:)` directly, as above. It is public and `@visibleForTesting`.
- **`CustomMinimumContrastGuideline({required finder, minimumRatio = 4.5, tolerance = 0.01, description})`** exists and scopes contrast to a subset of elements — but it samples pixels, so it carries the same mis-attribution defect. Prefer the pure-Dart ratio test.

Write a subclass only for a property that is genuinely a whole-tree traversal. For anything expressible as a direct assertion on a `SemanticsNode` from `tester.getSemantics`, assert it directly — a plain `expect` gives a better failure message and no boundary-skip surprises.

## What automation genuinely cannot cover — say so plainly

**Switch Access (Android) / Switch Control (iOS) cannot be tested automatically at all.** Flutter publishes no support statement for either, and no API simulates scanning, group selection, or point scanning. Traversal order is the only proxy and it is a *weak* one: point scanning is coordinate-based with no order at all; group selection is a nested binary narrowing that reaches any of 12 items in ⌈log₂12⌉ = 4 presses regardless of order; and scanning targets *actionable* elements while semantics traversal enumerates non-actionable nodes too. A `Tab`-key `FocusTraversalPolicy` test is a fine companion, but both are regression guards on *intent* — never conformance evidence. Focus traps in edit mode and the text field are verified by hand on a device or not at all.

Do not build these — they find nothing here:

- **Espresso `AccessibilityChecks`** walks the Android **View** hierarchy. Flutter is one opaque `FlutterView` rendering to a single canvas. It sees no tiles.
- **CI a11y automation via `flutter drive`.** The semantics tree is not exposed to the platform during `flutter drive` unless an accessibility service is already running; the workaround is force-enabling one via `adb settings put secure`. Not worth the day.

**Google's Accessibility Scanner does work** — it is an `AccessibilityService` and reads Flutter's `AccessibilityBridge` virtual node tree, as does Xcode's Accessibility Inspector. Both are manual, on-device, human-driven. They belong in the pre-release checklist, not CI.

Manual-only, and each guards a top-severity failure: TalkBack/VoiceOver actually announcing the display label and speaking the vocalization on double-tap; empty slots not announced as buttons; the scan highlight being visible against every theme including high contrast; exiting edit mode and the text field using only a switch.

## Review checklist

- `expect()` on a `meetsGuideline` matcher → must be `await expectLater`.
- `containsSemantics` → use `isSemantics`.
- `start:` / `end:` on `simulatedAccessibilityTraversal` → use `startNode:` / `endNode:`.
- A trailing `handle.dispose()` → `addTearDown(handle.dispose)`.
- A tap-target claim resting on `meetsGuideline` alone → add the explicit `getSize` loop; the edge tiles are unmeasured.
- A contrast claim resting on `textContrastGuideline` → add the pure-Dart ratio test.
- Any unpinned layout or geometry test → `tester.useDevice(...)` first; the default 800×600 logical surface is wider than any phone and hides real breakage.
