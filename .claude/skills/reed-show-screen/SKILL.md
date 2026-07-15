---
name: reed-show-screen
description: "Reed's show/poster mode — show_text_screen.dart, the TextPainter per-line fit clamped 32–140pt, forced light polarity (showGround #FFFCF7, showInk #1A140D), the standing line, the instant flash, tap-anywhere exit. Use when fitting a phrase to the viewport, sizing type from a measured width, choosing line breaks, touching showGround/showInk/showStandingLine, or rendering says full-screen. Not for the shared type roles or font assets — this covers only the measured per-line fit of poster type."
---

# Show mode is a poster, not UI

One screen, one job: a stranger reads it at arm's length in daylight and understands the situation in two seconds. The user is not looking at it — the phone is turned away from their face. Every rule below follows from those two sentences.

## Polarity is forced, not themed

| property | value |
|---|---|
| ground | `showGround` = `#FFFCF7` — **light, always, regardless of the active palette** |
| ink | `showInk` = `#1A140D` — 17.85:1 / Lc +103.3 |
| standing line | `showStandingLine` = `#5A544E` — 7.29:1 / Lc +84.3 on that ground |
| margin | 24dp, all sides |
| chrome | none — no app bar, no buttons, no icons, no back arrow |
| exit | tap anywhere + system back |

Read all three from `AacTheme.of(context)`; every palette (`paper`, `ink`, `hcInk`, `hcPaper`) carries the same three values, which is *why* they are theme fields rather than constants — the contrast gate walks them per palette. Never reach for `t.ground`/`t.ink` here; those invert and would hand a stranger a dark screen in daylight.

Warm ink on warm paper holds Lc +103.3 where pure `#000` on `#FFF` gives +106.0. Do not "fix" the 2.7 Lc: anything past Lc 90 is beyond the fluent-reading bar, and the warmth is what keeps the poster in the same family as the rest of the app.

## The one bold move: each line optically justified

Take `says`. Break it into 2–4 lines. **Scale each line independently so it touches both margins exactly** — flush left *and* flush right, **by size, never by tracking**. Line one at 96pt, line two at 138pt, line three at 71pt is the correct-looking result, not a bug.

Per line, at a probe size of 100:

```dart
final tp = TextPainter(
  text: TextSpan(text: line, style: showStyle.copyWith(fontSize: 100)),
  textDirection: TextDirection.ltr,
)..layout();
final size = (100 * measure / tp.width).clamp(32.0, 140.0);
```

`measure` is the column width (viewport width − 48). The probe is a linear-scaling assumption and it holds: glyph advances scale with `fontSize`. Lay out each candidate line **unconstrained** (no `maxWidth`) — a constrained `layout()` wraps and `tp.width` then reports the constraint, silently returning the same size for every line and quietly deleting the whole feature.

Choose the break by **brute force**: for `n` in 1..4, enumerate break points (≤56 combinations for a ≤9-word phrase), score each candidate by **the largest minimum line size that still fits the height**, take the winner. Maximise the *minimum* — not the mean, not the max — because the smallest line is what a stranger struggles with, and a candidate that wins on average while dropping one line to 34pt is worse than a flat one. Break only at spaces; never hyphenate, never break a word.

Ties (identical minimum size) break toward **fewer lines**: fewer lines is fewer fixations at reading distance.

56 combinations × 4 lines of `TextPainter` is one layout pass on a screen with no animation and no assets. It is not worth caching, memoising, or moving to an isolate. Fit inside `LayoutBuilder` and recompute on every constraint change — rotation and `textScaler` both change the answer.

**Why this is right and not merely nice: the most beautiful setting and the most legible setting are the same computation.** Wherever width binds — which it does for any phrase long enough to need two lines — per-line justification is arithmetically ≥ uniform setting for every line, because a uniform setting is constrained by the *longest* line and every other line is then smaller than it could be. The cashier gets the largest letters physically available for that phrase in that rectangle, and the result is a Swiss poster. That coincidence is the entire reason to do it. Do not replace it with `FittedBox`, `AutoSizeText`, or a uniform fit — those all solve for the longest line and throw the rest away.

## Type

| property | value | why |
|---|---|---|
| size | fitted, `clamp(32.0, 140.0)` | 32 is the legibility floor; 140 is where a phone's own frame becomes the constraint |
| weight | **w500 — never w700** | bold at 100pt closes the counters, and counter size is a real legibility factor; w500 at poster scale is both prettier *and* more legible than bold |
| tracking | −0.02em (−1.92 at 96pt) | as size rises, weight falls and tracking tightens — Atkinson has no `opsz` axis, so compensate by hand |
| height | 0.98 | |
| align | `TextAlign.start`, ragged right | use `TextAlign.start` + `EdgeInsetsDirectional`, never `.left`/`EdgeInsets`, so RTL mirrors |
| block | 2–4 lines, vertically centred as one optical block | |

Never track below −0.02em: past that, Atkinson's generous sidebearings stop protecting letter separation, which is the one thing the typeface is being paid for. If the OpenDyslexic option is on, drop negative tracking to 0 — that font's proportions assume default spacing.

Set weight with `fontWeight: FontWeight.w500` only. Do **not** additionally pass `FontVariation('wght', 500)`; `FontWeight` drives the `wght` axis on its own and passing both is a conflict.

**Vertical centring is metric, never a nudge.** Atkinson's em box is top-heavy (ascent 984 > capHeight 668), so mathematically-centred display type sits optically low. Fix it with:

```dart
const TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
  leadingDistribution: TextLeadingDistribution.even,
)
```

A hardcoded `Padding(top: -6)`-style correction is wrong at every size the fitter produces, and breaks outright at 200% text scale and on the dyslexia font. If `DefaultTextHeightBehavior` is already installed app-wide, do not re-derive it locally — but never let it be stripped from this subtree.

## The standing line

Above the poster, at the top margin, start-aligned: the `standing` role — 18pt / w500 / tracking 0 / height 1.30, in `showStandingLine`.

Default text: **`I can’t speak right now. I can hear you.`** (real apostrophe). User-editable in settings, including empty. **Default ON.**

This — not the 140pt type — is the design investment show mode actually needs. **The enemy is being misread, not being unseen.** Show mode's job is frame control: the two seconds where a stranger decides whether they are talking to a competent adult with a temporary problem, or to a person something is wrong with. A phone held up saying "Thank you" in huge type reads as *weird*. The same phone with the standing line above it reads instantly. The phrase is what the user said; the line is what stops it being misread.

The standing line does **not** participate in the fitting algorithm — it is fixed at 18pt and its height is subtracted from the budget the fitter scores against. Never scale it, never justify it, never let it grow to two lines' worth of weight and compete with the phrase.

## The flash — decided

Entering show mode from the `ink` palette jumps L 0.19 → 0.98 in one frame. **It flashes. Instantly. No ramp.** No fade, no `AnimatedContainer`, no `Color.lerp`, no route transition.

The user deliberately pressed a control and is turning the phone away from their own face at that moment — that *is* the mitigation. A ramp is *longer* exposure to the transition and costs latency in the one moment where latency has a social cost. This is a design judgment, and it ships with an escape hatch rather than an argument:

**Settings: `Show screen: bright · match my theme`.** A user who cannot tolerate the flash picks `match my theme` and pays the stranger-legibility cost knowingly. That is their call, and it is the only condition under which show mode is not `#FFFCF7`. Ship the setting; do not ship a compromise ramp instead of it.

**v1 does not touch screen brightness.** 17.85:1 suffices at typical brightness, and a brightness plugin is a native dependency and another sensory event.

## Exit

**A tap anywhere, plus the system back gesture. Never a targeted control.** The user is not looking at the screen; hunting for a dismiss target by feel on a max-luminance surface while photophobic and mid-shutdown is a failure mode with no upside. A close button in the corner is the wrong answer even "as well as" — it invites the fit algorithm to reserve space for chrome that must not exist.

Wrap the whole poster in a full-bleed gesture target (`GestureDetector` with `behavior: HitTestBehavior.opaque`), not a button. There is no dead zone: the standing line, the margins, and the type are all exit surface.

## Degradation

Show mode **never scrolls** — except once. If `says` is long enough that six lines at the 32pt floor still overflow the height, the poster becomes a **scrollable block at a uniform 32pt**. That is an honest degradation for a user who deliberately wrote a paragraph, and it is the only path where the justification is abandoned. Detect it by the fitter failing to seat any candidate at ≥32pt within the height budget — never by a character count, which is wrong at every text scale.

Never clip, never ellipsise, never `TextOverflow.fade`. The words are the product; a truncated sentence in a stranger's face is a total failure of the screen.

Landscape is offered and yields roughly 2× the type size — the fitter produces this for free from the wider `measure`. Do not lock orientation here.

## The known risk

Varying line size is typographic emphasis, and emphasis is semantic. *"I can't **TALK** right now"* with TALK at 138pt says something the user did not say, and a stranger may read the biggest line as the stressed line. This is unmeasured. Keep the fitter behind a seam so the fallback stays cheap: **uniform setting at the longest line's fitted size** — still a poster, less of one. Do not pre-emptively cap the size ratio between lines to hedge; that gets both the beauty and the legibility wrong while proving nothing.

## Banned in show mode

`BoxShadow` · `elevation:` · `BackdropFilter` · blur · gradients · any animation or transition · any icon · any app bar · `FittedBox`/`AutoSizeText` for the phrase · uniform sizing across lines · w700 · tracking below −0.02em · hardcoded vertical nudges · a targeted exit control · colour literals outside the tokens file.
