---
name: reed-golden-testing
description: Refuses goldens and ships the contrast gate instead — matchesGoldenFile, --update-goldens, golden_toolkit, alchemist, and every screenshot or pixel-diff suite are rejected; WCAG + APCA + grayscale floors cover each colour pairing across paper, ink, hcInk, hcPaper. Use when reaching for a golden or screenshot test, adding a colour to tokens.dart or AacTheme, adding a palette, Stock, lit state, or focus ring, or asking whether the palette is readable or colourblind-safe.
---

# Visual testing: no goldens, one contrast gate

## The decision

**Ship zero golden files. Not four, not one per palette. Zero.** Do not add
`matchesGoldenFile`, do not add a `--update-goldens` CI step, do not add a
golden package to `pubspec.yaml`.

The temptation is real and must be answered rather than waved off. A rigidly
fixed 3×4 grid with zero animation, four palettes, and a handful of text scales
looks like the ideal golden subject: nothing moves, so any pixel diff is a real
diff. That reasoning is correct about *stability* and wrong about *value*.

**A golden cannot assert anything.** It asserts "these pixels equal the pixels I
blessed." Bless a screen of grey-on-grey unreadable text once and it passes
forever, green, silently, in the exact app where an unreadable label means a
person cannot speak. The failure the golden guards against — a padding tweak —
is the cheapest failure this codebase has. The failure it cannot see — a colour
pairing that dropped below its floor — is the expensive one.

**The combinatorics are a maintenance trap for one developer.** 4 palettes × 5
text scales × 2 modes = 40 PNGs, every one invalidated by any padding change,
reviewed by a human eyeballing 40 diffs at 11pm in week 2. That review does not
happen. What happens is `--update-goldens` and a commit titled "update goldens",
which converts the suite into a ratchet that blesses whatever shipped.

**Goldens sabotage the exit plan.** Someone clones this repo on Linux, runs
`flutter test` against PNGs generated on macOS, and sees a wall of red. They
conclude the repo is broken and leave. Font rasterization, subpixel positioning,
and antialiasing differ across host platforms and across Flutter's own engine
revisions; the `flutter/flutter` repo maintains a whole comparator infrastructure
to survive this and still has skew. A solo dev inherits the problem and none of
the infrastructure.

**The font problem makes the 40 PNGs worthless even where they are stable.**
`flutter test` runs in a plain Dart VM with a test font whose every glyph is an
identical box — bundled assets are not loaded unless the test explicitly loads
them. So a golden either renders boxes (blessing nothing about type) or loads the
real variable font (`wght` axis 200–800, one axis, no `opsz`), whose variable-axis
rasterization is exactly the thing that differs between host platforms. Type is
the entire visual argument of this app. A golden suite that either hides the type
or renders it non-reproducibly is not testing the design.

## Tooling: check liveness before naming a package

Only two facts matter here, and both cut against goldens:

| package | state | verdict |
|---|---|---|
| `golden_toolkit` | **discontinued** at v0.15.0, ~3 years stale, no suggested replacement | Never recommend. Tutorials still do; they are stale. |
| `alchemist` (Betterment/VGV) | v0.14.0, maintained | Achieves CI stability by setting `obscureText: true` — it **replaces text with coloured rectangles**. |
| `flutter_test_goldens` | v0.0.12, ~11 likes | Not a foundation for a tool people depend on to speak. |

Read that middle row twice. The one maintained option buys platform stability by
deleting the type — the exact signal this app needs. Even a minimal "did I
catastrophically break layout" tripwire, rendered through it, blesses coloured
rectangles. There is no good option, so take none.

**Before naming any package in any recommendation, check that it is not
discontinued.** Recommending an archived package from memory is the failure mode
this table exists to prevent.

## What replaces goldens

Three things, none of which needs a PNG:

1. **The contrast gate** below — the design system, verified in CI.
2. **An overflow matrix** — pump the board across devices × `TextScaler` ×
   `boldText`, assert `tester.takeException()` is null. Catches every "text does
   not fit" bug a golden would, with a readable failure message. `boldText` is a
   first-class axis: it widens glyphs and overflows tiles that pass unbolded.
3. **`getRect` grid invariants** — assert tiles in a row share a top edge and
   tiles in a column share a left edge at 2.0× scale. Catches every reflow a
   golden would, and names which cell moved.

Each produces a sentence a human can act on. A golden produces a diff image.

## The contrast gate — `test/ui/contrast_test.dart`

Pure Dart. No widget tree, no golden files, no platform variance, ~85 tests in
about a second. This is the move the constraints reward: it is the only mechanism
that verifies the design system rather than photographing it.

**Do not use `meetsGuideline(textContrastGuideline)` or
`MinimumTextContrastGuidelineAAA` as the gate.** They screenshot the rendered
layer and pick foreground/background from a colour histogram, which
mis-attributes the background in low-variance regions — white text on `#FAFAFA`
**passes** (an open, unfixed Flutter defect). They also only see text findable via
`find.text`, so a `CustomPainter` label is invisible to them. Keep them as
one-line advisory tripwires if you like; never let them be the gate. The test
below cannot false-pass: no screenshots, no histogram.

**Four channels, because a ratio test alone is not enough.** A rejected ghost
line passed WCAG AA at 5.34:1 and was unreadable at APCA Lc −39.0. A rejected
press flood was 1.02:1 in colour and 1.015:1 in grayscale. Rejected isoluminant
tiles collapsed to deutan ΔE 1.06. Each is caught by a different channel; drop a
channel and that class of bug returns.

```dart
double _wcag(Color fg, Color bg) {
  final double a = fg.computeLuminance(), b = bg.computeLuminance();
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

double _y(Color c) => 0.2126729 * math.pow(c.r, 2.4) +
    0.7151522 * math.pow(c.g, 2.4) + 0.0721750 * math.pow(c.b, 2.4);

/// APCA 0.98G-4g. Validated against published reference pairs below; do not edit.
double _apca(Color txt, Color bg) {
  double ty = _y(txt), by = _y(bg);
  const double blkThrs = 0.022, blkClmp = 1.414;
  if (ty <= blkThrs) ty += math.pow(blkThrs - ty, blkClmp);
  if (by <= blkThrs) by += math.pow(blkThrs - by, blkClmp);
  if ((by - ty).abs() < 0.0005) return 0;
  final double s = by > ty ? (math.pow(by, 0.56) - math.pow(ty, 0.57)) * 1.14
                           : (math.pow(by, 0.65) - math.pow(ty, 0.62)) * 1.14;
  if (by > ty) return s < 0.1 ? 0 : (s - 0.027) * 100;
  return s > -0.1 ? 0 : (s + 0.027) * 100;
}

/// Android ships Settings > Accessibility > Color correction > Grayscale. Every
/// chroma-only signal is IDENTICALLY ZERO in that mode.
Color _gray(Color c) {
  final double y = c.computeLuminance();
  final double v = y <= 0.0031308 ? 12.92 * y : 1.055 * math.pow(y, 1 / 2.4) - 0.055;
  return Color.from(alpha: 1, red: v, green: v, blue: v);
}

typedef Pair = ({String what, Color fg, Color bg, double wcagMin, double lcMin});

List<Pair> _pairs(AacTheme t) {
  final List<Pair> p = <Pair>[
    (what: 'ink/ground',     fg: t.ink,     bg: t.ground,    wcagMin: 7.0, lcMin: 75),
    (what: 'inkDim/ground',  fg: t.inkDim,  bg: t.ground,    wcagMin: 4.5, lcMin: 55),
    (what: 'ink/container',  fg: t.ink,     bg: t.container, wcagMin: 7.0, lcMin: 75),
    (what: 'keyline/ground', fg: t.keyline, bg: t.ground,    wcagMin: 3.0, lcMin: 30),
    // Ring lives in the GUTTER, so changed pixels are ground -> ring (SC 2.4.13).
    (what: 'focus/ground',   fg: t.focus,   bg: t.ground,    wcagMin: 3.0, lcMin: 45),
    (what: 'show',           fg: t.showInk, bg: t.showGround, wcagMin: 7.0, lcMin: 90),
    (what: 'standing', fg: t.showStandingLine, bg: t.showGround, wcagMin: 4.5, lcMin: 60),
  ];
  for (final Stock s in Stock.values) {
    // Resting label AAA (read during a shutdown). Lit label AA / Lc 45: a 1-3s
    // transient on a label just read — identifiable, not readable. Stated here so
    // nobody "fixes" it to 7.0 and flattens the lit state.
    p.add((what: 'ink/${s.name}', fg: t.inkOn(s), bg: t.stock(s), wcagMin: 7.0, lcMin: 60));
    p.add((what: 'ink/${s.name}-lit', fg: t.inkOn(s, lit: true),
           bg: t.stockLit(s), wcagMin: 4.5, lcMin: 45));
  }
  return p;
}

void main() {
  test('APCA implementation matches published reference pairs', () {
    expect(_apca(const Color(0xFF888888), const Color(0xFFFFFFFF)), closeTo(63.1, 0.1));
    expect(_apca(const Color(0xFFFFFFFF), const Color(0xFF888888)), closeTo(-68.5, 0.1));
    expect(_apca(const Color(0xFF000000), const Color(0xFFAAAAAA)), closeTo(58.1, 0.1));
    expect(_wcag(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21.00, 0.01));
  });

  for (final AacTheme t in kAllThemes) {
    group(t.name, () {
      // 1. CONTRAST. WCAG is the compliance floor, APCA the instrument. BOTH.
      for (final Pair p in _pairs(t)) {
        test('contrast ${p.what}', () {
          expect(p.fg.a, 1.0, reason: 'contrast is undefined for a translucent fg');
          expect(p.bg.a, 1.0);
          expect(_wcag(p.fg, p.bg), greaterThanOrEqualTo(p.wcagMin));
          expect(_apca(p.fg, p.bg).abs(), greaterThanOrEqualTo(p.lcMin));
        });
      }

      // 2. GRAYSCALE. Independently catches the isoluminant collapse, the chroma
      // press flood, and any future chroma-only signal: the entire class of bug
      // this system keeps being offered.
      test('lit state and focus ring survive grayscale', () {
        for (final Stock s in Stock.values) {
          expect(_wcag(_gray(t.stockLit(s)), _gray(t.stock(s))), greaterThanOrEqualTo(1.30),
              reason: '${s.name}: lit is chroma-only and vanishes in grayscale');
        }
        expect(_wcag(_gray(t.focus), _gray(t.ground)), greaterThanOrEqualTo(3.0));
      });

      // 3. EDGE FINDABILITY. NOT a WCAG rule, deliberately not named like one.
      // SC 1.4.11 exempts a control identified by its own text label — a phrase
      // tile carries a 7:1 label, so it is self-identifying and the edge is not
      // compelled. Asserting 3:1 would force a hard rule around all 12 tiles,
      // which IS the 2014 enterprise grid. max() lets the design choose which of
      // fill or keyline carries the edge, requiring only that one does. DO NOT
      // "fix" this to 3.0.
      test('edge findability', () {
        final double floor = t.usesStocks ? 1.5 : 3.0;
        for (final Stock s in Stock.values) {
          expect(math.max(_wcag(t.stock(s), t.ground), _wcag(t.keyline, t.stock(s))),
              greaterThanOrEqualTo(floor));
        }
      });

      // 4. THE PALETTE CONTRACT.
      test('stocks are staggered in lightness, never isoluminant', () {
        if (!t.usesStocks) return;
        final List<double> ls =
            t.stocks.map((Color c) => c.computeLuminance()).toList()..sort();
        expect(ls.last - ls.first, greaterThan(0.02), reason: 'stagger collapsed');
      });
      test('lerp is a hard cut, never a mix', () {
        final AacTheme o = kAllThemes.firstWhere((AacTheme x) => x != t);
        for (final double x in <double>[0, 0.25, 0.49, 0.5, 0.75, 1.0]) {
          expect(identical(t.lerp(o, x), t) || identical(t.lerp(o, x), o), isTrue);
        }
      });
      test('geometry floors hold', () {
        expect(Geom.gapColumn, greaterThanOrEqualTo(12.0));
        expect(Geom.gapRow, greaterThan(Geom.gapColumn),
            reason: 'equal gutters read as a table, not a page');
        expect(Geom.innerRadius(Geom.tileRadius, 12), 8.0);
        expect(Geom.hairline(3.0), closeTo(0.333, 0.001));
      });
    });
  }
}
```

## Rules for extending the gate

| Situation | Do this |
|---|---|
| Adding a colour to `AacTheme` | Add a `Pair` for it in `_pairs` in the same commit, with a stated `wcagMin` and `lcMin`. An unpaired colour is an untested colour. |
| Adding a `Stock` value | Nothing — the `Stock.values` loop and the stagger test pick it up. That is why they loop. |
| Adding a palette | Add it to `kAllThemes`. The whole group runs against it. |
| A floor fails | Change the **colour**, never the floor. A floor lowered to make a test pass is the test deleting itself. |
| Tempted to relax `ink/${s.name}-lit` to 7.0 | Don't. The lit label is a 1–3s transient on text just read; AA/Lc 45 is deliberate and flattening it kills the lit state. |
| Tempted to raise `edge findability` to 3.0 | Don't. It is not a WCAG rule; forcing 3:1 around all 12 tiles produces the enterprise grid the design exists to avoid. |
| A translucent colour | Rejected by `expect(p.fg.a, 1.0)` on purpose — contrast against a background you do not control is non-certifiable by construction. This is also why `BackdropFilter`, blur, and gradients are banned: translucency deletes the gate. |
| Adding `dynamic_color` / `ColorScheme.fromSeed` / wallpaper theming | Rejected. A palette computed on-device from an image nobody has seen is unverifiable at build time — every guarantee this gate provides evaporates. |

## The greppable companion

`lib/ui/core/tokens.dart` is the only file permitted a colour literal. Enforce
it in CI rather than promising it; every design system that rotted, rotted by
someone typing a hex at 11pm:

```bash
! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'
```

A colour outside `tokens.dart` is a colour outside the gate.

## The question that gates every visual decision

> **Does this still work for someone who cannot see colour, is at 200% text, and
> is driving the app with one switch at one second per step?**

The grayscale channel answers the first third mechanically. A golden never
answers any of it.
