# E02-T04 — The contrast gate test

| | |
|---|---|
| **Epic** | E02 — Design system in code |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E02-T03 |
| **Blocks** | Nothing |

**Skills:** `reed-golden-testing` · `reed-colour-system` · `reed-testing-strategy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A tile label that dropped below its contrast floor is unreadable to the person who needs it most, and nobody will ever report it — there is no telemetry, and a user in shutdown does not file bugs. A golden file cannot catch this: it asserts "these pixels equal the pixels I blessed", so grey-on-grey passes forever once blessed. This test is the only mechanism that verifies the design system rather than photographing it, and it is the reason this project ships zero golden files.

## Scope

Create `test/ui/contrast_test.dart`. Pure Dart — `package:test`-style, no `WidgetTester`, no golden files, no platform variance. Target ~85 tests in about a second, inside the ~135-test / under-30-second suite budget.

Four channels, each catching a class the others miss. The rejections that prove it: a ghost line passed WCAG AA at **5.34:1** and was unreadable at **APCA Lc −39.0**; a press flood was **1.02:1** in colour and **1.015:1** in grayscale; isoluminant tiles collapsed to deutan **ΔE 1.06**. Drop a channel, that class returns.

### The four helpers

Copy these exactly from `reed-golden-testing`. The APCA function is 0.98G-4g and is validated against published reference pairs — **do not edit it**.

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
```

### The self-test, first

Before any floor is trusted, the implementation must prove itself:

```dart
test('APCA implementation matches published reference pairs', () {
  expect(_apca(const Color(0xFF888888), const Color(0xFFFFFFFF)), closeTo(63.1, 0.1));
  expect(_apca(const Color(0xFFFFFFFF), const Color(0xFF888888)), closeTo(-68.5, 0.1));
  expect(_apca(const Color(0xFF000000), const Color(0xFFAAAAAA)), closeTo(58.1, 0.1));
  expect(_wcag(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21.00, 0.01));
});
```

### The pairings

```dart
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
```

### The four channels, per palette

Loop `for (final AacTheme t in kAllThemes)` — `paper`, `ink`, `hcInk`, `hcPaper` — with a `group(t.name, ...)`.

**1. Contrast.** Per `Pair`: assert `p.fg.a == 1.0` (reason: `'contrast is undefined for a translucent fg'`) and `p.bg.a == 1.0`, then `_wcag >= p.wcagMin` **and** `_apca().abs() >= p.lcMin`. WCAG is the compliance floor, APCA the instrument. Both, always.

**2. Grayscale.** One test, `'lit state and focus ring survive grayscale'`. For every `Stock`: `_wcag(_gray(t.stockLit(s)), _gray(t.stock(s))) >= 1.30`, reason `'${s.name}: lit is chroma-only and vanishes in grayscale'`. Then `_wcag(_gray(t.focus), _gray(t.ground)) >= 3.0`. This channel is independent — it is what catches the whole class of feedback that encodes state in chroma alone, invisible to a colourblind user and to anyone with Android's Grayscale colour correction on. Reed's luminance step measures 1.34–1.48:1 and survives; the rejected chroma flood measured 1.015:1.

**3. Edge findability.** `final double floor = t.usesStocks ? 1.5 : 3.0;` then per `Stock`: `math.max(_wcag(t.stock(s), t.ground), _wcag(t.keyline, t.stock(s))) >= floor`. Carry the comment explaining why: SC 1.4.11 exempts a control identified by its own text label, and a tile carries a 7:1 label. `max()` lets the design choose whether fill or keyline carries the edge.

**4. The palette contract.** Three tests:
- `'stocks are staggered in lightness, never isoluminant'` — early-return if `!t.usesStocks`; sort `t.stocks.map((Color c) => c.computeLuminance())`, assert `ls.last - ls.first > 0.02`, reason `'stagger collapsed'`.
- `'lerp is a hard cut, never a mix'` — pick `kAllThemes.firstWhere((AacTheme x) => x != t)`, and for `x` in `[0, 0.25, 0.49, 0.5, 0.75, 1.0]` assert `identical(t.lerp(o, x), t) || identical(t.lerp(o, x), o)`.
- `'geometry floors hold'` — `Geom.gapColumn >= 12.0`; `Geom.gapRow > Geom.gapColumn` with reason `'equal gutters read as a table, not a page'`; `Geom.innerRadius(Geom.tileRadius, 12) == 8.0`; `Geom.hairline(3.0)` `closeTo(0.333, 0.001)`.

### The greppable companion

Add the token-literal guard so a hex typed at 11pm outside the gate fails CI:

```bash
! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'
```

A colour outside `tokens.dart` is a colour outside the gate.

### Explicitly out of scope

- **Any golden.** No `matchesGoldenFile`, no `--update-goldens` CI step, no `golden_toolkit` (discontinued at v0.15.0, ~3 years stale), no `alchemist` (alive at v0.14.0 but buys CI stability with `obscureText: true` — it replaces text with coloured rectangles), no `flutter_test_goldens` (v0.0.12, ~11 likes).
- **`meetsGuideline(textContrastGuideline)` / `MinimumTextContrastGuidelineAAA` as the gate.** They may exist as one-line advisory tripwires elsewhere; they are never this gate.
- The overflow matrix and the `getRect` grid invariants — separate tasks, same replacement plan.

## Acceptance criteria

- [ ] `flutter test test/ui/contrast_test.dart` passes and reports roughly 85 tests, completing in about a second.
- [ ] The reference-pair test is present and green: `_apca(#888888, #FFFFFF)` ≈ 63.1, `_apca(#FFFFFF, #888888)` ≈ −68.5, `_apca(#000000, #AAAAAA)` ≈ 58.1, `_wcag(#000000, #FFFFFF)` ≈ 21.00.
- [ ] Every one of the four palettes in `kAllThemes` produces its own `group` — `paper`, `ink`, `hcInk`, `hcPaper` all appear in the test output.
- [ ] Every `Pair` asserts **both** `_wcag >= wcagMin` and `_apca().abs() >= lcMin`. Verify by deleting the APCA line locally and confirming the reduced test is weaker — then restore it.
- [ ] The grayscale test exists as a **separate** test from the contrast tests, and fails if any `stockLit`/`stock` pair drops below 1.30 in grayscale. Verify: temporarily set one `stockLit` equal to its `stock` and watch it go red with the stock's name in the message.
- [ ] `grep -rn 'matchesGoldenFile\|golden_toolkit\|alchemist\|update-goldens' . --include='*.dart' --include='*.yaml' --include='*.yml'` returns nothing.
- [ ] `! grep -rn 'Color(0x' lib/ --include='*.dart' | grep -v 'lib/ui/core/tokens.dart'` exits 0.
- [ ] `dart analyze` is clean.
- [ ] The test file contains no `Color(0x` literal other than the four reference pairs in the self-test.

## Traps

- **Lowering a floor to make a test pass.** Change the **colour**, never the floor. A floor lowered to go green is the test deleting itself. If a pairing fails, compute a replacement with `python3 .claude/skills/reed-colour-system/scripts/contrast.py '#RRGGBB' '#RRGGBB'` — never hand-math a ratio, never recall one.
- **"Fixing" `ink/${s.name}-lit` up to 7.0.** The lit label is a 1–3s transient on text the user just read. AA / Lc 45 is deliberate. Raising it erases the lit state, which is the only confirmation a user with motor imprecision gets that their tap landed.
- **"Fixing" edge findability to 3.0.** It is not a WCAG rule and is deliberately not named like one. Forcing 3:1 around all 12 tiles produces a hard rule on every tile — the 2014 enterprise grid the design exists to avoid.
- **Editing `_apca` because a number "looks off".** It is 0.98G-4g, validated against published references. If the self-test is green and a pairing fails, the pairing is wrong, not the algorithm.
- **Folding grayscale into the contrast loop.** It must stay independent. A chroma-only signal can pass every WCAG/APCA pairing in the list and be identically zero in Android's Grayscale mode. That is the exact class it exists to catch, and merging it hides which channel failed.
- **Adding a colour to `AacTheme` without adding a `Pair`.** An unpaired colour is an untested colour. Add both in the same commit. Adding a `Stock` value needs nothing — the `Stock.values` loop picks it up; that is why it loops.
- **A translucent colour.** `expect(p.fg.a, 1.0)` rejects it on purpose: contrast against a background you do not control is non-certifiable by construction. Same reason `BackdropFilter`, blur and gradients are banned — translucency deletes the gate.
- **Reaching for `dynamic_color` or `ColorScheme.fromSeed` later.** A palette computed on-device from an image nobody has seen is unverifiable at build time; every guarantee this gate provides evaporates.
- **Writing `lerp` as `return this`.** The step function is `t < 0.5 ? this : (other ?? this)`. `return this` never arrives at the new palette, and the `identical(...) == o` half of the lerp test is what catches it.
- **Letting `meetsGuideline` creep in as the real check.** It screenshots the rendered layer and picks fg/bg from a colour histogram: white text on `#FAFAFA` **passes** (open, unfixed Flutter defect), and it only sees text findable via `find.text`. It produces a strong feeling that accessibility is tested while skipping most of the board.

## Files

- Creates: `test/ui/contrast_test.dart`
- Changes: the CI workflow — add the `Color(0x` grep guard alongside `flutter test`.
- Reads only (must not modify): `lib/ui/core/tokens.dart`, the `AacTheme` / `Stock` / `Geom` / `kAllThemes` definitions from E02-T03.

## Done when

`flutter test test/ui/contrast_test.dart` verifies every semantic pairing against its WCAG and APCA floor plus the independent grayscale channel across all four palettes, in about a second, with no golden file anywhere in the repo.
