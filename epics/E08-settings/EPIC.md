# E08 — Settings

> One flat screen, no tree, no dialog: a voice picker that speaks before it commits, output mode, theme, and haptics — every control a statement of what it does, reachable in one tap from the grid.

| | |
|---|---|
| **Status** | Not started |
| **Tasks** | 4 |
| **Depends on** | E03 (`SettingsRepository` and `settingsProvider` — E03-T03), E02 (theme wiring and the palette switcher — E02-T03), E04 (the voice filter — E04-T02) |

## Why this epic exists

Voice quality is a top-two obstacle to continued use of AAC, and a voice is not a preference row — it is the sound of a person. Someone who goes non-speaking part-time is choosing what they sound like to a cashier, a nurse, a partner. A picker that lists twenty names and no way to hear them is asking an adult to choose their voice from a spelling.

The screen has a second, harder job. It is the one surface in Reed a user may open *while* they are in trouble: the voice vanished, the phone is silent, and the error string they just read said `Pick one in settings.` So settings must behave like the grid does — flat, still, tap-and-done. A nested tree, an expanding section, a modal confirm, or a "are you sure" is a decision demanded from someone whose decision-making is exactly what is impaired. **No modal dialogs, ever** is not a style rule in this epic; it is the requirement.

Getting it wrong is quiet in the usual way. A voice row that stores an id without ever synthesising a syllable ships a board that is silent for one person and fine for everyone else, and nobody will file that bug — a user who cannot speak does not file bugs, and there is no telemetry. A `ListTile` dropped in because it is what settings screens are made of brings a 200ms ink highlight into the app that animates nothing.

## What "done" means

- `flutter analyze` is clean and `flutter test` is green.
- The grid's `settings` control opens a single scrollable list. `grep -rn 'showDialog\|AlertDialog\|SimpleDialog\|BottomSheet' lib/ui/settings/` returns nothing. There is no second settings level.
- `grep -rn 'InkWell\|InkResponse\|ListTile\|Animated' lib/ui/settings/` returns nothing.
- `grep -rn "'theme'\|'grid_size'\|'voice_id'\|'output_mode'\|'haptics'" lib/ui/` returns nothing — every read and write goes through `SettingsRepository`, which owns the key strings and the string↔typed boundary.
- Every row is a `Semantics(button: true, label: …)` node asserted with `isSemantics(...)`; the theme row's label is `'Theme: ink. Tap to change.'` and it names the **current** palette.
- The screen renders at `TextScaler.linear(2.0)` with no overflow, and `grep -rn 'withClampedTextScaling\|textScaleFactor\|FittedBox\|TextOverflow.ellipsis' lib/ui/settings/` returns nothing.
- `hasScheduledFrame` is false after one `pump()` following a tap on every row. Tests use `pump()`; `pumpAndSettle` appears nowhere.
- The voice picker lists only voices `SpeechService.voices()` returned — nothing `networkRequired`, nothing carrying `notInstalled`. Tapping a voice speaks a sample through the same `speak()` path the tiles use and handles the returned `SpeakOutcome` exhaustively; a failure puts the words on screen.
- With zero offline-safe voices on the device, the picker states the fact and the next action in words. An empty list widget is a failure of this criterion.
- Every visible string passes a grep for `!` · `.toUpperCase(` · `.toLowerCase(` · `'` · `caregiver` · `parent` · `student` · `Sorry` · `Oops` · `we ` · `just ` · `Please`.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E08-T01 | The settings screen | S | E03-T03 |
| E08-T02 | The voice picker | M | E08-T01, E04-T02 |
| E08-T03 | Output mode and theme controls | S | E08-T01, E02-T03 |
| E08-T04 | Haptics and the low-stimulus mode | S | E08-T01 |

**E08-T01 — The settings screen** builds the container the other three fill: a route with no transition, a flat list of rows, and the read/write wiring to `settingsProvider` and `settingsRepositoryProvider`. It is an S because it invents nothing — `ReedSettings` and its `const ReedSettings.defaults()` already exist, already parse totally, and are already restored before first paint. The task's real content is the row idiom: an extracted `StatelessWidget`, `GestureDetector` with `HitTestBehavior.opaque`, `Semantics(button: true)`, a label that states the control and its current value (`Tiles: 12 · 6`, `Keep my board off cloud backup`), and `ref.read` in the callback — never a value captured out of `build()`.

**E08-T02 — The voice picker** is the epic. It reads `SpeechService.voices()` — already filtered, so nothing on the list needs the network and nothing is half-downloaded — and makes each row **audible before it is chosen**: tap speaks a sample in that voice, and the selection is committed by the same tap. It is an M for three reasons that are all invisible when wrong: the sample must go through the real `speak()` path so a voice that reports success and produces nothing is caught by the same machinery the grid has; the returned `SpeakOutcome` must be switched exhaustively with no `default:` and no `case _:`; and the stored `voice_id` can name a voice Android has since garbage-collected, so this screen is where a dangling id gets re-resolved and replaced rather than discovered at tap time during a shutdown. `pitch` and `rate` live here too, beside the preview — a rate slider with nothing to listen to is a number, not a control.

**E08-T03 — Output mode and theme controls** ships two rows over machinery E02-T03 already built. The theme row shows the current palette and cycles on tap — `paper → ink → high contrast → paper`, three positions and not four, with HC polarity a set-once preference defaulting to `ink`. Output mode persists `enum.name` through `SettingsRepository`; the member set belongs to the speech and show-screen work and is not invented here. It is an S precisely because the switcher, the persistence, and the before-first-paint restore are all done — the risk is a well-meaning addition, not missing code.

**E08-T04 — Haptics and the low-stimulus mode** ships the `haptics` toggle and then settles the question its own title raises. There is no low-stimulus mode, because Reed is already it: nothing animates, nothing fades, nothing appears or vanishes on its own, and there is no notification, no sound, no badge to suppress. A mode would be a second appearance to golden-test in four palettes and would advertise that the default is not already calm. The two stimulus channels that genuinely exist are each already a control: the haptic, toggled here, and the show-mode luminance jump, which is E06-T03's `Show screen: bright · match my theme`. The task's job is the toggle, the wiring that makes `HapticFeedback.selectionClick` conditional at the tile's press, and a comment at the point of temptation saying why there is no third switch.

## Skills this epic draws on

**The screen and its rows**
- `reed-widget-conventions` — extract a widget, never a `_buildX` method; `GestureDetector` + `HitTestBehavior.opaque`, never `InkWell`; no long-press, no swipe, no `Dismissible` on a row.
- `reed-riverpod-usage` — `settingsProvider` / `settingsRepositoryProvider`; `ref.watch` in `build()`, `ref.read` in callbacks; no `StateProvider`, no `family`, no `@riverpod`; `ProviderContainer.test()` in tests.

**What the controls say**
- `reed-copy-voice` — lowercase chrome authored as literals (`theme`, `settings`), sentence case in semantic labels, curly apostrophes, names before prose, no apology, no "we", no exclamation mark, no modal, no prompted accommodation.

**The voice**
- `reed-speech-service` — `voices()` is pre-filtered; `speak()` returns a sealed `SpeakOutcome` and is `@useResult`; `setVoice` returns 1 for a `notInstalled` voice; the stored voice id is re-resolved against `voices()` and falls back audibly; warm-up fails silently, `speak()` fails loudly.

**Appearance and stillness**
- `reed-theming-code` — read `AacTheme.of(context)` and the M3 `ColorScheme` roles, never a literal, never `fromSeed`, never `dynamic_color`; the three-position cycle; restore before first paint; `highContrastOf` is iOS-only and may nudge a default, never gate one.
- `reed-motion-policy` — zero duration on every row; `pump()` not `pumpAndSettle()`; `hasScheduledFrame` false after a tap.

**Correctness**
- `reed-a11y-coding` — `Semantics(button: true, label: …)` on every row, `boldText` honoured, no clamp and no `FittedBox`, state never carried by colour alone, `isSemantics(...)` in the assertions.

## Sequencing

**E08-T01 is a hard gate on the other three**, and they then run in parallel — T02, T03 and T04 touch different rows of the same list and share nothing but the row idiom T01 establishes. This is the widest parallel fan in the plan; it is real, not padding.

T01 waits on **E03-T03** because a settings screen that reaches past `SettingsRepository` into drift is the exact leak the repository exists to prevent, and stubbing the repository would let the screen grow its own key strings and its own parsing.

T02's second dependency, **E04-T02**, is not a formality: without the voice filter the picker lists network-only and half-downloaded voices, and every one of them is a row a user can tap, select, and be silenced by. T03 waits on **E02-T03** for the same reason in the other direction — the cycle order, the HC polarity preference and the before-first-paint restore all live there, and a settings screen that reimplements them ships a second, divergent switcher.

Nothing in E08 blocks anything. That makes it easy to defer and expensive to defer: the error strings E04 and E06 already ship point at this screen (`Pick one in settings.`, `The previous board is in settings.`), so shipping those without it hands the user a signpost to a room that does not exist.

## Risks specific to this epic

- **The settings tree.** Every settings screen anyone has built has sections, sub-pages, and an expanding tile. Each one is a navigation decision for a person in sensory overload standing between them and their voice. Flat list, one level, no accordion. An expanding section is also self-caused change, which the motion policy forbids outright.
- **`ListTile` and `SwitchListTile`.** They are what a settings screen is made of everywhere else, and they are `InkWell`s. `NoSplash.splashFactory` at the theme root kills the *splash* only — `InkResponse.updateHighlight()` independently mounts a 200ms `InkHighlight`. The `hasScheduledFrame` assertion is the only thing that will catch it.
- **A voice picker with no audio.** The one bug that defeats the entire purpose of the epic: a list of names, a tap that writes `voice_id`, and the user discovers what they sound like in front of a stranger. Preview is the feature; the row is the packaging.
- **Previewing through a side door.** Calling `flutter_tts` directly, or a private `_previewSpeak`, bypasses the `setVoice != 1` check, the `notInstalled` guard and the timeout — so the picker becomes the one screen where a silent failure reports success. Preview through `SpeechService.speak()`, switch the outcome, show the words on failure.
- **Discarding the preview's `SpeakOutcome`.** `onTap: () => service.speak(sample)` is caught by **no lint** — the arrow closure "returns" the Future so `discarded_futures` is satisfied, but the target type is `VoidCallback`, so the Future and its error are dropped. Route it through a void-returning controller method, exactly as the tiles do.
- **A dangling `voice_id`.** Android garbage-collects voice data between launches. A picker that trusts the stored id and shows it as selected is showing a voice that is gone. Re-resolve against `voices()`; if it vanished, fall back audibly and let the row say what is actually selected now.
- **An empty list treated as a layout state.** Zero offline-safe voices is a real device state (`SpeechEnv.zeroVoices`, `onlyNetworkVoices`, `onlyNotInstalledVoices` all produce it). An empty `ListView` says nothing and offers nothing.
- **A confirm step.** "Change your voice?" is a question asked of someone who cannot answer questions right now, for an action that is one tap to undo. No confirms anywhere in this screen — and no content filter, no warning, and no "are you sure" on any phrase reachable from here.
- **A fourth switcher position.** Adding `hcPaper` as its own stop makes the theme control a four-state puzzle at the worst moment. HC polarity is a set-once preference; the cycle stays at three.
- **Gating high contrast on `MediaQuery.highContrastOf`.** It is documented "Only supported on iOS" and is **always false on Android**. That branch is dead code on the target platform, and it makes high contrast unreachable for every real user while reading as correct.
- **A prompted accommodation.** "Text is large. Switch to 6 tiles?" is the app noticing something about the user and offering help. Ship the control, visible from install, and say nothing.
- **The haptic bypassing the setting.** The toggle is only true if every `HapticFeedback` call site reads it. A tile that buzzes with haptics off is a sensory event the user explicitly declined, and the order at the tile stays haptic → `setState(lit)` → TTS.
- **`toUpperCase()` on a row label.** A text transform is a rule about all text, and the voice list contains names. Author `theme` lowercase in the string; never compute it.

## Out of scope

- **Persistence, parsing, defaults, and clamping** — E03-T03. `ReedSettings`, the seven keys, `enum.name` serialization, total parsing with a logged fallback, and the before-`runApp` load are done. This epic renders and writes; it does not decide storage.
- **The palettes, the tokens, the cycle, and the contrast gate** — E02. The theme row calls into machinery that already exists and is already proven across all four palettes.
- **Enumerating and filtering voices** — E04-T02 owns `offlineSafeVoices` and the four wire-format traps. The picker consumes a `List<Voice>` and asks no questions about `network_required`.
- **`Show screen: bright · match my theme` and the standing line** — E06-T03 contributes those two rows to this screen. It does not build the screen, and this epic does not build them.
- **The 2×3 layout itself** — E05. The `grid_size` preference persists in E03-T03 and surfaces as a row here; what a 2×3 board actually looks like is grid work.
- **`Keep my board off cloud backup`** — the row belongs on this screen, the `android:allowBackup` behaviour behind it is release work. The string stays blunt; it is a safety accommodation for a user whose adversary may hold their phone account, and euphemism costs them the control.
- **Onboarding, a tour, a tip strip, or a first-run pointer at settings.** The grid is twelve labelled rectangles and the chrome is words. There is no gate, no splash, and nothing to explain.
- **Anything named `parent`, `caregiver`, or `supervisor`** — not a section, not a class, not a doc comment. There is one user and they own the board.
