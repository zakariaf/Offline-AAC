---
name: reed-text-scale-testing
description: TextScaler, boldText, and RenderFlex overflow in widget tests — the device x scale x bold matrix, one testWidgets per tuple, and asserting a label fits its computed tile. Use when pumping TextScaler.linear or boldText, chasing an "overflowed by N pixels" failure, reaching for takeException, ignoreOverflowErrors, FittedBox, ellipsis, or withClampedTextScaling, or checking whether the tile grid, show-text mode, or type-to-speak field survive 200%+ and Larger Accessibility Sizes.
---

# Testing at text scale

Users at 200%+ are the target audience, not an edge case. A tile whose label is
clipped mid-shutdown is this product failing the exact person it exists for, and
nobody will report it: there is no telemetry, and a user who cannot speak does
not file bugs. The scale matrix is the only thing standing between that user and
a broken board.

## The two overflow classes — one is loud, one is silent

**Loud: `RenderFlex` overflow already FAILS a widget test.** It is not merely a
yellow-black banner and a log line. `DebugOverflowIndicatorMixin._reportOverflow`
calls `FlutterError.reportError`; `TestWidgetsFlutterBinding` captures it into
`_pendingExceptionDetails`; `testWidgets` rethrows at test end unless something
clears it. The entire blog genre on this topic is about how to **suppress** it.

So the rule inverts from the intuition: the job is not to *make* overflow fail,
it is to **never lose the net that already exists**.

> Never call `takeException()` to swallow. Never assign `FlutterError.onError` in
> a layout test. Never copy the popular `ignoreOverflowErrors` helper.
> Never `takeException()` in a global `tearDown` — it clears
> `_pendingExceptionDetails` before `testWidgets` rethrows, silently converting
> the whole suite's overflow net into a no-op.

**Silent: a clipped `Text` reports nothing, ever.** `RenderParagraph` has no
overflow indicator. A label that runs past a tile's fixed height inside a
`SizedBox` + clip produces zero errors, a green test, and unreadable words on a
real phone. Only a `Flex` child reports. This is why `takeException(), isNull` is
necessary and **not sufficient**, and why the fit assertion below is the real
gate.

## Three traps that make an overflow suite pass while checking nothing

1. **The 800x600 default surface.** Wider than any phone. Unpinned, tiles come
   out ~2x too wide, the text fits, the suite is green, and the shipped 360dp
   phone is broken. Pin a device in every layout test.
2. **Overflow is reported ONCE per `RenderObject`.** `_overflowReportNeeded` goes
   false after the first report and resets only on `reassemble()`. Looping scales
   inside one `testWidgets` silently under-reports scales 2..n.
   → **Generate one `testWidgets` per tuple.** Never a `for` loop inside a test.
3. **It only reports if the widget PAINTS.** `Offstage` subtrees and content
   scrolled outside a viewport never report. (Clipped content *does* still
   report — `RenderFlex` calls `paintOverflowIndicator` after pushing its own
   clip.) The fixed grid is fine, but **show-text mode and edit mode need their
   own pumped tests** — a board test will never reach them.

## The matrix

```dart
// test/ui/overflow_matrix_test.dart
void main() {
  // TextScaler.linear is a deliberate OVER-approximation: Android 14+ scales
  // large text LESS than small text, so linear stresses 20pt tile labels harder
  // than a real device would. That conservatism is wanted — but do not claim
  // these tests are device-faithful. 1.3 and 1.5 are here precisely because
  // nonlinear scaling makes the mid-range non-obvious. 3.0 is Larger
  // Accessibility Sizes territory, where iOS AX5 lives.
  const List<double> scales = <double>[1.0, 1.3, 1.5, 2.0, 3.0];

  for (final Device device in Device.all) {
    for (final double scale in scales) {
      for (final bool bold in <bool>[false, true]) {
        testWidgets('board: no overflow @ $device x$scale${bold ? ' bold' : ''}',
            (WidgetTester tester) async {
          tester.useDevice(device);
          await tester.pumpApp(
            textScaler: TextScaler.linear(scale),
            boldText: bold,
          );

          // Not strictly required — the binding rethrows at test end. Explicit
          // for a better message, and to document that suppression is banned.
          expect(tester.takeException(), isNull,
              reason: 'tile text overflowed at $device x$scale');
        });
      }
    }
  }
}
```

3 devices x 5 scales x 2 bold = 30 tests. Pumping is one frame each; the cost is
nothing and the coverage is the product.

Devices are pinned in **logical** size and multiplied by DPR, because
`view.physicalSize` is in physical pixels — `Size(320, 568)` at the default DPR
of 3.0 gives a 107x189 surface, not a small phone:

| device | logical | dpr |
|---|---|---|
| `Device.seLike` | 320 x 568 | 2.0 |
| `Device.small` | 360 x 800 | 3.0 |
| `Device.pixel7` | 412 x 915 | 2.625 |

`addTearDown(view.reset)` after pinning. Prefer `TestFlutterView.reset()` over
the `resetPhysicalSize` / `resetDevicePixelRatio` pair — a leaked view size
poisons the next test, and that failure lands in a file nobody edited.

## boldText is a first-class axis, not an afterthought

`boldText` widens advance widths. A tile that fits at 2.0x unbolded can overflow
at 2.0x bold. It is a system accessibility setting the target audience turns on,
it costs one bool in the tuple, and dropping it halves the matrix while removing
the half most likely to be red. Always pair it with scale; never test it alone.

## The fit assertion — the real constraint

There is no minimum tap-target dp floor in this app, and reintroducing one is a
regression. WCAG 2.5.8 (AA) is 24x24 CSS px; 2.5.5 Enhanced (AAA) is 44x44. Any
larger invented number (76dp is the usual one) appears in no standard, is
non-binding on real phones — tiles compute to ~89–106 x 125–146dp — and at 200%
text scale it is measuring the **wrong thing**, because the label block needs
~124dp against ~125dp of tile. The tile is not too small. The tile is exactly
`(viewport − chrome) / rows`, and the only question is whether the label fits
inside it.

So assert that, at every scale:

```dart
// test/ui/label_fit_test.dart
int linesOf(WidgetTester tester, String label) => tester
    .renderObject<RenderParagraph>(find.text(label))
    .computeLineMetrics()
    .length;

for (final double scale in <double>[1.0, 1.3, 1.5, 2.0, 3.0]) {
  testWidgets('every starter label fits its tile @ x$scale',
      (WidgetTester tester) async {
    tester.useDevice(Device.small); // 360x800: the tightest shipped 3x4
    await tester.pumpApp(textScaler: TextScaler.linear(scale));

    expect(tester.takeException(), isNull); // the loud class

    for (final TestTile t in kTestTiles) {
      final Rect slot =
          tester.getRect(find.byKey(ValueKey<String>('slot_${t.row}_${t.col}')));
      final Size text = tester.getSize(find.text(t.label));

      // Tile inset is 16dp on every side. The label is bottom-anchored and
      // start-aligned; overrun leaves NO exception, only clipped words.
      expect(text.height, lessThanOrEqualTo(slot.height - 32.0),
          reason: '"${t.label}" needs ${text.height}dp inside a '
              '${slot.height}dp tile at x$scale — it is being clipped silently');
      expect(text.width, lessThanOrEqualTo(slot.width - 32.0),
          reason: '"${t.label}" is ${text.width}dp wide at x$scale');

      // A literal \n in a shipped label is a HINT, not a guarantee: past 3 lines
      // the layout falls back to natural wrap. Assert the ceiling holds.
      expect(linesOf(tester, t.label), lessThanOrEqualTo(3),
          reason: '"${t.label}" wrapped to >3 lines at x$scale');
    }
  });
}
```

`find.byKey(ValueKey('slot_r_c'))` for geometry — position IS the primary key,
and `find.bySemanticsLabel` names behaviour, not position. Never `find.byType`
for a tile.

## Fixing a red matrix — the four wrong fixes

Every one of these turns the test green and the product worse. The correct fix is
always the layout, the label text, or the layout *setting*.

| Reach for | Why it is banned |
|---|---|
| `MediaQuery.withClampedTextScaling`, `textScaleFactor` | The one-line "fix" a tired contributor applies at 2am. It defeats the entire matrix while contrast and tap-target still pass green. It also overrides the user's own OS setting — the setting they need. |
| `FittedBox`, any auto-shrink | Backwards: it makes the **longest** (most complex) phrase the **smallest**, destroys the grid's uniform rhythm, and silently cancels the user's TextScaler. |
| `TextOverflow.ellipsis`, `maxLines` truncation | An ellipsis on an AAC utterance is a **different utterance**. The editor refuses at 16 characters instead; nothing truncates at render time. |
| A smaller font on the offending tile | One uniform size for all 12 is load-bearing. Variable line count reads fine; variable size reads as broken. |

The legitimate resolutions: shorten the `label` (the tile is a *handle* for the
utterance — the sentence lives in `says`), add a hand-set `\n`, adjust the shared
tile type role, or accept the **6-tile layout**. At 200% a 20pt label becomes
40pt and 12 tiles arithmetically cannot render on a phone. "Never reflow"
absolutism resolves to "never work at 200%", which is worse. Layout is a user
setting chosen once; the matrix must be run against **both** layouts, never
against 3x4 alone with 6-tile treated as the escape hatch nobody tests.

## Make the ban structural, not per-test discipline

Discipline is exactly what the no-telemetry constraint says cannot be relied on.
Pin it with a ten-line policy test that greps the source — no lint covers any of
this:

```dart
// test/policy/no_text_clamping_test.dart
void main() {
  test('lib/ never clamps or overrides text scaling', () {
    const List<String> forbidden = <String>[
      'withClampedTextScaling', // clamps TextScaler — violates the a11y contract
      'textScaleFactor',        // deprecated, and almost always a clamping hack
      'FittedBox',              // auto-shrink; see above
    ];
    final List<String> offenders = <String>[];
    for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final String src = f.readAsStringSync();
      for (final String bad in forbidden) {
        if (src.contains(bad)) offenders.add('${f.path}: $bad');
      }
    }
    expect(offenders, isEmpty,
        reason: 'TextScaler must be honored at 200%+ and never clamped.\n'
            'Fix the layout; do not clamp the text.\n${offenders.join('\n')}');
  });

  test('test/ never suppresses overflow', () {
    const List<String> forbidden = <String>[
      'ignoreOverflowErrors',
      'FlutterError.onError =',
    ];
    // Same walk over Directory('test'). A single hit disarms the whole matrix.
  });
}
```

## The anti-clamp behavioural check

The grep catches the named API. This catches a clamp built by hand:

```dart
testWidgets('text scale is honored, never clamped', (WidgetTester tester) async {
  tester.useDevice(Device.small);

  await tester.pumpApp();
  final double base = tester.getSize(find.text('Overwhelmed')).height;

  await tester.pumpApp(textScaler: const TextScaler.linear(2.0));
  final double scaled = tester.getSize(find.text('Overwhelmed')).height;

  // 1.8, not 2.0: tolerate line-height rounding, still fail hard on a clamp.
  expect(scaled, greaterThan(base * 1.8),
      reason: 'Text did not grow at 2.0x. Someone clamped TextScaler to keep the '
          'fixed grid tidy. 200%+ must be honored.');
});
```

No guideline catches this. Contrast and tap-target both stay green while the text
stops growing.

## What else to pump at scale, and what not to bother with

- **Run the matrix over show-text mode and edit mode separately.** They do not
  paint during a board test, and unpainted means unreported. Show mode fits its
  text by construction; the honest degradation past six lines at the 32pt floor
  is a scrollable block, so assert *that*, not absence of scroll.
- **The type-to-speak field is the 13th cell** and grows with the same scaler.
  Give it its own tuple loop.
- **Pin the grid invariant at 2.0x**, not just absence of overflow: tiles in a
  row share a top edge, tiles in a column share a left edge, within 0.5dp. That
  assertion replaces goldens, and it fails with a sentence a human can read.
- **No goldens for the scale matrix.** 4 palettes x 5 scales x 2 modes = 40 PNGs,
  each invalidated by any padding tweak, and a golden **cannot assert anything** —
  one rendering clipped text passes forever once blessed. Everything a golden
  would catch here is caught more cheaply, with a readable message, by the matrix
  and the fit assertion.
- **Never `pumpAndSettle`.** Zero animation is a design rule, so it is only
  waiting out animations that do not exist, carries a 10-minute default timeout,
  and truncates its stack trace on timeout. `pump()` for state changes,
  `pump(duration)` for anything timer-driven.

## The one question every scale decision answers

> Does this still work for someone who cannot see colour, is at 200% text, and is
> driving the app with one switch at one second per step?

If the answer needs a clamp, a shrink, or an ellipsis to be yes, the answer is no.
