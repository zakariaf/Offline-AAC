# a11y-testing

> Phase: **research** · Agent `a3c68e016b45b2d53` · Run `wf_12b14467-451`

## Result

## Summary

Flutter's built-in a11y guideline API is real, current, and cheap to adopt — but it is far weaker than its reputation, and for THIS app's geometry it is close to a no-op unless you know two specific traps. Trap 1: `MinimumTapTargetGuideline` silently SKIPS any node whose paint bounds touch the view boundary (`_isAtBoundary`, gap threshold 0.001) — a full-bleed 3x4 grid means the edge tiles, which is most of them, are never checked and the test passes vacuously. Trap 2: `textContrastGuideline` has a long-standing open false-negative (flutter#103235: white-on-#fafafa PASSES), so it cannot be trusted as the contrast gate. The API itself is confirmed: `final handle = tester.ensureSemantics(); await expectLater(tester, meetsGuideline(androidTapTargetGuideline)); handle.dispose();` is correct and current, with exact thresholds Android 48x48, iOS 44x44, contrast 4.5:1 normal / 3.0:1 large (large = 18px, or 14px bold). The custom 76dp guideline needs NO subclassing — `MinimumTapTargetGuideline` has a public const constructor (`const MinimumTapTargetGuideline({required Size size, required String link})`) and is `@visibleForTesting`, so instantiating it at Size(76,76) inside `test/` is the sanctioned path; `AccessibilityGuideline` is a plain abstract class with a const ctor if you do want a custom one. A live API break matters here: `containsSemantics` is DEPRECATED after v3.40.0-1.0.pre in favor of `isSemantics` — on Flutter 3.44 stable, most tutorials you'll find are already wrong. The highest-value test for this project is not `meetsGuideline` at all: it is `tester.semantics.simulatedAccessibilityTraversal()`, which pins the exact order a screen reader AND a switch scanner visit the 12 tiles — the one automated proxy for Switch Access/Switch Control, which are otherwise manual-only. Espresso `AccessibilityChecks` is useless on Flutter (View-hierarchy-based; Flutter is one FlutterView), while Google's Accessibility Scanner DOES work because it is an accessibility service and reads Flutter's AccessibilityBridge virtual node tree — but it is manual and cannot go in CI. There are no a11y lints in `flutter_lints`; DCM has a handful (`avoid-missing-image-alt`, `prefer-action-button-tooltip`, `prefer-text-rich`) that don't cover what matters here. Deque's 57%-of-issues automation figure is for axe-core's ~100 web rules; Flutter's four guidelines are a small fraction of that, so budget accordingly: automated a11y here is a regression net, and a written manual device checklist is the actual correctness gate.

### The documented meetsGuideline/ensureSemantics pattern is current and correct on Flutter 3.44.

*Confidence: high, **LOAD-BEARING***

`testWidgets('a11y', (tester) async { final SemanticsHandle handle = tester.ensureSemantics(); await tester.pumpWidget(const App()); await expectLater(tester, meetsGuideline(androidTapTargetGuideline)); handle.dispose(); });` — confirmed against docs.flutter.dev/ui/accessibility/accessibility-testing. `ensureSemantics()` is required (semantics tree is off by default in tests) and `handle.dispose()` is required. `meetsGuideline` must be awaited via expectLater because `AccessibilityGuideline.evaluate` returns `FutureOr<Evaluation>` and the contrast guideline is genuinely async (it screenshots the layer).

- https://docs.flutter.dev/ui/accessibility/accessibility-testing

- https://api.flutter.dev/flutter/flutter_test/meetsGuideline.html

### Exact thresholds: androidTapTargetGuideline = Size(48,48); iOSTapTargetGuideline = Size(44,44); contrast 4.5 normal / 3.0 large; large text = 18px or 14px bold; default assumed font size 12.

*Confidence: high, **LOAD-BEARING***

Read from packages/flutter_test/lib/src/accessibility.dart master. `const AccessibilityGuideline androidTapTargetGuideline = MinimumTapTargetGuideline(size: Size(48.0, 48.0), link: 'https://support.google.com/accessibility/android/answer/7101858?hl=en');` and `iOSTapTargetGuideline = MinimumTapTargetGuideline(size: Size(44.0, 44.0), link: <HIG url>)`. In MinimumTextContrastGuideline: `kMinimumRatioNormalText = 4.5`, `kMinimumRatioLargeText = 3.0`, `kLargeTextMinimumSize = 18`, `kBoldTextMinimumSize = 14`, `_kDefaultFontSize = 12.0`, `_tolerance = -0.01`. Sizes are compared in logical pixels (`paintBounds.size / view.devicePixelRatio`), so Size(76,76) means 76dp.

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart

### CRITICAL FOR THIS APP: MinimumTapTargetGuideline silently skips every tappable node whose bounds touch the view edge — a full-bleed 3x4 grid would make the tap-target test pass vacuously on the edge tiles.

*Confidence: high, **LOAD-BEARING***

Source: `final Rect viewRect = Offset.zero & view.physicalSize; if (_isAtBoundary(paintBounds, viewRect)) { return result; }` where `_isAtBoundary` returns true unless the child has a gap > `_kMinimumGapToBoundary` (0.001) on ALL four sides. It also skips nodes touching a scrollable ancestor's edge (`current.flagsCollection.hasImplicitScrolling && _isAtBoundary(...)`). In a 3x4 grid that reaches the screen edges, the 10 perimeter tiles are skipped and only the 2 interior tiles are actually measured. The test goes green while checking almost nothing. Additional skips in `shouldSkipNode`: nodes with neither tap nor longPress action, `isHidden` nodes, and `isLink` nodes (per WCAG target-size). Nodes with `isMergedIntoParent` are skipped too (the merged parent gets checked instead, which is the desired behavior for a tile).

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart

### A custom 76dp guideline requires NO subclassing — MinimumTapTargetGuideline's const constructor is public and the class is @visibleForTesting.

*Confidence: high, **LOAD-BEARING***

`@visibleForTesting class MinimumTapTargetGuideline extends AccessibilityGuideline { const MinimumTapTargetGuideline({required this.size, required this.link}); final Size size; final String link; ... }`. So `const MinimumTapTargetGuideline(size: Size(76,76), link: '<your docs url>')` works, and because of @visibleForTesting the analyzer accepts it inside test/ with no lint. Contrast: `LabeledTapTargetGuideline` has a PRIVATE constructor (`const LabeledTapTargetGuideline._()`) so it cannot be re-parameterized or subclassed — only the `labeledTapTargetGuideline` const is usable. `AccessibilityGuideline` itself is a public, extendable abstract class: `abstract class AccessibilityGuideline { const AccessibilityGuideline(); FutureOr<Evaluation> evaluate(WidgetTester tester); String get description; }`, with `Evaluation.pass()`, `Evaluation.fail(String reason)`, `final bool passed`, `final String? reason`, and `operator +` that ANDs results and newline-joins reasons.

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart

- https://api.flutter.dev/flutter/flutter_test/AccessibilityGuideline-class.html

### textContrastGuideline has an open, unfixed false-negative and must not be the contrast gate.

*Confidence: high, **LOAD-BEARING***

flutter/flutter#103235: `meetsGuideline(textContrastGuideline)` PASSES with white text (0xffffff) on 0xfafafa. Still open, P2. Mechanism: the guideline screenshots the render layer and samples pixels, picking foreground/background from a color histogram over the text's paint bounds (`find.text(text).hitTestable()`), so it mis-attributes which color is 'background' in low-variance regions and on anti-aliased/blended text. It also only evaluates nodes whose label/value text is findable via `find.text`, so text drawn in a CustomPainter or as an image is invisible to it.

- https://github.com/flutter/flutter/issues/103235

### There is an undocumented-in-blogs WCAG AAA contrast guideline class available.

*Confidence: high*

`class MinimumTextContrastGuidelineAAA extends MinimumTextContrastGuideline { const MinimumTextContrastGuidelineAAA(); }` with `kAAAMinimumRatioNormalText = 7.0` and `kAAAMinimumRatioLargeText = 4.5`. Usable directly as `meetsGuideline(const MinimumTextContrastGuidelineAAA())`. Relevant for an AAC app used in distress/low-light, but it inherits the same #103235 sampling defect.

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart

### BREAKING/CURRENT: containsSemantics is deprecated after v3.40.0-1.0.pre; use isSemantics. matchesSemantics is NOT deprecated.

*Confidence: high, **LOAD-BEARING***

api.flutter.dev for containsSemantics states: 'Migrate to isSemantics instead. This feature was deprecated after v3.40.0-1.0.pre.' Its implementation now just delegates every parameter to `isSemantics()`. Since stable is 3.44.0, this deprecation is live and virtually every tutorial/blog predates it. Semantics: `isSemantics(...)` = partial match, only what you specify is checked. `matchesSemantics(...)` = strict, unspecified flags/actions default to false-expected (so it fails if the node has an extra flag you didn't declare). Both take ~85 named params including label, value, hint, identifier, isButton, isEnabled, hasEnabledState, isFocusable, isFocused, isTextField, isHidden, isImage, isHeader, isLink, hasTapAction, hasLongPressAction, hasFocusAction, onTapHint, onLongPressHint, customActions, rect, size, textDirection, and `List<Matcher>? children`.

- https://api.flutter.dev/flutter/flutter_test/containsSemantics.html

- https://api.flutter.dev/flutter/flutter_test/isSemantics.html

- https://api.flutter.dev/flutter/flutter_test/matchesSemantics.html

### Screen-reader traversal order IS automatable via SemanticsController.simulatedAccessibilityTraversal — and it is the best available proxy for switch-scanning order.

*Confidence: high, **LOAD-BEARING***

Accessed as `tester.semantics`. Signature: `Iterable<SemanticsNode> simulatedAccessibilityTraversal({FinderBase<Element>? start, FinderBase<Element>? end, FinderBase<SemanticsNode>? startNode, FinderBase<SemanticsNode>? endNode, FlutterView? view})`. Also `SemanticsNode find(FinderBase<Element> finder)`. It simulates traversal 'as if by assistive technologies'. Because Android Switch Access and iOS Switch Control scan in the same platform traversal order the screen reader uses, pinning this order is the only automated signal you can get about switch scanning.

- https://api.flutter.dev/flutter/flutter_test/SemanticsController-class.html

### Espresso AccessibilityChecks does NOT work usefully on a Flutter app; Google's Accessibility Scanner DOES.

*Confidence: medium, **LOAD-BEARING***

Flutter renders into a single FlutterView with no child Android Views. Espresso's AccessibilityChecks runs the Accessibility Test Framework over the Android View hierarchy, so it sees one opaque view and finds nothing meaningful. Accessibility Scanner, by contrast, is an installed AccessibilityService and reads AccessibilityNodeInfo — which Flutter's `AccessibilityBridge` populates as a virtual view hierarchy ('AccessibilityBridge causes Android to treat Flutter SemanticsNodes as if they were accessible Android Views', identified by virtual view IDs via AccessibilityNodeProvider). So Scanner works, but it is a manual, on-device, human-driven tool — not CI. Deque axe DevTools Mobile also supports Flutter via the same mechanism (commercial).

- https://api.flutter.dev/javadoc/io/flutter/view/AccessibilityBridge.html

- https://developer.android.com/training/testing/espresso/accessibility-checking

- https://docs.deque.com/devtools-mobile/2025.7.2/en/flutter/

### Flutter's semantics tree is not exposed to the Android platform during flutter drive unless an accessibility service is already running — blocking naive CI a11y automation.

*Confidence: high, **LOAD-BEARING***

flutter/flutter#111110, open, P2: 'When using flutter drive, Flutter's semantics tree doesn't produce virtual Android Views.' Reporter confirms 'If TalkBack is enabled, the view hierarchy exists even during flutter drive. But this is an ugly and annoying workaround.' Affects Android 9-13. Consequence: any CI plan that shells out to a native a11y auditor against a driven Flutter app needs an accessibility service force-enabled on the emulator (adb settings put secure enabled_accessibility_services ...), which is fragile. For a solo 2-week MVP this is not worth building.

- https://github.com/flutter/flutter/issues/111110

### Switch Access / Switch Control cannot be tested automatically at all. Manual only.

*Confidence: high, **LOAD-BEARING***

Flutter publishes no Switch Control/Switch Access support statement, and there is no test API that simulates switch scanning, group selection, or point scanning. The only automatable proxy is traversal order (above). Everything else — whether a tile is reachable, whether the scan highlight is visible against your theme, whether edit mode traps the scanner, whether the type-to-speak field can be exited — is a human-on-device check.

- https://docs.flutter.dev/ui/accessibility/assistive-technologies

### There are no accessibility lint rules in flutter_lints. DCM has a few, none of which cover this app's risks.

*Confidence: high, **LOAD-BEARING***

flutter_lints / package:lints ship zero a11y rules. DCM (dcm.dev, commercial with a free tier) has `avoid-missing-image-alt` (Image without semanticLabel), `prefer-action-button-tooltip` (FloatingActionButton without tooltip), `prefer-text-rich` (RichText vs Text.rich), `prefer-dedicated-media-query-method`. None enforce 'every tile has a semantic label', 'no clamped TextScaler', or 'no hardcoded tile height'. The pub package `flutter_accessibility_scanner` is a runtime debug-overlay widget, not a linter, and is low-adoption — not a dependency worth taking for a permanence-oriented open-source app.

- https://dcm.dev/blog/2025/06/30/accessibility-flutter-practical-tips-tools-code-youll-actually-use/

- https://pub.dev/packages/flutter_accessibility_scanner

### Automated a11y checking catches a minority of real issues; the best-evidenced figure is 57%, and Flutter's four guidelines are far below that.

*Confidence: medium, **LOAD-BEARING***

Deque's Automated Accessibility Coverage Report: anonymized data from 2,000+ audits, 13,000+ pages, ~300,000 issues, found automation completely covered 57% of ISSUES (the commonly-cited ~30% figure counts WCAG success criteria instead, which understates it because a few issue types dominate by volume). But that 57% is axe-core's ~100 web rules. Flutter ships FOUR guidelines (tap size, label presence, contrast) — roughly the subset axe would call 'trivially machine-checkable' — and one of them (contrast) is known-broken. Realistic expectation for Flutter's built-ins: well under half of what axe catches, i.e. a small minority of real issues. This is not an argument against them; it is an argument that they are a regression tripwire, not a gate.

- https://www.deque.com/blog/automated-testing-study-identifies-57-percent-of-digital-accessibility-issues/

- https://www.deque.com/automated-accessibility-coverage-report/

### Automated guidelines cannot catch the failure modes that would actually hurt this app's users.

*Confidence: high, **LOAD-BEARING***

Specifically NOT caught: (1) label CORRECTNESS — labeledTapTargetGuideline only checks a label is non-empty, so a tile labeled 'button1' or a tile whose semantic label leaks the vocalization ('I need to leave, I'm not able to talk right now') instead of the display label ('Overwhelmed') passes; (2) traversal ORDER sanity (order is assertable but no guideline checks it); (3) whether the announced label matches the spoken TTS output — the whole label/vocalization split is semantically invisible to the tooling; (4) reachability/focus traps in edit mode; (5) whether TTS actually produced audio; (6) real screen-reader pronunciation, verbosity, and hint text; (7) overflow/clipping at 200% TextScaler (contrast/tap-size guidelines don't notice text clipped to nothing — you need golden or explicit overflow assertions); (8) color-only meaning; (9) live-region announcement timing.

- https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_test/lib/src/accessibility.dart

### Accessibility feature flags (textScaler, boldText, disableAnimations, highContrast) are settable in widget tests two ways, and the MediaQuery-wrapper way is the one to use.

*Confidence: high, **LOAD-BEARING***

Preferred and hermetic: wrap the widget under test in `MediaQuery(data: const MediaQueryData(textScaler: TextScaler.linear(2.0), boldText: true, disableAnimations: true, highContrast: true), child: app)`. Global alternative: `tester.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(...)` and `tester.platformDispatcher.textScaleFactorTestValue = 2.0`, which REQUIRE `addTearDown(tester.platformDispatcher.clearAllTestValues)` or they leak into later tests. Note `textScaleFactor` is deprecated framework-wide in favor of `TextScaler` (nonlinear scaling for Android 14); use `TextScaler.linear(2.0)` and `MediaQuery.textScalerOf(context)`. Flutter's own media_query_test.dart covers disableAnimations, boldText, highContrast, onOffSwitchLabels.

- https://api.flutter.dev/flutter/widgets/MediaQueryData-class.html

- https://docs.flutter.dev/release/breaking-changes/deprecate-textscalefactor

- https://github.com/flutter/flutter/blob/master/packages/flutter/test/widgets/media_query_test.dart

### What the Flutter team itself does: it dogfoods these guidelines in-repo and treats semantics as unit-testable data.

*Confidence: medium*

packages/flutter_test/test/accessibility_test.dart tests the guidelines themselves. Across the framework, widget a11y is asserted with `tester.getSemantics(finder)` + `matchesSemantics(...)`, and with SemanticsTester dumping expected trees — i.e. they assert the semantics NODE CONTENT, not just guideline conformance. Flutter 3.32 (May 2025) rebuilt semantics tree compilation (~80% faster) and fixed TalkBack link recognition, indicating the semantics layer is actively maintained. Notably, the team pairs this with manual screen-reader passes; there is no CI screen-reader automation in the Flutter repo.

- https://github.com/flutter/flutter/blob/master/packages/flutter_test/test/accessibility_test.dart

- https://dcm.dev/blog/2025/12/23/top-flutter-features-2025/

## Recommendations

- **[must]** Do NOT rely on meetsGuideline(androidTapTargetGuideline) to enforce the 76dp tiles. Assert tile geometry directly with tester.getSize()/getRect() over all 12 tiles, because the guideline silently skips every tile touching the view edge.
  - _isAtBoundary skips nodes flush with the view rect. A full-bleed 3x4 grid would check only the 2 interior tiles and pass green. A direct size assertion has no skip logic, no false pass, and gives a better failure message. Keep meetsGuideline as a cheap extra tripwire, not as the gate.
- **[should]** Add the custom 76dp guideline as `const aacTapTargetGuideline = MinimumTapTargetGuideline(size: Size(76, 76), link: '<repo docs url>#tap-targets')` in test/, not a hand-rolled subclass.
  - MinimumTapTargetGuideline's const ctor is public and @visibleForTesting, so this is the sanctioned use and produces no lint. Writing your own subclass duplicates transform/skip logic you'd get wrong. Accept that it inherits the boundary-skip flaw — which is exactly why the direct geometry assertion above is the real gate.
- **[must]** Pin the exact screen-reader traversal order of all 12 tiles with tester.semantics.simulatedAccessibilityTraversal() as a hard-coded expected list.
  - This is the single highest-value a11y test in this project. A 3x4 grid must traverse row-major and predictably; a regression here silently reorders a user's muscle-memory board. It is also the only automated proxy for Switch Access/Switch Control scan order, which is otherwise untestable. With no telemetry, this test is the only thing that will ever tell you the order broke.
- **[must]** Assert each tile's semantics with isSemantics(...), not containsSemantics(...).
  - containsSemantics is deprecated after v3.40.0-1.0.pre and you are on 3.44 stable. isSemantics is the drop-in replacement with identical params. Using the deprecated name in a codebase whose exit plan is open-sourcing hands a stranger a deprecation warning on day one.
- **[must]** Assert that each tile's semantic label is the DISPLAY label ('Overwhelmed') and explicitly assert it is NOT the vocalization string.
  - labeledTapTargetGuideline only checks a label exists and is non-empty. The label!=vocalization split is the heart of this data model, and getting it backwards means a screen-reader user hears a paragraph on every tile while scanning. No automated guideline can catch this; only an explicit per-tile assertion can. Test both directions: label is right AND vocalization is absent from the label.
- **[must]** Treat textContrastGuideline as advisory only; enforce contrast with a pure-Dart unit test over your theme's color pairs instead.
  - flutter#103235 (open) means white-on-#fafafa passes. A tiny unit test computing WCAG contrast ratio from your ThemeData color pairs is deterministic, has no screenshot sampling, runs in milliseconds, and cannot false-pass. For an app used in distress/low-light, target AAA (7.0 normal / 4.5 large) — the ratio math is ~10 lines. Optionally also run meetsGuideline(const MinimumTextContrastGuidelineAAA()) since it's one line, but never let it be the only check.
- **[must]** Run the whole a11y suite parameterized over TextScaler.linear(1.0, 1.5, 2.0, 3.0) and boldText true/false, wrapping in MediaQuery rather than mutating platformDispatcher.
  - TextScaler at 200%+ must be honored and never clamped — a stated correctness property. A for-loop over scale factors turns one test into four with no extra code. MediaQuery wrapping is hermetic; platformDispatcher test values leak across tests unless you addTearDown(clearAllTestValues), which is a footgun for a stranger reading the repo.
- **[should]** Add an explicit 'no clamped TextScaler' test: assert that a tile's rendered text height actually grows between 1.0x and 2.0x, and that nothing overflows.
  - The most likely way to break the 200% promise is a well-meaning MediaQuery override that clamps textScaler to keep the fixed grid tidy. No guideline catches clamping — contrast and tap-size both still pass. Asserting the height genuinely increases catches it. Pair with expecting zero RenderFlex overflow exceptions (tester.takeException()) at 3.0x.
- **[avoid]** Skip Espresso AccessibilityChecks and any CI screen-reader automation entirely.
  - Espresso's ATF reads the Android View hierarchy; Flutter is one FlutterView, so it sees nothing. And flutter#111110 means the virtual node tree isn't even exposed during flutter drive unless an accessibility service is pre-enabled. Building this would consume a large slice of a 2-week MVP and produce near-zero signal. This is the clearest 'skip it' in this dimension.
- **[avoid]** Do not add flutter_accessibility_scanner or DCM as dependencies for a11y.
  - flutter_lints has zero a11y rules, and DCM's four a11y rules (avoid-missing-image-alt, prefer-action-button-tooltip, prefer-text-rich, prefer-dedicated-media-query-method) cover none of this app's actual risks. A commercial linter is also a liability for an open-source exit plan — a stranger can't run your CI. Your per-tile semantics tests already enforce more than these rules would.
- **[must]** Write docs/a11y-manual-checklist.md with a dated, device-specific manual pass, and require it before every release tag.
  - Automated checks catch a minority of issues even with axe's ~100 web rules (Deque: 57% of issues); Flutter's four guidelines catch far less, and Switch Control/Access are 100% manual. With no telemetry you will never learn of a field failure, so the manual pass IS the safety net. Minimum checklist: (1) TalkBack — swipe through all 12 tiles, confirm order + display labels, confirm double-tap speaks the vocalization; (2) VoiceOver same; (3) Android Switch Access — confirm every tile reachable, confirm exit from edit mode and from the text field; (4) iOS Switch Control same, incl. item + point scanning; (5) system font at max — no clipping in tiles or show-text mode; (6) Accessibility Scanner run on the grid screen (it works — it reads AccessibilityBridge virtual nodes); (7) Xcode Accessibility Inspector audit; (8) silent switch ON — confirm audio still plays (guards the .ambient regression).
- **[should]** Structure the suite as one shared harness (pumpGrid with seeded 12 tiles) + five test groups: geometry, labels, traversal order, scaling, guidelines.
  - A stranger picking this up needs the a11y suite to read as an executable spec of the accessibility promise. One helper that pumps a deterministic 12-tile board, then groups named exactly after the properties ('every tile is a labeled button', 'traversal is row-major', 'text scales to 300% without clipping') documents intent better than prose. Zero animation helps here: no pumpAndSettle races, deterministic frames, so these tests will be stable.

### The shared harness — deterministic 12-tile board (no animation = no pumpAndSettle races)

```dart
// test/a11y/harness.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 12 fixed slots, row-major. Labels are DISPLAY labels; the
/// vocalization is deliberately different (Open Board Format semantics).
const kTestTiles = <({int row, int col, String label, String vocalization})>[
  (row: 0, col: 0, label: 'Overwhelmed', vocalization: "I need to leave, I'm not able to talk right now"),
  (row: 0, col: 1, label: 'Yes',         vocalization: 'Yes'),
  (row: 0, col: 2, label: 'No',          vocalization: 'No'),
  (row: 1, col: 0, label: 'Wait',        vocalization: 'Please give me a moment'),
  (row: 1, col: 1, label: 'Help',        vocalization: 'I need help'),
  (row: 1, col: 2, label: 'Pain',        vocalization: 'I am in pain'),
  (row: 2, col: 0, label: 'Water',       vocalization: 'Can I have some water'),
  (row: 2, col: 1, label: 'Toilet',      vocalization: 'I need the toilet'),
  (row: 2, col: 2, label: 'Thanks',      vocalization: 'Thank you'),
  (row: 3, col: 0, label: 'Repeat',      vocalization: 'Could you repeat that'),
  (row: 3, col: 1, label: 'Slower',      vocalization: 'Please speak more slowly'),
  (row: 3, col: 2, label: 'Write',       vocalization: 'I would rather write it down'),
];

/// Pumps the grid with semantics enabled and a controlled MediaQuery.
/// Returns the SemanticsHandle — caller MUST dispose (use addTearDown).
Future<void> pumpGrid(
  WidgetTester tester, {
  TextScaler textScaler = TextScaler.noScaling,
  bool boldText = false,
  Size surface = const Size(400, 800),
}) async {
  final handle = tester.ensureSemantics();
  addTearDown(handle.dispose);

  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: surface,
        textScaler: textScaler,
        boldText: boldText,
        disableAnimations: true, // matches the zero-animation design rule
      ),
      child: const MaterialApp(home: GridScreen(/* seeded repo */)),
    ),
  );
  // No pumpAndSettle: zero animation means one pump is a settled frame.
}
```

addTearDown(handle.dispose) is safer than a trailing handle.dispose() — it still runs if an expect() throws, so one failing test doesn't cascade into 'semantics already enabled' errors in the rest of the suite.

### Geometry gate — the real 76dp enforcement (does NOT use meetsGuideline)

```dart
// test/a11y/geometry_test.dart
// WHY NOT meetsGuideline: MinimumTapTargetGuideline skips any node whose
// paint bounds touch the view edge (_isAtBoundary, gap threshold 0.001).
// A full-bleed 3x4 grid => the 10 perimeter tiles are silently skipped and
// the guideline passes vacuously. This test has no skip logic.

testWidgets('every one of the 12 tiles is at least 76x76 dp', (tester) async {
  await pumpGrid(tester);

  for (final tile in kTestTiles) {
    final finder = find.byKey(ValueKey('tile_${tile.row}_${tile.col}'));
    expect(finder, findsOneWidget, reason: 'slot (${tile.row},${tile.col}) missing');

    final size = tester.getSize(finder);
    expect(
      size.width, greaterThanOrEqualTo(76.0),
      reason: '"${tile.label}" is ${size.width}dp wide; min tap target is 76dp',
    );
    expect(
      size.height, greaterThanOrEqualTo(76.0),
      reason: '"${tile.label}" is ${size.height}dp tall; min tap target is 76dp',
    );
  }
});

// Cheap extra tripwire. Keep it, but never let it be the only check.
testWidgets('meets built-in tap target guidelines (advisory)', (tester) async {
  await pumpGrid(tester);
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline)); // 48x48
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));     // 44x44
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
});
```

The reason: strings matter enormously here. With no telemetry and possible abandonment, a failure message that names the tile and prints the actual dp is the difference between a stranger fixing it in 30 seconds and giving up.

### Custom 76dp AccessibilityGuideline — no subclassing needed

```dart
// MinimumTapTargetGuideline has a PUBLIC const ctor and is @visibleForTesting,
// so instantiating it in test/ is the sanctioned path (no lint).
const aacTapTargetGuideline = MinimumTapTargetGuideline(
  size: Size(76.0, 76.0), // logical px (dp): source divides by devicePixelRatio
  link: 'https://github.com/you/offline-aac/blob/main/docs/a11y.md#tap-targets',
);

testWidgets('meets the 76dp AAC tap target guideline', (tester) async {
  await pumpGrid(tester);
  await expectLater(tester, meetsGuideline(aacTapTargetGuideline));
});

// If you ever DO need a real custom guideline, AccessibilityGuideline is a
// plain public abstract class with a const ctor:
class NoTinyLabelGuideline extends AccessibilityGuideline {
  const NoTinyLabelGuideline();

  @override
  String get description => 'Tile semantic labels must be human-readable';

  @override
  FutureOr<Evaluation> evaluate(WidgetTester tester) {
    var result = const Evaluation.pass();
    for (final view in tester.binding.renderViews) {
      result += _walk(view.owner!.semanticsOwner!.rootSemanticsNode!);
    }
    return result; // Evaluation.operator+ ANDs passed, newline-joins reasons
  }

  Evaluation _walk(SemanticsNode node) {
    var result = const Evaluation.pass();
    node.visitChildren((child) { result += _walk(child); return true; });
    final data = node.getSemanticsData();
    if (data.hasAction(ui.SemanticsAction.tap) &&
        RegExp(r'^(button|tile|item)\s*\d+$', caseSensitive: false).hasMatch(data.label)) {
      result += Evaluation.fail('$node: placeholder label "${data.label}"');
    }
    return result;
  }
}
```

LabeledTapTargetGuideline canNOT be reused this way — its ctor is private (const LabeledTapTargetGuideline._()). Only MinimumTapTargetGuideline, MinimumTextContrastGuideline, MinimumTextContrastGuidelineAAA, and CustomMinimumContrastGuideline have public ctors.

### The single highest-value test: traversal order (and the switch-scan proxy)

```dart
// test/a11y/traversal_test.dart
testWidgets('screen reader / switch scanner visits the 12 tiles row-major', (tester) async {
  await pumpGrid(tester);

  final traversal = tester.semantics.simulatedAccessibilityTraversal();

  // Keep only the tile nodes (drop app bar, text field, etc.).
  final tileLabels = traversal
      .map((n) => n.label)
      .where((l) => kTestTiles.any((t) => t.label == l))
      .toList();

  expect(
    tileLabels,
    kTestTiles.map((t) => t.label).toList(), // row-major, hard-coded
    reason: 'Tile traversal order changed. This breaks muscle memory for '
            'screen reader AND switch users, who scan in this same order.',
  );
});

// Scope the traversal to just the grid, skipping chrome:
testWidgets('grid traversal is bounded by first and last tile', (tester) async {
  await pumpGrid(tester);

  final ordered = tester.semantics.simulatedAccessibilityTraversal(
    start: find.byKey(const ValueKey('tile_0_0')),
    end:   find.byKey(const ValueKey('tile_3_2')),
  );

  expect(ordered.length, 12, reason: 'expected exactly 12 nodes between first and last tile');
});
```

Android Switch Access and iOS Switch Control scan in the same platform traversal order the screen reader uses, so this is the ONLY automated signal you can get about switch scanning. Everything else about switches is manual.

### Per-tile semantics — with the label/vocalization assertion no guideline can make

```dart
// test/a11y/labels_test.dart
testWidgets('every tile is a labeled, enabled button showing the DISPLAY label', (tester) async {
  await pumpGrid(tester);

  for (final tile in kTestTiles) {
    final finder = find.byKey(ValueKey('tile_${tile.row}_${tile.col}'));

    // isSemantics — NOT containsSemantics (deprecated after v3.40.0-1.0.pre).
    expect(
      tester.getSemantics(finder),
      isSemantics(
        label: tile.label,
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        isHidden: false,
      ),
      reason: 'tile "${tile.label}" has wrong semantics',
    );

    // THE CHECK NO GUIDELINE MAKES: the screen reader must announce
    // "Overwhelmed", never the full vocalization sentence.
    final node = tester.getSemantics(finder);
    expect(
      node.label, isNot(contains(tile.vocalization)),
      reason: 'tile "${tile.label}" leaks its vocalization into the semantic '
              'label; a screen reader user would hear the whole sentence while scanning',
    );
  }
});

// Empty grid_slots (button_id IS NULL) must not masquerade as tappable buttons.
testWidgets('empty slots are not announced as buttons', (tester) async {
  await pumpGridWithEmptySlot(tester, row: 2, col: 1);
  final node = tester.getSemantics(find.byKey(const ValueKey('tile_2_1')));
  expect(node, isSemantics(isButton: false, hasTapAction: false));
});
```

find.bySemanticsLabel('Overwhelmed') also works and reads nicely, but prefer keying off grid position — position IS the primary key in your schema, so ValueKey('tile_r_c') mirrors the data model and a reflow bug would surface as a key/label mismatch.

### TextScaler: parameterized, plus the anti-clamping test

```dart
// test/a11y/scaling_test.dart
for (final scale in <double>[1.0, 1.3, 2.0, 3.0]) {
  testWidgets('grid is accessible at ${scale}x text scale', (tester) async {
    await pumpGrid(tester, textScaler: TextScaler.linear(scale));

    // No overflow / layout exceptions at any scale.
    expect(tester.takeException(), isNull);

    // Tap targets survive scaling.
    for (final tile in kTestTiles) {
      final size = tester.getSize(find.byKey(ValueKey('tile_${tile.row}_${tile.col}')));
      expect(size.height, greaterThanOrEqualTo(76.0), reason: '"${tile.label}" at ${scale}x');
    }

    // Labels still reachable at every scale.
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });
}

// THE ANTI-CLAMP TEST: no guideline catches a clamped TextScaler —
// contrast and tap-size both still pass while text stops growing.
testWidgets('text scale is honored, never clamped', (tester) async {
  await pumpGrid(tester, textScaler: TextScaler.noScaling);
  final baseline = tester.getSize(find.text('Overwhelmed')).height;

  await pumpGrid(tester, textScaler: const TextScaler.linear(2.0));
  final scaled = tester.getSize(find.text('Overwhelmed')).height;

  expect(
    scaled, greaterThan(baseline * 1.8),
    reason: 'Text did not actually grow at 2.0x — someone clamped TextScaler '
            'to keep the fixed grid tidy. 200%+ must be honored.',
  );
});

testWidgets('boldText is honored', (tester) async {
  await pumpGrid(tester, boldText: true);
  final style = tester.widget<Text>(find.text('Overwhelmed')).style!;
  expect(style.fontWeight, isNot(FontWeight.w300));
});
```

The 1.8 factor (not 2.0) tolerates line-height rounding while still failing hard on a clamp. Note textScaleFactor is deprecated framework-wide — always TextScaler.linear, and read via MediaQuery.textScalerOf(context).

### Contrast: a deterministic unit test, because textContrastGuideline false-passes

```dart
// test/a11y/contrast_test.dart
// flutter#103235 (OPEN): meetsGuideline(textContrastGuideline) PASSES with
// white text on #fafafa. It samples screenshot pixels and mis-picks the
// background in low-variance regions. So compute the ratio ourselves.

double _luminance(Color c) => c.computeLuminance();

double contrastRatio(Color fg, Color bg) {
  final l1 = _luminance(fg), l2 = _luminance(bg);
  final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // AAA (7.0 normal / 4.5 large) — defensible for an app used in distress
  // and in low light. Pure Dart: no screenshots, no sampling, cannot false-pass.
  for (final theme in [aacLightTheme, aacDarkTheme, aacHighContrastTheme]) {
    test('${theme.name}: tile label on tile background meets WCAG AAA', () {
      expect(
        contrastRatio(theme.tileLabelColor, theme.tileBackgroundColor),
        greaterThanOrEqualTo(7.0),
        reason: '${theme.name} tile text contrast is too low',
      );
    });

    test('${theme.name}: show-text mode meets WCAG AAA large text', () {
      expect(
        contrastRatio(theme.showTextColor, theme.showTextBackground),
        greaterThanOrEqualTo(4.5), // large text (>=18px, or >=14px bold)
      );
    });
  }
}

// One line of advisory belt-and-braces in the widget suite:
// await expectLater(tester, meetsGuideline(const MinimumTextContrastGuidelineAAA()));
```

Flutter's own constants for reference: kMinimumRatioNormalText = 4.5, kMinimumRatioLargeText = 3.0, kLargeTextMinimumSize = 18, kBoldTextMinimumSize = 14, and AAA: kAAAMinimumRatioNormalText = 7.0, kAAAMinimumRatioLargeText = 4.5.

### docs/a11y-manual-checklist.md — the actual correctness gate

```markdown
# Accessibility release checklist (MANUAL — required before every tag)

Automated tests catch a minority of a11y issues (Deque: 57% even with axe's ~100
web rules; Flutter ships 4 guidelines, one of which is known-broken). Switch
Control / Switch Access have NO automation. There is no telemetry: if this is
wrong in the field, we will never find out. So this pass is the safety net.

Device: __________  OS version: __________  Date: __________  Tester: __________

## TalkBack (Android)
- [ ] Swipe-right through the grid: all 12 tiles reached, row-major, none skipped
- [ ] Each tile announces its DISPLAY label ('Overwhelmed'), NOT the sentence
- [ ] Each tile announces as "button"
- [ ] Double-tap speaks the VOCALIZATION through TTS (audio actually heard)
- [ ] Empty slots are not announced as buttons
- [ ] Type-to-speak field is reachable and exitable
- [ ] Show-text mode: text announced; back-out works
- [ ] Edit mode: reachable, exitable, no focus trap

## VoiceOver (iOS)
- [ ] Same 8 checks as above
- [ ] Personal Voice (if configured) is selectable and speaks

## Switch Access (Android) — NO AUTOMATION EXISTS
- [ ] Every tile reachable by scanning; order matches the traversal test
- [ ] Scan highlight is visible against ALL themes (incl. high contrast)
- [ ] Can exit edit mode using only the switch
- [ ] Can exit the text field using only the switch (no trap)

## Switch Control (iOS) — NO AUTOMATION EXISTS
- [ ] Item scanning reaches all 12 tiles
- [ ] Point scanning can hit every tile
- [ ] Can exit edit mode and text field using only the switch

## Scaling & display
- [ ] System font size at MAX + Display Zoom on: no tile text clipped
- [ ] Bold Text on: layout intact
- [ ] Show-text mode readable at max font size

## Audio (guards the silent-failure class)
- [ ] iOS silent switch ON -> tapping a tile STILL PLAYS AUDIO (.playback, not .ambient)
- [ ] Music playing -> tile speech ducks the music, does not stop it
- [ ] Selected voice uninstalled from system -> app surfaces an error, never silence
- [ ] Airplane mode -> every voice still works (no network_required voice selected)

## Scanners
- [ ] Google Accessibility Scanner run on grid screen (works: reads Flutter's
      AccessibilityBridge virtual nodes) — no new findings
- [ ] Xcode Accessibility Inspector audit on grid screen — no new findings
```

Ship this file in the repo, not in a wiki. It is the single most valuable a11y artifact for the open-source exit plan: it tells a stranger exactly what 'accessible' means for this app and how to verify it without your devices or your knowledge.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
=== THE PROJECT THESE PRACTICES ARE FOR ===

An offline AAC (augmentative & alternative communication) app for autistic adults with situational/part-time speech loss. Flutter, Android-first, iOS later. Solo developer. Today is 2026-07-15; Flutter stable is 3.44.0, Dart 3.x.

The app: ONE screen — a FIXED 3x4 grid of phrase tiles + a type-to-speak field on the same surface + on-device TTS. A "show text" full-screen mode. An explicit edit mode. Settings (voice/pitch/rate/output mode/theme). No accounts, no server, no network.

DECISIONS ALREADY MADE (from a prior deep research pass — do not re-litigate these, design practices AROUND them):
- **drift** (SQLite) for local DB. Schema: boards / buttons / grid_slots / images / sounds / settings. Critically, `grid_slots` has PRIMARY KEY (board_id, row, col) with a NULLABLE button_id — position IS the primary key, so tile reflow is structurally impossible. Data model borrows Open Board Format semantics (label != vocalization: the tile SHOWS "Overwhelmed" but SPEAKS "I need to leave, I'm not able to talk right now").
- **flutter_riverpod** for state — explicitly acknowledged as NOT load-bearing (12 tiles and a text field; ValueNotifier would work). Chosen for a testable seam between repository and UI, and to react to MediaQuery a11y flags + TTS voice-availability changes.
- **flutter_tts** wrapped behind an abstract `SpeechService` (speak/stop/voices), with a `voice_filter` (Android network_required check + setVoice return-value check — flutter_tts returns 0 with only a Log.d on failure, which would silently give a user in crisis NO SPEECH) and an `audio_session` config (iOS .playback + duckOthers; NEVER .ambient).
- Native platform channels needed for: Personal Voice (iOS), an Android Quick Settings TileService (Kotlin, speaks natively from SharedPreferences with NO Flutter engine on that path), an iOS 18 ControlWidget (Swift).
- Images/sounds are FILES ON DISK with paths in the DB, never BLOBs.

=== THE CONSTRAINTS THAT MAKE THIS PROJECT'S ENGINEERING UNUSUAL ===

1. **NO TELEMETRY, EVER.** No Firebase, no Crashlytics, no Sentry, no analytics — the privacy promise forbids it and the audience reads privacy labels adversarially. THE DEVELOPER WILL NEVER LEARN THAT THE APP CRASHED IN THE FIELD. Tests are the ONLY safety net. This should raise the bar on testing dramatically and change what is worth testing. There is a planned on-device-only, user-exportable crash log.
2. **A BOTCHED DB MIGRATION IS THE LOSS OF SOMEONE'S VOICE.** Users hand-curate phrase boards over months; that data is irreplaceable and unmergeable. Migration testing is a safety property, not hygiene.
3. **ACCESSIBILITY IS CORRECTNESS, NOT POLISH.** An inaccessible accessibility app is a total failure. Semantics on every tile; iOS Switch Control / Android Switch Access / VoiceOver / TalkBack must work; TextScaler must be honored at 200%+ and never clamped. This must be enforced by TESTS and lints, not by discipline.
4. **A SILENT FAILURE IS THE WORST BUG CLASS.** An unchecked setVoice return, a voice that vanished, an audio session misconfigured to .ambient so the silent switch mutes the app — each means a user taps a tile mid-shutdown and NOTHING happens. Error handling must make silence impossible.
5. **The developer may abandon this** (it is app #N of a 50-app challenge). The offline architecture means it keeps working unmaintained; open-sourcing is the exit plan. So the code must be READABLE BY A STRANGER and the docs must let someone else pick it up.
6. **Solo dev, ~2-week MVP.** Practices must be proportionate. Ceremony that a team needs and a solo dev doesn't is a real cost. Be honest about what to SKIP.
7. Zero animation is a design rule (distress + latency). Deterministic UI.

Today's date: 2026-07-15. Prefer 2025-2026 sources. Flutter and its ecosystem move fast — a 2022 blog post is probably wrong.


YOUR DIMENSION: Automated accessibility testing in Flutter. THIS IS THE MOST IMPORTANT DIMENSION for this project — a11y is a correctness property here, not polish.

Research with WebSearch/WebFetch: docs.flutter.dev accessibility docs, the flutter_test accessibility API, api.flutter.dev for AccessibilityGuideline, Flutter's own accessibility tests, community articles (check dates).

- **`meetsGuideline()` and the built-in guidelines**: `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `textContrastGuideline`, `labeledTapTargetGuideline`. Get the EXACT API, the exact thresholds each enforces (Android 48x48? iOS 44x44? contrast 4.5:1?), and how to use them: `final handle = tester.ensureSemantics(); await expectLater(tester, meetsGuideline(...)); handle.dispose();` — verify this is current and correct.
- What do these guidelines NOT catch? (Be specific and honest — automated a11y checks famously catch a minority of real issues. What percentage? Any evidence?)
- Can you write a CUSTOM AccessibilityGuideline? This project wants a 76dp minimum target — show how to subclass/implement AccessibilityGuideline to enforce a custom size. Is that API public and stable?
- **Testing semantics**: `find.bySemanticsLabel`, `tester.getSemantics()`, `matchesSemantics()` / `containsSemantics()` matchers — the full current API and how to assert a tile is labeled, is a button, is enabled, has the right action. Show real code.
- `SemanticsController`, semantic traversal order testing — can you assert the ORDER a screen reader visits tiles? (This matters: a 3x4 grid must be traversed in a predictable order.) Show how.
- Testing that the app respects textScaler / boldText / disableAnimations.
- **Switch Control / Switch Access**: can they be tested automatically AT ALL, or is it manual-only? Honest answer. If manual, what is the actual manual checklist? (Flutter publishes no Switch Control support statement — how do you verify it yourself?)
- Screen reader testing: is there any automation? (TalkBack/VoiceOver in CI — possible? Espresso/XCUITest accessibility audits? Android's Accessibility Scanner / Espresso AccessibilityChecks — do those work on a Flutter app given it's a single canvas view? THIS IS A KEY QUESTION.)
- Are there a11y lints? (flutter_lints? any package?)
- What does the Flutter team itself do to test accessibility?

Be rigorous, get exact API signatures, and give a concrete a11y test suite design for a 12-tile grid.
````

</details>
