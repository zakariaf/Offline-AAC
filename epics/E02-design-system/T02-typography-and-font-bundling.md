# E02-T02 — Typography and font bundling

| | |
|---|---|
| **Epic** | E02 — Design system in code |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E01-T01 |
| **Blocks** | E02-T03, E06-T01 |

**Skills:** `reed-typography` · `reed-code-bans` · `reed-dependency-hygiene`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Every string in Reed — the tile label, the poster, the field the user types into — is one typeface doing all the work. Tap "Can’t talk" and the tile label *becomes* the poster: same string, same face, just louder. If the font is not bundled correctly the app falls back to Roboto and the whole visual argument evaporates; if it is bundled but silently instanced by the subsetter, the app looks perfect at w400 and fails only for the accessibility user who turns platform bold text on — the exact user this app exists for, and the one who will never file a bug report about it.

## Scope

### 1. Get the font

Download **Atkinson Hyperlegible Next** (variable, upright, SIL OFL 1.1) from `github.com/googlefonts/atkinson-hyperlegible-next`.

**Never `brailleinstitute.org`** — it gates an open-source font behind email registration and a EULA.

Verified facts about the shipped TTF; trust these over any blog:

```
upem 1000 | glyphs 392
axis wght  min 200  default 400  max 800    <- ONE axis. No opsz. No GRAD. No ital.
instances  200 300 400 500 600 700 800
capHeight 668 | ascent 984 | descent -316
```

### 2. Subset it — preserving the wght axis

Flutter tree-shakes *icon* fonts only, **never text fonts**. Subsetting is manual and mandatory. Latin + punctuation, with `--layout-features='*'`, and **do not let the subsetter instance the font**. An instanced font is a static weight and `boldText` stops working.

Expect roughly **80–120KB**, down from ~200–400KB.

Verify the axis survived before committing. The tooling must still report:

```
wght min 200 default 400 max 800
```

If it reports a single static weight, the subset is wrong — throw it away and redo it. Do not ship it "for now."

### 3. Declare it in pubspec

```yaml
flutter:
  fonts:
    - family: AtkinsonHyperlegibleNext
      fonts: [{ asset: assets/fonts/AtkinsonHyperlegibleNext-VF.ttf }]
```

`google_fonts` is **banned**. It fetches over HTTP at runtime *by default*. It can be forced offline, but that still ships an HTTP client and a network code path into an app whose entire pitch is *"no internet permission — that's not a promise, it's a fact you can check."* Take no dependency. If some package pulls it transitively, that is a blocker, not a wart — see `reed-dependency-hygiene` for the tree audit (`dart pub deps --json` + `audit_deps.py`), not a direct read of `pubspec.yaml`, which cannot see the second hop.

Commit the `pubspec.lock` delta in the same commit as any `pubspec.yaml` change.

### 4. Ship the licence and register it

Ship `OFL.txt` alongside the TTF and register it:

```dart
LicenseRegistry.addLicense(() async* {
  yield LicenseEntryWithLineBreaks(
    ['AtkinsonHyperlegibleNext'],
    await rootBundle.loadString('assets/fonts/OFL.txt'),
  );
});
```

Declare `assets/fonts/OFL.txt` under `flutter: assets:` or it will not be in the bundle at runtime.

### 5. The five type roles

Build exactly these. Resist a sixth — each new role erodes the scale jump that carries the whole aesthetic.

| role | size | wght | tracking | height | align |
|---|---|---|---|---|---|
| `tile` | 20 | **600** | −0.20 (−0.01em) | 1.15 | start, bottom-anchored |
| `show` | **fitted 32–140** | **500** | −0.02em (−1.92 @ 96) | 0.98 | start, ragged right |
| `standing` | 18 | 500 | 0 | 1.30 | start |
| `field` | 22 | 500 | 0 | 1.30 | start |
| `meta` (chrome) | 15 | 500 | +0.15 (+0.01em) | 1.35 | start, lowercase |

The hand-built optical sizing rule, one line each way — **as size rises, weight falls and tracking tightens**:

```
15pt -> w500 / +0.01em
20pt -> w600 / -0.01em
96pt -> w500 / -0.02em
```

Tile→show is **1:5** at the top end; 15→140 across the app is **1:9.3**. That spread *is* the aesthetic. This app cannot use motion, so scale contrast is the loudest instrument available. Do not compress it to make a screen "feel balanced."

Use `FontWeight`, never `FontVariation`. `FontWeight` drives the `wght` axis automatically as of Flutter 3.41 (the `font-weight-variation` breaking change). Setting both double-drives one axis:

```dart
// RIGHT
const TextStyle(
  fontFamily: 'AtkinsonHyperlegibleNext',
  fontSize: 20, fontWeight: FontWeight.w600,
  letterSpacing: -0.20, height: 1.15,
);

// WRONG — double-driving one axis
const TextStyle(
  fontWeight: FontWeight.w600,
  fontVariations: [FontVariation('wght', 600)],
);
```

`FontWeight(560)` is legal for an off-step weight — the axis is continuous; 200…800 are just labelled stops.

### 6. The metric fix for show mode

`ascent 984 > capHeight 668` — the em box is top-heavy, so mathematically centred text sits optically low. The tile label sidesteps this by bottom-anchoring. Show mode needs the metric fix, never a hardcoded nudge (a nudge breaks at 200% text scale and under the dyslexia-font option):

```dart
const TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
  leadingDistribution: TextLeadingDistribution.even,
)
```

### Out of scope

- The colour system and the `ThemeData` wiring (E02-T01, E02-T03).
- The OpenDyslexic option's font asset. This task only needs to leave the tracking-to-zero rule expressible — the `show` widget itself, the fitted 32–140 solver, and the tile bottom-anchoring land in their own screen tasks.
- Any string-table copy work (curly quotes, lowercase chrome) — that is `reed-copy-voice` territory. This task ships the roles, not the words.

## Acceptance criteria

- [ ] `assets/fonts/AtkinsonHyperlegibleNext-VF.ttf` and `assets/fonts/OFL.txt` exist and are committed.
- [ ] The subset TTF is between 80KB and 120KB: `ls -l assets/fonts/AtkinsonHyperlegibleNext-VF.ttf`.
- [ ] A font-inspection command run against the committed TTF reports `wght min 200 default 400 max 800`. Paste the output into the commit message.
- [ ] `grep -rn 'google_fonts' pubspec.yaml pubspec.lock` returns nothing.
- [ ] `grep -rn 'FontVariation' lib/` returns nothing.
- [ ] `grep -rni 'italic\|FontStyle.italic' lib/` returns nothing.
- [ ] `grep -rn 'FittedBox\|toUpperCase()\|toLowerCase()\|TextOverflow.ellipsis' lib/` returns nothing.
- [ ] `grep -rn 'TextAlign.left\|TextAlign.right' lib/` returns nothing — `TextAlign.start` and `EdgeInsetsDirectional` only, so RTL mirrors.
- [ ] A unit test asserts each of the five roles' exact `fontSize`, `fontWeight`, `letterSpacing`, and `height` against the table above — five roles, twenty assertions, no tolerance.
- [ ] A unit test asserts every role's `fontFamily == 'AtkinsonHyperlegibleNext'` (a role that fell back to Roboto passes a size assertion).
- [ ] A test asserts `LicenseRegistry.licenses` yields an entry whose packages include `AtkinsonHyperlegibleNext` and whose text is non-empty.
- [ ] A golden test at w400 and at w800 for the same string produces **different** bytes — this is the only automatic proof the axis survived subsetting.
- [ ] `pubspec.lock` is in the same commit as the `pubspec.yaml` change.
- [ ] `flutter analyze` is clean and `flutter build apk --debug` succeeds (a green analyzer is not proof the font resolved).

## Traps

- **The subsetter instances the font and nothing tells you.** This is the headline trap. `pyftsubset` will happily produce a static-weight font that renders identically at w400, passes every visual check, and fails only when the platform `boldText` flag is on. Nothing in the app crashes. Nothing in CI goes red unless you write the two-weight golden. Verify the axis with the tooling immediately after subsetting, before you commit — the check costs ten seconds and the failure costs an accessibility user their app.
- **Dropping `--layout-features='*'`.** The default feature set strips OpenType features you did not know you were relying on, and the damage shows up as subtly wrong kerning in one phrase nobody looks at.
- **Reaching for `FontVariation('opsz', …)`.** There is no `opsz` axis. It no-ops. Optical sizing here is hand-built with the three-line rule above.
- **Reaching for italic.** There is no `ital` axis and the italic file is not shipped. `FontVariation('ital', 1)` **silently no-ops** — so a "working" italic is impossible to spot in review. Never use italic anywhere, including emphasis in chrome. Emphasise with weight or size, or not at all.
- **`letterSpacing` left at 0 above 17pt.** Flutter's default tracking is calibrated for roughly 14pt; doing nothing at 20pt is doing the *wrong* thing, not the neutral thing. The zeroes in the table are deliberate at 18pt and 22pt only; every size above that carries an explicit value.
- **Tracking below −0.02em.** Past that, Atkinson's generous sidebearings stop protecting letter separation — which is the single thing being paid for in payload and width.
- **w700 in show mode.** Bold at 100pt closes the counters, and counter size is a real legibility factor. w500 at poster scale is both prettier and more legible. Weight below 400 is banned anywhere — that is the Roboto Light hangover.
- **Varying weight by palette.** `wght` changes advance widths, so a weight that differs by theme re-wraps a label when the theme changes. Reflow is banned. That layout bug ships silently: there is no telemetry, and a user mid-shutdown does not file bugs. `boldText` is the only thing permitted to move weight.
- **A hardcoded pixel nudge to fix the optical centring in show mode.** It looks right on your device at 100% and breaks at 200% text scale and under the dyslexia-font option. Use `TextHeightBehavior`.
- **`FittedBox` or auto-shrink on a tile label.** The obvious move, and backwards: it makes the *longest* (most complex) phrase the *smallest*, destroys the grid's rhythm, and overrides the user's own `TextScaler` setting. One uniform size for all 12 tiles — variable line count is fine, variable size reads as broken.
- **Ellipsising a label.** An ellipsis on an AAC utterance is a *different utterance*. Fix the layout; never hide the overflow.
- **`toUpperCase()` / a text transform for the lowercase chrome.** Author the chrome lowercase **in the string table**, or you will eventually lowercase someone's name. And never apply Reed's authoring rules to what a user typed.
- **Claiming the font is "scientifically proven."** No independent peer-reviewed validation exists. The only honest phrasing anywhere — store copy, settings, a code comment — is *"developed and tested with low-vision readers at the Braille Institute."*
- **Forgetting `OFL.txt` in `flutter: assets:`.** `LicenseRegistry.addLicense` with a `rootBundle.loadString` on an undeclared asset throws at runtime, inside a lazily-evaluated licence stream, which surfaces as an empty licences page rather than a crash — silent, and a redistribution defect.

## Files

- `assets/fonts/AtkinsonHyperlegibleNext-VF.ttf` — new (subset, wght axis intact)
- `assets/fonts/OFL.txt` — new
- `pubspec.yaml` — add `fonts:` block and the `OFL.txt` asset entry
- `pubspec.lock` — committed delta
- `lib/design/typography.dart` — new; the five roles
- `lib/design/font_licence.dart` — new; the `LicenseRegistry.addLicense` registration (called from app startup)
- `test/design/typography_test.dart` — new; role value assertions + family assertion
- `test/design/font_licence_test.dart` — new
- `test/golden/font_weight_axis_test.dart` — new; w400 vs w800 differ

## Done when

The subset variable font ships with its licence registered, the five roles hold their exact values in a passing test, and a two-weight golden proves the `wght` axis survived subsetting.
