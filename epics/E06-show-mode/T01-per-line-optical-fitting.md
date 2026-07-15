# E06-T01 — Per-line optical fitting

| | |
|---|---|
| **Epic** | E06 — Show mode |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E02-T02 |
| **Blocks** | E06-T02 |

**Skills:** `reed-show-screen` · `reed-typography`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Show mode is the phone turned away from the user's face at a cashier, arm's length, in daylight. The stranger has about two seconds. Per-line optical fitting is not decoration: a uniform fit solves for the *longest* line and every other line is then smaller than it could be, so the stranger reads smaller letters than the rectangle could have given them. The most beautiful setting and the most legible setting are the same computation — that coincidence is the entire reason to do this.

## Scope

Build the fitter: a pure function that takes `says`, the available rectangle, and the resolved `show` `TextStyle`, and returns the chosen line break plus a per-line font size. No widget work beyond what E06-T02 needs to consume — this task delivers the algorithm and its tests.

**The `show` type role (from `reed-typography`, do not re-derive):**

| property | value |
|---|---|
| size | fitted, `clamp(32.0, 140.0)` |
| weight | `FontWeight.w500` — **never** w700 |
| tracking | −0.02em (−1.92 at 96pt) |
| height | 0.98 |
| align | `TextAlign.start`, ragged right |
| block | 2–4 lines, vertically centred as one optical block |

Set weight with `fontWeight: FontWeight.w500` only. Do **not** also pass `FontVariation('wght', 500)` — `FontWeight` drives the `wght` axis on its own and passing both is a conflict. If the OpenDyslexic option is on, drop the negative tracking to `0`.

**The measure.** `measure` = viewport width − 48 (24dp margin, all sides). The height budget is the viewport height minus the 24dp top and bottom margins minus the space the standing line occupies. The standing line (`standing` role: 18pt / w500 / tracking 0 / height 1.30) does **not** participate in fitting — it is fixed at 18pt and its height is simply subtracted from the budget the fitter scores against.

**Per-line probe.** Probe at a fixed size of 100 and scale by the ratio:

```dart
final tp = TextPainter(
  text: TextSpan(text: line, style: showStyle.copyWith(fontSize: 100)),
  textDirection: TextDirection.ltr,
)..layout();
final size = (100 * measure / tp.width).clamp(32.0, 140.0);
```

`layout()` is called **unconstrained** — no `maxWidth`. The probe is a linear-scaling assumption and it holds: glyph advances scale with `fontSize`.

**Choosing the break — brute force.** For `n` in 1..4, enumerate the break points over the word list (≤56 combinations for a ≤9-word phrase). Break **only at spaces**; never hyphenate, never break a word. Score each candidate by **the largest minimum line size that still fits the height**; take the winner. Maximise the *minimum*, not the mean and not the max — the smallest line is what a stranger struggles with, and a candidate that wins on average while dropping one line to 34pt is worse than a flat one. **Ties (identical minimum size) break toward fewer lines** — fewer lines is fewer fixations at reading distance.

56 combinations × 4 lines of `TextPainter` is one layout pass on a screen with no animation and no assets. **Do not cache, memoise, or move it to an isolate.** Run it inside `LayoutBuilder` and recompute on every constraint change — rotation and `textScaler` both change the answer. Landscape yields roughly 2× the type size for free from the wider `measure`; do not lock orientation.

**Vertical centring is metric, never a nudge.** Atkinson's em box is top-heavy (ascent 984 > capHeight 668), so mathematically-centred display type sits optically low:

```dart
const TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
  leadingDistribution: TextLeadingDistribution.even,
)
```

If `DefaultTextHeightBehavior` is already installed app-wide, do not re-derive it locally — but never let it be stripped from this subtree.

**The degradation path.** If no candidate seats at ≥32pt within the height budget (roughly: six lines at the floor still overflow), the fitter reports failure and the poster becomes a **scrollable block at a uniform 32pt**. Detect this by the fitter failing, **never** by a character count — a character count is wrong at every text scale. This is the only path where justification is abandoned. Never clip, never ellipsise, never `TextOverflow.fade`.

**The seam.** Varying line size is typographic emphasis, and emphasis is semantic — a stranger may read the biggest line as the stressed line. This is unmeasured. Keep the fitter behind an interface so the fallback stays cheap: **uniform setting at the longest line's fitted size**. Do **not** pre-emptively cap the size ratio between lines to hedge.

**Out of scope:** the show screen widget, `showGround` #FFFCF7 / `showInk` #1A140D / `showStandingLine` #5A544E wiring, the flash, the tap-anywhere exit, the standing line's own copy and settings toggle — all E06-T02.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] Unit test: a phrase whose fit produces different per-line sizes asserts the sizes **differ** (e.g. a candidate producing ~96 / ~138 / ~71). A test that passes with every line equal means the fitter is dead.
- [ ] Unit test: every returned line's laid-out width at its returned size is within a small epsilon of `measure` — flush left and flush right — unless that line clamped at 32.0 or 140.0.
- [ ] Unit test: the returned sizes are all within `[32.0, 140.0]`.
- [ ] Unit test: the winner has a minimum line size ≥ the minimum line size of every other candidate that fits the height (assert against a brute-force reference over the same candidate set).
- [ ] Unit test: two candidates with identical minimum size resolve to the one with **fewer** lines.
- [ ] Unit test: no returned line ever splits a word; joining the lines with a single space reproduces the input word sequence exactly.
- [ ] Unit test: line count is always in 1..4 on the fitted path.
- [ ] Unit test: a paragraph-length `says` returns the degraded result (uniform 32pt, scrollable), and the trigger is the fitter's failure, not a length threshold.
- [ ] Unit test: the same phrase at a wider `measure` (landscape) returns sizes ≥ the portrait sizes.
- [ ] Unit test: total block height + standing-line height + 48 ≤ viewport height for the winner.
- [ ] Grep check: no `FittedBox`, no `AutoSizeText`, no `FontVariation('wght'`, no `w700`, no `TextAlign.left`, no `EdgeInsets(` (use `EdgeInsetsDirectional`) in the fitter or its consumer.
- [ ] Grep check: the fitter's `layout()` calls pass no `maxWidth`.

## Traps

- **Constrained `layout()` deletes the feature silently.** Passing `maxWidth` makes the painter wrap, and `tp.width` then reports the *constraint* — so every line probes at the same width, every line gets the same size, and the whole bold move quietly becomes a uniform fit that nobody notices in review. Lay out unconstrained.
- **Reaching for `FittedBox` / `AutoSizeText` / a uniform fit.** All three solve for the longest line and throw the rest away. They look like they work. They are the exact thing this task exists to not do.
- **Maximising the mean or the max.** Both produce candidates that strand one line at 34pt next to a 130pt line. The stranger's read speed is set by the smallest line.
- **Forgetting to subtract the standing line's height** from the budget. The fitter then seats a block that overlaps or pushes the standing line off, and it only shows up at large text scales.
- **A hardcoded vertical nudge** (`Padding(top: -6)` and friends) instead of `TextHeightBehavior`. It is wrong at every size the fitter produces and breaks outright at 200% text scale and on the dyslexia font.
- **Detecting the degradation by character count.** Wrong at every text scale. The only honest signal is the fitter failing to seat any candidate at ≥32pt.
- **Passing both `FontWeight.w500` and `FontVariation('wght', 500)`.** Double-driving one axis.
- **Caching or memoising the fit.** It is one layout pass. Caching it means a stale answer after rotation or a `textScaler` change — a subtle wrong-size poster with no telemetry to catch it.
- **Leaving negative tracking on under the OpenDyslexic option.** That font's proportions assume default spacing; drop to 0.
- **Hyphenating or word-breaking to make a candidate fit.** Break only at spaces. A broken word in a stranger's face is a different utterance.
- **Capping the inter-line size ratio "to be safe".** Gets both the beauty and the legibility wrong and proves nothing about the emphasis risk. Keep the seam instead.

## Files

- Creates the fitter (pure Dart, no widgets) and its unit tests.
- Touches `show_text_screen.dart` only to the extent of exposing the seam that E06-T02 consumes.

## Done when

Given any `says` and a rectangle, the fitter returns 1–4 space-broken lines each sized to touch both margins within `[32, 140]`, maximising the minimum line size and tie-breaking to fewer lines — or reports the uniform-32pt scrolling degradation — and the unit tests prove each of those properties.
