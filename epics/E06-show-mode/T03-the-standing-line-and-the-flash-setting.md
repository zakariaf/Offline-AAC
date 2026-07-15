# E06-T03 — The standing line and the flash setting

| | |
|---|---|
| **Epic** | E06 — Show mode |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E06-T02 |
| **Blocks** | Nothing |

**Skills:** `reed-show-screen` · `reed-copy-voice` · `reed-motion-policy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

The enemy is being misread, not being unseen. A phone held up at a cashier saying **Thank you** in 140pt type reads as *weird* — a stranger spends their two seconds deciding whether something is wrong with the person, not reading the words. The same phone with `I can’t speak right now. I can hear you.` sitting above it reads instantly, and the user is a competent adult with a temporary problem. This one line — not the fitter, not the typeface — is the design investment show mode actually needs. The flash setting exists for the same reason in the other direction: entering show mode from the `ink` palette jumps L 0.19 → 0.98 in one frame, that is a deliberate un-ramped decision, and a decision made on judgment ships with an escape hatch rather than an argument.

## Scope

Two things, both on top of the fitter E06-T02 built: the standing line, and the `Show screen: bright · match my theme` setting.

### The standing line

Above the poster, at the top margin (24dp), start-aligned. The `standing` type role: **18pt / w500 / tracking 0 / height 1.30**, colour `showStandingLine` = `#5A544E` (7.29:1 / Lc +84.3 on `#FFFCF7`).

- Read the colour from `AacTheme.of(context).showStandingLine`. Never a literal, never `t.inkDim` on the bright path.
- Alignment is `TextAlign.start` with `EdgeInsetsDirectional`, never `.left` / `EdgeInsets` — show mode mirrors in RTL.
- **It does not participate in the fitting algorithm.** It is fixed at 18pt, and its laid-out height (plus the gap below it) is **subtracted from the height budget the fitter scores candidates against**. Never scale it, never justify it, never let it wrap to a second line's worth of visual weight and compete with the phrase.
- It is inside the full-bleed `GestureDetector` (`behavior: HitTestBehavior.opaque`). There is no dead zone: tapping the standing line exits show mode like tapping anywhere else.
- Empty string ⇒ the widget is not built at all, and the fitter gets the full height budget back. Not a zero-height `SizedBox`, not an empty `Text` occupying a line box.

Default text, exactly, with a real apostrophe:

```dart
// lib/ui/strings.dart
const defaultStandingLine = 'I can’t speak right now. I can hear you.';
```

**Default ON.** User-editable in settings, **including empty** — an empty standing line is a valid choice, not an invalid input. The editor never refuses it, never re-fills it with the default, never shows a "this is recommended" nudge.

### The two new settings keys

The `settings` table is plain K/V precisely so preference #8 is an insert, not a migration. Add three keys through `SettingsRepository` (`lib/data/settings_repository.dart`), following its existing rules verbatim — key strings do not leave that file, enums persist by `.name` never index, parsing is **total** (missing row, `''`, `'NaN'`, `'2'` all resolve to the documented default and log the offending value to the on-device diagnostic log):

| key | type | default |
|---|---|---|
| `standing_line_enabled` | `'true'` / `'false'`, parsed with an explicit `== 'true'` | `true` |
| `standing_line_text` | `String` | `defaultStandingLine` |
| `show_polarity` | `ShowPolarity { bright, matchTheme }`, stored as `.name` | `bright` |

Missing `standing_line_text` row ⇒ `defaultStandingLine`. A **present** row holding `''` ⇒ empty, honoured. Those are two different states and the repository must not collapse them — `?? defaultStandingLine` on a non-null empty string silently overwrites a deliberate choice.

The text is a user string. **Never transform it.** No trimming, no capitalising the first letter, no appending a period, no lowercasing. Straight-to-curly normalisation on save is the one sanctioned edit, and only on save — never mid-typing.

### The flash, and the escape hatch

**It flashes. Instantly. No ramp.** No fade, no `AnimatedContainer`, no `Color.lerp`, no `PageRouteBuilder` transition, no `AnimatedSwitcher`, no "quick 80ms" anything. The user deliberately pressed a control and is turning the phone away from their own face at that moment — that *is* the mitigation. A ramp is *longer* exposure to the transition and costs latency in the one moment where latency has a social cost.

This is design judgment, not evidence. It ships with a setting, not an argument:

```
Show screen: bright · match my theme
```

- `bright` (default): `showGround` `#FFFCF7`, `showInk` `#1A140D`, `showStandingLine` `#5A544E`, regardless of the active palette.
- `matchTheme`: the **only** condition under which show mode is not `#FFFCF7`. Ground `t.ground`, ink `t.ink`, standing line `t.inkDim` — all from `AacTheme.of(context)`, all already walked by the contrast gate per palette. The user pays the stranger-legibility cost knowingly. That is their call.

Everything else about the poster is unchanged between the two: same fitter, same clamp, same margins, same w500, same exit. Polarity is the only variable.

`matchTheme` is not a "gentler flash" and must not be implemented as one. The route into show mode has no transition under either setting — the theme-root `pageTransitionsTheme` already guarantees that; do not add a local `PageRoute` that re-introduces one.

### The settings controls

Three controls, authored lowercase in the string table, never a text transform (`.toLowerCase()` in a widget eventually lowercases a user's phrase, and no lint catches that day):

- `Show screen: bright · match my theme` — a two-value segmented control, no prose caption.
- `Standing line` — on/off, default on.
- The text field for `standing_line_text`, pre-filled with the current value. No character cap. No placeholder that reads as an instruction.

No question copy, no "Tip:", no exclamation marks, no "we", no praise, no narration of why the user might want this. Names first, prose only where a name is insufficient. Never prompt the accommodation — do not detect the `ink` palette and offer `match my theme`; ship the setting, visible from install, and let them find it.

### Out of scope

- The fitter itself, the break search, the 32–140pt clamp, the scroll degradation at the 32pt floor — E06-T02.
- The settings **screen** scaffolding, its route and its layout. This task contributes the three controls to it; it does not build it.
- Screen brightness. **v1 does not touch it.** 17.85:1 suffices at typical brightness, and a brightness plugin is a native dependency and another sensory event.
- Any per-phrase standing line. There is one line, global.
- Any localisation of `defaultStandingLine` beyond the shipped English literal.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] `grep -rn "AnimatedContainer\|AnimatedOpacity\|AnimatedSwitcher\|Tween\|CurvedAnimation\|Color.lerp\|Duration(" lib/ui/show/` returns nothing.
- [ ] `grep -rn "0xFFFFFCF7\|0xFF1A140D\|0xFF5A544E" lib/ --include='*.dart'` matches only the tokens file.
- [ ] `grep -rn "toUpperCase(\|toLowerCase(" lib/ui/show/ lib/ui/settings/` returns nothing.
- [ ] `grep -rn "standing_line_enabled\|standing_line_text\|show_polarity" lib/ --include='*.dart'` matches only `lib/data/settings_repository.dart`.
- [ ] Test: `defaultStandingLine` contains `’` (U+2019) and not `'` — assert on the code unit, not by eye.
- [ ] Test: default settings ⇒ the standing line renders, `findsOneWidget`, text equal to `defaultStandingLine`.
- [ ] Test: `standing_line_text = ''` (row present, value empty) ⇒ **no** standing-line widget in the tree, and the fitted size of a fixed reference phrase is **strictly greater** than with the default line present. This is the assertion that proves the height budget is actually being returned.
- [ ] Test: `standing_line_enabled = 'false'` ⇒ no standing-line widget, same budget behaviour as empty.
- [ ] Test: a missing `standing_line_text` row ⇒ `defaultStandingLine`; a present empty row ⇒ `''`. Two distinct cases, both asserted.
- [ ] Test: garbage `show_polarity` (`''`, `'2'`, `'Bright '`) ⇒ `ShowPolarity.bright`, throws nothing.
- [ ] Test: `setShowPolarity(ShowPolarity.matchTheme)` writes the literal string `'matchTheme'` — assert the raw column value, not the round trip.
- [ ] Test: with `bright` and the `ink` palette active, the poster's background is `showGround`; with `matchTheme` and the `ink` palette active, it is `t.ground`. Both assert against `AacTheme.of(context)` values, not literals.
- [ ] Test: entering show mode, then a single `await tester.pump()` ⇒ `expect(tester.binding.hasScheduledFrame, isFalse)`. No `pumpAndSettle` anywhere in the file.
- [ ] Test: `tester.tap` on the standing line's text exits show mode. It is exit surface, not a dead zone.
- [ ] Test at `textScaler` 2.0: the standing line is still one line's worth of role (18pt × scale), the poster still fits or degrades to the 32pt scroll, and nothing overflows.
- [ ] Golden: bright + default standing line, and bright + empty standing line, at the same phrase — visibly different type sizes.

## Traps

- **Letting the standing line into the fitter.** If it is laid out inside the same `LayoutBuilder` column without its height being subtracted from the budget first, the fitter seats a candidate that then overflows by exactly the standing line's height — and the poster is clipped in a stranger's face. Measure it, subtract it, then score.
- **`?? defaultStandingLine` on the parsed value.** A present-but-empty row is a deliberate choice. Coalescing null-or-empty into the default silently overwrites it, the user re-clears it, it comes back, and they conclude the app does not do what they told it. Distinguish *absent* from *empty*.
- **Reserving space for the line when it is off.** An empty `Text('')` or a `SizedBox(height: 0)` inside a `Column` still contributes a line box or a slot the fitter must account for. Do not build the widget.
- **`t.ground` / `t.ink` on the bright path.** They invert with the palette and would hand a stranger a dark screen in daylight. On `bright`, read `showGround` / `showInk` / `showStandingLine` only. They are theme fields — not constants — because the contrast gate walks them per palette; that is not permission to substitute the palette's own roles.
- **`showStandingLine` on the `matchTheme` path.** `#5A544E` is verified at 7.29:1 / Lc +84.3 **on `#FFFCF7`**. On the `ink` palette's ground that number is meaningless and the line may be near-invisible. Use `t.inkDim`, which the gate already walks per palette.
- **Compromise-ramping the flash.** A 120ms `AnimatedContainer` "for the people who can't take it" ships a worse product to everyone: it is longer exposure to the luminance change, plus latency in the moment latency costs socially, and it does not actually serve the user it was added for — they needed `matchTheme`. Ship the setting; do not ship the ramp instead of it.
- **Citing evidence for the no-ramp decision.** Do not write a comment claiming instant is empirically optimal. The commonly-cited latency work measured feedback onset and never tested a no-animation condition. Argue it from latency, which is arithmetic, and from judgment about this audience, which is defensible on its own. Laundered evidence gets fact-checked and reopens the whole ban.
- **Prompting the accommodation.** "Dark theme detected — switch show screen to match my theme?" is the app noticing something about the user and offering to help. That is the parental posture in indie clothes. The setting is visible from install; that is the whole mechanism.
- **`.toLowerCase()` to render the chrome.** A transform is a rule about all text, and text includes people. Author `Standing line` and `Show screen: bright · match my theme` as literals.
- **A terminal period ban applied to the standing line.** The no-terminal-period rule is about *labels*. The standing line is a genuine sentence — two of them — and takes normal punctuation, including the final period. Do not strip it.
- **A `maxLength` on the standing-line field.** The 16-character cap belongs to `label`. The standing line is uncapped. Capping it silently truncates someone's frame-control sentence.
- **A confirmation step on clearing the line.** No "are you sure", no modal. A modal during a shutdown demands a decision from someone whose decision-making is impaired.

## Files

- `lib/ui/show/show_text_screen.dart` — changed. Standing line widget, height budget subtraction, polarity branch.
- `lib/ui/strings.dart` — changed. `defaultStandingLine`, the two settings control labels.
- `lib/data/settings_repository.dart` — changed. Three keys, `ShowPolarity` enum, total parsers, setters.
- `lib/ui/settings/` — changed. The three controls.
- `test/ui/show/standing_line_test.dart` — new.
- `test/data/settings_repository_test.dart` — changed. Cases for the three keys.
- `test/goldens/` — new goldens for line-present and line-absent.

## Done when

A stranger looking at the phone reads `I can’t speak right now. I can hear you.` above the phrase, the line can be edited to anything including nothing and the poster grows to fill the space it gave back, and a user who cannot tolerate the flash sets `Show screen: match my theme` and gets their own palette at full size with no ramp anywhere in the code.
