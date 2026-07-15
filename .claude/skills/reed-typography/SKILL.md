---
name: reed-typography
description: TextStyle, fontSize, fontWeight, letterSpacing, height, and font assets — Reed's one variable typeface (Atkinson Hyperlegible Next, wght 200-800, no italic), five fixed roles, hand-built optical sizing, lowercase chrome, and curly-quote punctuation. Use when editing any TextStyle or type role, adding a sixth type size, wiring fonts in pubspec.yaml or assets/fonts, or reaching for google_fonts, FontVariation, FittedBox, or toUpperCase.
---

# Reed typography

One typeface, five roles, and a scale jump doing the work that motion is banned from doing. Every number below is measured or adjudicated — none is a preference.

## The typeface

**Atkinson Hyperlegible Next**, variable, upright only, SIL OFL 1.1. Source it from `github.com/googlefonts/atkinson-hyperlegible-next` — **never** `brailleinstitute.org`, which gates an open-source font behind email registration and a EULA. Ship `OFL.txt` and register it via `LicenseRegistry.addLicense()`.

Probed facts about the shipped TTF — trust these over any blog:

```
upem 1000 | glyphs 392
axis wght  min 200  default 400  max 800    <- ONE axis. No opsz. No GRAD. No ital.
instances  200 300 400 500 600 700 800
capHeight 668 | ascent 984 | descent -316   <- ascenders sit ABOVE cap height
```

Consequences that bite:

- **No `opsz`.** Optical sizing is hand-built (below). Do not reach for `FontVariation('opsz', …)`; it no-ops.
- **No `ital`.** Italic is a separate file and is not shipped. `FontVariation('ital', 1)` silently no-ops, so a "working" italic is impossible to spot in review — **never use italic anywhere**, including emphasis in chrome. Emphasise with weight or size or not at all.
- **`ascent 984 > capHeight 668`** — the em box is top-heavy, so mathematically centred text sits optically low. Bottom-anchoring the tile label sidesteps this entirely. Show mode needs the metric fix, never a hardcoded nudge (a nudge breaks at 200% text scale and under the dyslexia-font option):

```dart
const TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
  leadingDistribution: TextLeadingDistribution.even,
)
```

**One typeface, everywhere.** Not economy: the tile label and the show poster **are the same string**. Tap "Can't talk" and it becomes a poster. Set in two faces, the utterance changes identity as it amplifies. Same voice, just louder.

**Never claim the font is "scientifically proven."** No independent peer-reviewed validation exists. The only honest phrasing, in store copy or settings or a code comment: *"developed and tested with low-vision readers at the Braille Institute."*

## The five roles

Resist a sixth. Each new role erodes the scale jump that carries the whole aesthetic.

| role | size | wght | tracking | height | align |
|---|---|---|---|---|---|
| `tile` | 20 | **600** | −0.20 (−0.01em) | 1.15 | start, bottom-anchored |
| `show` | **fitted 32–140** | **500** | −0.02em (−1.92 @ 96) | 0.98 | start, ragged right |
| `standing` | 18 | 500 | 0 | 1.30 | start |
| `field` | 22 | 500 | 0 | 1.30 | start |
| `meta` (chrome) | 15 | 500 | +0.15 (+0.01em) | 1.35 | start, lowercase |

Tile→show is **1:5** at the top end; 15→140 across the app is **1:9.3**. That spread *is* the aesthetic. Posters are beautiful because of scale contrast, and this app cannot use motion, so scale contrast is the loudest instrument available. A type-size spread under 3:1 across an app is a dated tell; ours has nine times the room. Do not compress it to make a screen "feel balanced."

## Hand-built optical sizing

One rule, one line each way: **as size rises, weight falls and tracking tightens.**

```
15pt -> w500 / +0.01em
20pt -> w600 / -0.01em
96pt -> w500 / -0.02em
```

This is precisely what answers the "Atkinson looks chunky and institutional at display size" critique — the complaint is true at default settings and is fixed by the setting, not by a different face.

**Never w700 in show mode.** Bold at 100pt closes the counters, and counter size is a real legibility factor. w500 at poster scale is both prettier *and* more legible than bold. Weight below 400 is banned anywhere — it is the Roboto Light hangover.

**Never track below −0.02em.** Past that, Atkinson's generous sidebearings stop protecting letter separation, which is the single thing being paid for in payload and width. If the user enables the OpenDyslexic option, **drop all negative tracking to 0** — that font's proportions assume default spacing.

**Never leave `letterSpacing` at 0 above 17pt.** Flutter's default tracking is calibrated for roughly 14pt; doing nothing at 20pt is doing the wrong thing, not the neutral thing. The zeroes in the table above are deliberate at 18pt and 22pt; every size above that carries an explicit value.

## Weight is frozen across palettes

**Hold weight identical across all four palettes.** `boldText` (the platform accessibility flag) is the only thing permitted to move it.

Two reasons, both hard:

1. Halation on the dark palettes is solved with ink luminance, **never** with weight — heavier glyphs at high luminance contrast bloom *more*, so "thin it out on dark" is backwards.
2. `wght` changes advance widths. A weight that differs by theme re-wraps a label when the theme changes. **Reflow is banned** in this app; a label that gains a line on theme switch is a layout bug that ships silently, because nobody reports it — a user mid-shutdown does not file bugs, and there is no telemetry to catch it.

## `FontWeight`, not `FontVariation`

`FontWeight` drives the `wght` axis automatically as of Flutter 3.41 (the `font-weight-variation` breaking change). Setting both is redundant at best and conflicting at worst.

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

`FontWeight(560)` is legal for an off-step weight — the axis is continuous, the named instances (200…800) are just labelled stops.

## Bundling — never `google_fonts`

`google_fonts` fetches over HTTP at runtime **by default**. It can be configured offline, but that still ships an HTTP client and a network code path into an app whose entire pitch is *"no internet permission — that's not a promise, it's a fact you can check."* Take no dependency. If a package pulls it transitively, that is a blocker, not a wart.

```yaml
flutter:
  fonts:
    - family: AtkinsonHyperlegibleNext
      fonts: [{ asset: assets/fonts/AtkinsonHyperlegibleNext-VF.ttf }]
```

Subset to Latin + punctuation with `pyftsubset`, **preserving the wght axis**: pass `--layout-features='*'` and do not let the subsetter instance the font (an instanced font is a static weight and `boldText` stops working). Flutter tree-shakes *icon* fonts only, never text fonts — subsetting is manual and mandatory. Expect ~80–120KB down from ~200–400KB.

Verify after subsetting that the axis survived — `wght min 200 default 400 max 800` must still be reported by the tooling. A silently instanced font looks identical at w400 and fails only for the accessibility user who turns bold text on.

## Sizing rules that are not typography's to fix

- **One uniform size for all 12 tiles.** Variable line count is fine; variable size reads as broken.
- **Never `FittedBox`, never auto-shrink, never ellipsize a label.** Auto-shrink is the obvious move and it is backwards: it makes the *longest* (most complex) phrase the *smallest*, destroys the grid's rhythm, and overrides the user's own `TextScaler` setting. An ellipsis on an AAC utterance is a *different utterance*.
- **The editor refuses at 16 characters** and never silently truncates. A 2-word label beside a 9-word label is a content problem, not a typographic one — the long text lives in the separate spoken field, not on the chip.
- **Hand-set line breaks** are supported: a literal `\n` in a shipped label (`I need\na minute`) is a **hint**, because ragged text strands words and Flutter has no text-balance. If scaled text exceeds 3 lines, fall back to natural wrap.
- Use `TextAlign.start` and `EdgeInsetsDirectional` — never `TextAlign.left`/`EdgeInsets` — so RTL mirrors.

## Punctuation — the cheapest craft in the system

| rule | why |
|---|---|
| Real apostrophes: `’` not `'` | `I can’t talk right now` at 20pt/w600 reads as made by a person; `I can't talk right now.` reads as a database dump |
| Sentence case | see all-caps below |
| **No terminal periods on tile labels** | a period on a button is institutional |
| Intentional `…` and `—` | typed, not approximated with `...` or `--` |
| Normalise straight quotes to curly **on save only** | never mid-typing — rewriting a character under someone's cursor is hostile |

Zero bytes, zero risk, and most apps get it wrong — which is exactly why getting it right registers as craft. A straight apostrophe in a shipped phrase string is a greppable defect.

**Sentence case, never all-caps.** This is a deliberate override of a real finding: MIT AgeLab measured uppercase as *faster* for glance reading of isolated words (lowercase needed 26% more time). It is overridden because the finding is bounded to 1–2 word phrases and these labels run to four — and because **all caps on an AAC utterance reads as shouting**, which is catastrophic when the phrase is "I need a minute" and the whole point is signalling distress calmly. This question comes back; the answer does not change.

**All chrome is lowercase**: `theme` · `edit` · `show` · `settings`. Democratic, current, adult-indie rather than clinical. Author it lowercase **in the string table** — never a text transform and never `toUpperCase()`/`toLowerCase()` at render, or you will eventually lowercase someone's name.

**Reed's own strings only.** Force-lowercasing a user's phrases is the precise flavour of condescension this product exists to avoid. Sentence case, curly quotes and no-terminal-period are authoring rules for shipped copy; they are never applied to what someone typed.
