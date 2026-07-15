# E06 — Show mode

> A full-screen poster: `says` broken into 2–4 lines, each line scaled independently to touch both margins, forced light polarity, a standing line above it, and a tap anywhere to leave.

| | |
|---|---|
| **Status** | Not started |
| **Tasks** | 3 |
| **Depends on** | E02 (design system — `showGround`/`showInk`/`showStandingLine` on `AacTheme`, the `show` and `standing` roles, the bundled variable font) |

## Why this epic exists

Most people with part-time speech loss display text rather than, or alongside, speaking it. A cashier, a nurse, a partner reads the phone. Show mode is therefore co-equal with TTS, not a fallback for when TTS fails — although it is also that, because every speech failure puts the words on screen.

Getting it wrong has two distinct failure shapes, and they are not the same bug:

- **Illegible.** Type too small, or clipped, or ellipsised, at arm's length in daylight. The words are the product; a truncated sentence in a stranger's face is a total failure of the screen.
- **Misread.** A phone held up saying "Thank you" in 140pt type reads as *weird*. The two seconds where a stranger decides whether they are talking to a competent adult with a temporary problem, or to a person something is wrong with, is decided by the standing line above the phrase — not by the size of the phrase. **The enemy is being misread, not being unseen.** That is why E06-T03 exists and is not a polish task.

There is no telemetry. Nobody will ever report that the fitter returned 32pt for every line because a `TextPainter` was laid out with a `maxWidth`. Tests are the only instrument.

## What "done" means

- `flutter test` green, including golden tests for the show screen at the four palettes (all four render the *same* light poster) and at `TextScaler.linear(1.0)` and `2.0`, portrait and landscape.
- Tapping a tile whose `says` is `I can’t talk right now but I’m okay.` opens a screen with: no app bar, no icon, no button; ground `#FFFCF7`; ink `#1A140D`; the standing line at 18pt in `#5A544E` at the top margin; the phrase in 2–4 lines at **different** sizes, each within 1dp of the 24dp margins on both sides.
- A unit test on the fitter asserts that for a multi-line phrase, at least two lines have different `fontSize`, every line's measured width equals `measure` within tolerance, and every size is inside `[32.0, 140.0]`.
- A paragraph-length `says` that cannot seat six lines at 32pt renders as a uniform-32pt scrollable block — asserted by a test, never by a character count.
- A tap at the centre, at a margin, and on the standing line each pop the route. There is no dead zone.
- `hasScheduledFrame` is false after one `pump()` following entry to show mode: the flash is a frame, not a transition.
- Settings carries `Show screen: bright · match my theme`, defaults to `bright`, and the standing line is user-editable including empty, default ON.
- `grep -rn 'Color(0x' lib/ui/show/ ` returns nothing.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E06-T01 | Per-line optical fitting | M | E02-T02 |
| E06-T02 | The show screen | S | E06-T01 |
| E06-T03 | The standing line and the flash setting | S | E06-T02 |

**E06-T01 — Per-line optical fitting** is the epic's only hard problem, and it is a pure function: `(says, measure, heightBudget, TextStyle) → List<(String line, double size)>`. Brute-force the break points for `n` in 1..4 (≤56 combinations for a ≤9-word phrase), size each candidate line from a probe layout at `fontSize: 100`, score by **the largest minimum line size that still fits the height**, break ties toward fewer lines. It is an M because the scoring rule, the unconstrained-layout requirement, and the degradation trigger all have to be right and none of them is visible when wrong. Testable with no widget tree, which is why it is separated from T02 at all.

**E06-T02 — The show screen** wires the fitter into a `LayoutBuilder`, forces light polarity from `AacTheme.of(context)` regardless of the active palette, installs the metric vertical centring, and makes the entire surface a `GestureDetector` with `behavior: HitTestBehavior.opaque`. Small, because T01 did the thinking. Its risk is not arithmetic — it is that a well-meaning app bar, close button, or route transition appears.

**E06-T03 — The standing line and the flash setting** adds the 18pt line above the poster (default `I can’t speak right now. I can hear you.`, real apostrophe, editable including empty, default ON) and ships the `Show screen: bright · match my theme` preference. It comes last because both consume the finished layout: the standing line's height is subtracted from the fitter's budget, and the setting is the escape hatch for the flash T02 already ships. It is the smallest task and the one that decides whether the screen works socially.

## Skills this epic draws on

**Layout and type**
- `reed-show-screen` — the whole poster: the probe-and-scale fitter, the maximise-the-minimum scoring, the 24dp margin, the standing line, the flash, tap-anywhere exit, the scrollable-32pt degradation, and the ban list.
- `reed-typography` — the `show` role (fitted 32–140, w500, −0.02em, height 0.98) and the `standing` role (18/500/0/1.30); `FontWeight` never `FontVariation`; the `TextHeightBehavior` fix for Atkinson's top-heavy em box.

**Appearance**
- `reed-colour-system` — `showGround` `#FFFCF7`, `showInk` `#1A140D` (17.85:1 / Lc +103.3), `showStandingLine` `#5A544E` (7.29:1 / Lc +84.3); read from `AacTheme.of(context)`, never a literal.
- `reed-motion-policy` — the flash is one frame with no ramp; no route transition; `pump()` not `pumpAndSettle()`.

**Correctness**
- `reed-a11y-coding` — the poster honours `textScaler` and `boldText` by not touching them; no `FittedBox`, no `ellipsis`; the exit target carries semantics.
- `reed-copy-voice` — the standing-line default and the settings string; no apology, no "we", real apostrophes.

## Sequencing

A hard chain: **E06-T01 → E06-T02 → E06-T03**. Nothing here parallelises, and the chain is real rather than bureaucratic.

T01 cannot start before **E02-T02** because the fitter's probe measures *this* font — the answer for Atkinson at wght 500 is not the answer for Roboto, and a fitter tuned against a placeholder face produces plausible numbers that are all wrong. T02 needs T01's function to exist because its `LayoutBuilder` has nothing to call otherwise, and stubbing it with a uniform size would let a uniform-setting screen get golden-approved. T03 needs T02 because the standing line's 18pt height is subtracted from the budget T02 hands the fitter, and because the flash setting can only be written against a screen that already flashes.

E06 does not block anything. It depends on E02 for tokens and type, and on the speak screen only for a route to enter from — if E05 lands late, drive show mode from a test harness route rather than blocking.

## Risks specific to this epic

- **The constrained-layout bug, which is silent.** `TextPainter.layout(maxWidth: measure)` wraps the line and then `tp.width` reports the constraint, so `100 * measure / tp.width` returns 100 for every line. Every line comes back the same size, the feature is gone, and the screen still looks fine. Lay out each candidate **unconstrained**. Guard it with a test that asserts two lines differ in size.
- **Scoring the mean instead of the minimum.** Maximising the mean lets a candidate win while dropping one line to 34pt. The smallest line is what a stranger struggles with. Maximise the minimum.
- **`FittedBox` / `AutoSizeText` looks like the same feature and is not.** Both solve for the longest line and shrink everything else to match — the exact result per-line fitting exists to avoid. They will be suggested. They are banned here.
- **Someone "fixes" the polarity.** Reading `t.ground`/`t.ink` instead of `t.showGround`/`t.showInk` looks like theme hygiene and hands a stranger a dark screen in daylight. Guard with a golden that renders show mode under the `ink` palette and matches the `paper`-palette golden byte-for-byte.
- **Someone "fixes" the warmth.** `#1A140D` on `#FFFCF7` is Lc +103.3 where `#000` on `#FFF` is +106.0. Anything past Lc 90 is beyond the fluent-reading bar; the 2.7 Lc is what keeps the poster in the same family as the app. Do not spend a review arguing this twice.
- **A hardcoded vertical nudge.** `Padding(top: -6)` centres the block at exactly one size the fitter never produces twice, and breaks outright at 200% text scale and under the dyslexia font. Use `TextHeightBehavior`.
- **Chrome creeps in.** A close button "as well as" tap-anywhere invites the fitter to reserve space for it. The user is not looking at the screen; hunting for a dismiss target by feel on a max-luminance surface is a failure mode with no upside.
- **Emphasis is semantic, and this is unmeasured.** *"I can't **TALK** right now"* with TALK at 138pt says something the user did not say, and a stranger may read the biggest line as the stressed line. Keep the fitter behind a seam so the fallback — uniform setting at the longest line's fitted size — is a one-line swap. Do not pre-emptively cap the size ratio between lines: that loses the beauty and the legibility and proves nothing.
- **Degradation detected by character count.** Wrong at every text scale and every orientation. Detect it by the fitter failing to seat any candidate at ≥32pt inside the height budget.
- **Premature optimisation of the fitter.** 56 combinations × ≤4 lines of `TextPainter` is one layout pass on a screen with no animation and no assets. A cache keyed on the phrase goes stale on rotation and on a `textScaler` change — both of which change the answer — and the staleness is invisible. Fit inside `LayoutBuilder` and recompute on every constraint change.
- **Double-driving the weight axis.** `fontWeight: FontWeight.w500` plus `FontVariation('wght', 500)` is a conflict, and at 100pt the wrong resolution is subtle enough to ship. Set `FontWeight` only.
- **The standing line growing.** It is fixed at 18pt, does not participate in the fit, and its height is subtracted from the budget. Letting it scale or wrap to two lines gives it the weight to compete with the phrase, and then there are two posters on the screen.

## Out of scope

- **The tokens, the palettes, and the font asset** — E02. `showGround`/`showInk`/`showStandingLine` are already fields on every palette when this epic starts; the contrast gate that walks them per palette is E02-T04.
- **The route in from a tile, and the tile's own type** — E05. Show mode receives a `says` string; how a tap produced it is not this epic's problem.
- **TTS, the lit state, and speech failure handling** — E04. The rule that every speech failure shows the words is E04's; show mode is the surface it lands on, and needs no special case for it.
- **The settings screen itself** — E06-T03 contributes two controls (`Show screen`, the standing-line text) to a screen owned elsewhere; it does not build a settings framework.
- **Screen brightness.** v1 does not touch it. 17.85:1 suffices at typical brightness, and a brightness plugin is a native dependency and another sensory event.
- **Orientation locking.** Landscape yields roughly 2× the type size for free from the wider `measure`. Do not lock it here or anywhere.
