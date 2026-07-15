# E06-T02 — The show screen

| | |
|---|---|
| **Epic** | E06 — Show mode |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E06-T01 |
| **Blocks** | E06-T03, E10-T05 |

**Skills:** `reed-show-screen` · `reed-colour-system` · `reed-a11y-coding` · `reed-motion-policy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

E06-T01 produced a fitter: a phrase in, a set of per-line sizes out. This task is the screen it paints on — the one surface in Reed that the user is not looking at. The phone is turned away from their face and a stranger has about two seconds to decide whether they are talking to a competent adult with a temporary problem. Every rule below is either "the stranger can read it" or "the user can get out of it without looking", and those two are the whole screen.

## Scope

Build `lib/ui/show_text/show_text_screen.dart`: a full-screen poster for one `says` string, with a standing line above it, no chrome of any kind, and exit by tapping anywhere.

### Polarity is forced, not themed

Read all three from `AacTheme.of(context)`. Every palette (`paper`, `ink`, `hcInk`, `hcPaper`) carries the same three values — that is *why* they are theme fields and not constants, so the CI contrast gate walks them per palette.

| property | value | measured |
|---|---|---|
| ground | `showGround` = `#FFFCF7` | light, **always**, regardless of the active palette |
| ink | `showInk` = `#1A140D` | 17.85:1 / Lc +103.3 |
| standing line | `showStandingLine` = `#5A544E` | 7.29:1 / Lc +84.3 on that ground |
| margin | 24dp, all sides | |
| chrome | none — no app bar, no buttons, no icons, no back arrow | |

**Never reach for `t.ground` / `t.ink` in this file.** Those invert with the palette and would hand a stranger a dark screen in daylight. The app is dark because that is right for the user's eyes; the poster is light because that is right for a stranger's. Opposite optimisations, distinct renders, one file that must not confuse them.

Do not "fix" the 2.7 Lc that warm ink on warm paper costs against `#000` on `#FFF` (+103.3 vs +106.0). Anything past Lc 90 is beyond the fluent-reading bar, and the warmth is what keeps the poster in the same family as the rest of the app.

The **one** exception: the `Show screen: bright · match my theme` setting. On `match my theme`, and only then, the poster uses the active palette's `ground`/`ink`. Default is `bright`.

### The standing line

Above the poster, at the top margin, start-aligned: the `standing` role — **18pt / w500 / tracking 0 / height 1.30**, in `showStandingLine`.

Default text: **`I can’t speak right now. I can hear you.`** — real apostrophe (U+2019), not `'`. User-editable in settings, including empty. **Default ON.**

It does **not** participate in the fitting algorithm. It is fixed at 18pt, and its **rendered height at the current `textScaler`** is subtracted from the height budget passed to the fitter. Never scale it, never justify it, never let it grow to two lines' worth of weight and compete with the phrase. If it is empty or off, subtract nothing — do not reserve an 18pt band of blank paper.

This, not the 140pt type, is what show mode is actually for. The enemy is being misread, not being unseen. A phone held up saying "Thank you" in huge type reads as *weird*; the same phone with the standing line above it reads instantly.

### The phrase

Feed the fitter (E06-T01) `says`, the column width, and the remaining height budget; paint what it returns.

| property | value |
|---|---|
| size | per line, from the fitter, `clamp(32.0, 140.0)` |
| weight | **`FontWeight.w500` — never w700** |
| tracking | −0.02em (−1.92 at 96pt); **0 when the OpenDyslexic option is on** |
| height | 0.98 |
| align | `TextAlign.start`, ragged right — `EdgeInsetsDirectional`, never `.left`/`EdgeInsets`, so RTL mirrors |
| block | 2–4 lines, vertically centred as one optical block |

Set weight with `fontWeight: FontWeight.w500` **only**. Do not additionally pass `FontVariation('wght', 500)` — `FontWeight` drives the `wght` axis on its own and passing both is a conflict.

Vertical centring is **metric, never a nudge**. Atkinson's em box is top-heavy (ascent 984 > capHeight 668), so mathematically-centred display type sits optically low:

```dart
const TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
  leadingDistribution: TextLeadingDistribution.even,
)
```

If `DefaultTextHeightBehavior` is already installed app-wide, do not re-derive it locally — but never let it be stripped from this subtree. A `Padding(top: -6)`-style correction is wrong at every size the fitter produces and breaks outright at 200% text scale and on the dyslexia font.

Fit inside `LayoutBuilder` and recompute on every constraint change — rotation and `textScaler` both change the answer. Do not cache, memoise, or isolate it. Landscape is offered and yields roughly 2× the type size for free from the wider `measure`; **do not lock orientation here**.

### Exit

**A tap anywhere, plus the system back gesture. Never a targeted control.** The user is not looking at the screen. Hunting for a dismiss target by feel on a max-luminance surface while photophobic and mid-shutdown is a failure mode with no upside. A close button in the corner is the wrong answer even "as well as" — it invites the fit algorithm to reserve space for chrome that must not exist.

```dart
GestureDetector(
  behavior: HitTestBehavior.opaque,   // full-bleed: no dead zone anywhere
  onTap: () => Navigator.of(context).pop(),
  child: poster,
)
```

The standing line, the margins, and the type are all exit surface. System back pops normally — nothing blocks it, no `PopScope(canPop: false)`.

For TalkBack and switch users the poster is still one interactive node: `Semantics(button: true, label: <dismiss label>)` on the exit target, with the phrase text reachable. An unlabelled full-bleed `GestureDetector` is a screen a switch user cannot leave. Take the dismiss wording from `reed-copy-voice`; do not invent it here.

### The flash

Entering from the `ink` palette jumps L 0.19 → 0.98 in one frame. **It flashes. Instantly. No ramp.** No fade, no `AnimatedContainer`, no `Color.lerp`, no route transition. The user deliberately pressed a control and is turning the phone away from their own face at that moment — that *is* the mitigation, and a ramp is *longer* exposure to the transition plus latency in the one moment where latency has a social cost. The escape hatch is the setting, not a compromise ramp.

Push with a plain route; the app-root `pageTransitionsTheme` (`_NoTransitions`) already makes it a hard cut. Do not reach for `PageRouteBuilder`, `fullscreenDialog: true`, or `showGeneralDialog`, all of which reintroduce a transition.

**v1 does not touch screen brightness.** 17.85:1 suffices at typical brightness, and a brightness plugin is a native dependency and another sensory event.

### Degradation is honest, not silent

Show mode **never scrolls — except once.** If the fitter cannot seat any candidate at ≥ 32pt within the height budget, the poster becomes a **scrollable block at a uniform 32pt**. That is an honest degradation for a user who deliberately wrote a paragraph, and it is the only path where per-line justification is abandoned. Detect it **by the fitter reporting failure**, never by a character count — a character count is wrong at every text scale.

Never clip, never ellipsise, never `TextOverflow.fade`, never `FittedBox` below the floor. The words are the product; a truncated sentence in a stranger's face is a total failure of the screen.

Keep the fitter behind a seam so the known-risk fallback stays cheap: **uniform setting at the longest line's fitted size**. (Varying line size is typographic emphasis, and emphasis is semantic — a stranger may read the biggest line as the stressed line. Unmeasured. Do not pre-emptively cap the size ratio between lines to hedge.)

### Out of scope

- The fitter itself — break enumeration, scoring, the `TextPainter` probe (E06-T01).
- The control on the board that enters show mode.
- The settings UI for `Show screen: bright · match my theme` and for the standing-line text. This screen **reads** those values with defaults `bright` / ON / the default sentence; it does not build their editors.
- Widget and golden tests for this screen (E06-T03).

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] `grep -n 't\.ground\|t\.ink\b' lib/ui/show_text/show_text_screen.dart` returns nothing outside the `match my theme` branch.
- [ ] `grep -rn 'Color(0x' lib/ui/show_text/` is empty — every value comes from `AacTheme.of(context)`.
- [ ] Pumping the screen under `AacPalette.ink` renders a `showGround` `#FFFCF7` background and `showInk` `#1A140D` type, not the dark palette's.
- [ ] A tap at each of the four corners, at the centre of the standing line, and on the type itself all pop the route — one `pump()`, no `pumpAndSettle()`.
- [ ] `expect(tester.binding.hasScheduledFrame, isFalse)` after a single `pump()` on entry: nothing animates.
- [ ] The exit target asserts with `isSemantics(button: true, label: ...)` — not `containsSemantics`.
- [ ] `find.byType(AppBar)`, `find.byType(IconButton)`, `find.byType(Icon)`, `find.byType(BackButton)` all find nothing on this screen.
- [ ] With the standing line off or empty, the fitter's height budget equals the full column height minus margins; with it on, the budget shrinks by the standing line's *rendered* height at the active `textScaler`.
- [ ] `grep -rn 'withClampedTextScaling\|textScaleFactor\|FittedBox\|AutoSizeText\|TextOverflow' lib/ui/show_text/` is empty.
- [ ] A phrase long enough to defeat the 32pt floor renders as a uniform-32pt scrollable block, with no character-count check anywhere in the file.
- [ ] `grep -rn 'Animated\|Duration\|Curve\|Tween\|Hero\|PageRouteBuilder' lib/ui/show_text/` is empty.

## Traps

- **`t.ground` / `t.ink` autocomplete first.** They are the fields you type everywhere else in the app, they compile, and they look right in the light palette — the bug only appears for a user whose theme is `ink`, i.e. most users, in front of a stranger. `showGround`/`showInk`/`showStandingLine` or nothing.
- **Reading the poster colours from the wrong place under `match my theme`.** That branch is the *only* condition under which show mode is not `#FFFCF7`. Wire it as a single explicit branch at the top of `build`, not as a sprinkle of ternaries at each colour site — the latter is how one of them ends up inverted and no test notices.
- **A close button "as well as" the tap-anywhere.** It always seems free. It is not: it is chrome the fit algorithm then reserves space for, and it teaches the wrong exit to a user who will next need it with the screen facing away.
- **Putting the `GestureDetector` inside the scroll view on the degraded path.** It then covers only the content extent, and the overscroll area becomes a dead zone on the exact screen that must have none. Wrap the scroll view, not its child.
- **`PopScope(canPop: false)` to "confirm" the exit.** There is nothing to confirm. Blocking system back removes one of the two exits.
- **Passing the full viewport height to the fitter.** The standing line's height must come out of the budget first, and it must be *measured*, not assumed to be 18dp — at 200% text scale it is roughly double and may wrap to two lines, and the assumed version silently pushes the last line of the phrase off the bottom.
- **Measuring `measure` against different constraints than you paint in.** `measure` is the column width — viewport width − 48. If a `SafeArea` or extra padding is applied *outside* the `LayoutBuilder`, the fitter solves for a width the text is never given and the "flush both margins" edge quietly lies. Compute the fit from the same constraints the poster paints in.
- **`boldText` and w500.** The general rule is that hardcoded weight throws the platform setting away. Show mode is the deliberate exemption and the specific rule wins: bold at 100pt closes the counters, and counter size is a real legibility factor — w500 at poster scale is both prettier and more legible. Write the exemption in a comment naming the reason, or a reviewer applying `reed-a11y-coding` correctly will "fix" it to w700.
- **`FittedBox` / `AutoSizeText` / a uniform fit "since it's simpler".** They all solve for the longest line and throw every other line away. That deletes the feature the screen exists for and it does it silently — the screen still renders text.
- **Detecting the degraded path by `says.length`.** Wrong at every text scale, in landscape, and on the dyslexia font. The fitter failing to seat a candidate is the only signal.
- **A "quick 80ms fade" on entry, or a `fullscreenDialog` route.** Both are transitions. The flash is the decision, and the setting is its escape hatch.

## Files

- **Creates:** `lib/ui/show_text/show_text_screen.dart`
- **Reads:** the fitter from E06-T01; `AacTheme.of(context)` (`showGround`, `showInk`, `showStandingLine`); the settings provider for `Show screen: bright · match my theme`, the standing-line text, and the OpenDyslexic option.
- **May touch:** `lib/ui/core/tokens.dart` only if a `standing` type role is not yet defined — nothing else.

## Done when

A phrase pushed from any palette paints as warm-light, chrome-free, per-line-justified poster type above which the standing line sits, exits from a tap on any pixel or the system back gesture, and degrades to a scrollable 32pt block rather than shrinking below legibility.
