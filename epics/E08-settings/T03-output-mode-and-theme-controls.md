# E08-T03 — Output mode and theme controls

| | |
|---|---|
| **Epic** | E08 — Settings |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E02-T03, E08-T01 |
| **Blocks** | Nothing |

**Skills:** `reed-theming-code` · `reed-copy-voice` · `reed-riverpod-usage`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Some people cannot make sound in the room they are in — a meeting, a waiting room, a house with someone in it they do not want to alert. Some people cannot hold a phone up to a stranger's face. Output mode is which of those two the user is living in right now, and it is theirs to choose: speak, show, or both. And the theme control is the escape hatch for a user whose astigmatism or light sensitivity makes the current palette unreadable — if reaching it requires reading three screens of a settings tree, it is unreachable by exactly the person who needs it.

## Scope

### 1. Output mode — a remembered choice, three first-class values

`OutputMode { speak, show, both }`, an enum beside the settings model E08-T01 defines in `lib/data/settings_repository.dart`, persisted into the same versioned JSON settings file as the palette. Default `speak`.

**Both are first-class; neither is a fallback.** `show` is a chosen mode, not the error path. Do not implement `show` as "speak failed, therefore show", and do not implement `both` as "speak, and show only if speech throws". They are three independent settings values that a downstream surface reads. That every speech failure *also* puts the words on screen in large type is a separate, unconditional guarantee that holds in all three modes — it is not what `show` means.

**Never auto-speak.** Selecting an output mode never speaks a preview. Nothing in this task calls `SpeechService.speak`. The only thing that produces sound in Reed is a user tapping a tile or the speak affordance on the compose field.

The control is names-first, at the settings register:

```
Output: speak · show · both
```

Three options, one selected, no modal. `semanticLabel` on the selected state is a sentence a screen reader speaks: `'Output: both. Speaks aloud and shows the words.'` — sentence case there is correct even though the visible chrome is lowercase.

An unknown or corrupt persisted value falls back to `OutputMode.speak` explicitly and visibly — never to a null that a consumer dereferences on a device with no debugger attached, and never to a throw.

### 2. High contrast polarity — a set-once settings preference

`hcInk` (default) / `hcPaper`. This is a settings preference precisely so it is **not** a fourth position on the main-screen cycle: a shutdown user needs one tap to produce one predictable next state, and four positions makes the switcher a puzzle at the worst possible moment.

```
High contrast: dark · light
```

Behaviour, and it is exact:

- Changing polarity while the effective palette is **not** HC stores the value and changes nothing on screen. It takes effect the next time the user cycles into high contrast.
- Changing polarity while the effective palette **is** HC applies immediately — `hcInk` becomes `hcPaper` on the same frame, with no animation and no scheduled frame afterwards.

`MediaQuery.highContrastOf` may be read opportunistically to nudge the *initial* default and nothing else. It is iOS-only and always false on Android (`dart:ui`'s `AccessibilityFeatures.highContrast` documents *"Only supported on iOS"*), so a branch gated on it is dead code on the target platform:

```dart
// RIGHT — the user's explicit choice wins; the platform flag can only nudge
// the initial default, and only where the platform actually reports it.
final AacPalette effective = savedPalette
    ?? (MediaQuery.highContrastOf(context) ? hcPolarityPref : AacPalette.ink);
```

### 3. The theme control stays one tap from the board

E02-T03 built the three-position switcher (`paper → ink → high contrast → paper`) and it lives on the board screen. This task must not move it, wrap it in a route, or replace it with a "Theme" settings row. Settings may *also* host an instance of the same widget reading the same state — that is fine and costs nothing — but the board-screen control is non-negotiable and a test pins it there.

Its copy shows the **current** palette and cycles on tap:

```
theme: ink
```

with `semanticLabel: 'Theme: ink. Tap to change.'` Both `hcInk` and `hcPaper` display as `high contrast` — polarity is not in the label, because the label names the cycle position.

Author the lowercase in the string table. **Never `.toLowerCase()`** — a transform in a widget survives into a code path that eventually renders a user's phrase, and then Reed lowercases someone's name. No lint catches that day and no telemetry reports it.

### 4. Show-screen brightness

```
Show screen: bright · match my theme
```

Ship the control and persist the value in the same settings file, same corrupt-value discipline (fall back to `bright`). The show screen's consumption of it is not this task.

### 5. State — no new providers

Output mode, HC polarity and show-screen brightness are **fields on the settings state E08-T01 already exposes**, not three new providers. Provider count going up is a smell, not progress. No `StateProvider`, no `family`, no `@riverpod` codegen.

Read with `ref.watch` in `build()`; write with `ref.read(settingsProvider.notifier)` inside `onTap`. **Notifier methods return `void`:**

```dart
// VOID, deliberately. Do not "improve" this to return a Future.
// `onTap: () => notifier.setOutputMode(m)` is flagged by NEITHER discarded_futures
// NOR unawaited_futures — the arrow closure "returns" the Future so the lint thinks
// it is handled, but the target type is VoidCallback, so the Future AND ITS ERROR
// are dropped. That is the silence bug, and no lint in the ecosystem catches it.
void setOutputMode(OutputMode m) { ... }
void cycleTheme() { ... }
```

The write-to-disk is `unawaited(...)` with a `.catchError` that logs and surfaces inline. A failed write does **not** revert the in-memory state: a state that appears then reverts is a visual change the user did not cause, which the animation ban forbids.

`cycleTheme()` resolves the current palette **inside the method** via `ref.read`. Never capture the watched palette from `build()` into the tap closure.

### Out of scope

- The board's and compose field's behaviour under each output mode.
- The show screen itself.
- Any hex, any contrast verification, any new token.
- The settings screen scaffold, the settings file format and its versioning (E08-T01).
- `dynamic_color`, `DynamicColorBuilder`, `CorePalette.of`, `shared_preferences`. Permanently rejected.

## Acceptance criteria

- [ ] A widget test pumps `BoardScreen` with no navigation and finds the theme control: `expect(find.bySemanticsLabel(RegExp(r'^Theme: ')), findsOneWidget)`.
- [ ] A widget test asserts the visible label is `theme: paper` / `theme: ink` / `theme: high contrast`, and that `hcInk` and `hcPaper` both render `high contrast`.
- [ ] A widget test asserts the semantic label is exactly `Theme: ink. Tap to change.` when the palette is `ink`.
- [ ] A widget test selects each of `speak`, `show`, `both`, then cycles the theme three times, and asserts `FakeSpeechService` recorded **zero** speak calls.
- [ ] A test asserts the default output mode is `OutputMode.speak` on a settings file that has never been written.
- [ ] A round-trip test: set `OutputMode.both`, reconstruct the repository over the same file, assert `OutputMode.both`.
- [ ] A test feeds a corrupt/unknown output-mode string and asserts the result is `OutputMode.speak` — not null, not a throw. Same test for show-screen brightness → `bright`.
- [ ] A widget test with palette `paper` sets HC polarity to `light` and asserts the effective palette is still `paper`; it then taps the theme control twice and asserts `hcPaper`.
- [ ] A widget test with palette `hcInk` sets HC polarity to `light` and asserts `hcPaper` after a single `pump()` — never `pumpAndSettle()` — with `expect(tester.binding.hasScheduledFrame, isFalse)`.
- [ ] A widget test with `highContrast: true` in `MediaQueryData` and a saved palette of `paper` renders `paper`: the platform flag never overrides an explicit choice.
- [ ] `! grep -rn 'toUpperCase(\|toLowerCase(' lib/ui/settings/ lib/ui/board/` passes.
- [ ] `! grep -rn 'showDialog\|showModalBottomSheet' lib/` passes — errors and choices are inline and non-blocking.
- [ ] `! grep -rniE 'caregiver|parent|guardian|student|learner|sorry|oops|please|\bwe |just |simply' lib/ui/settings/` passes, and no user-facing literal in the diff contains `!` or a straight `'`.
- [ ] `grep -rn 'StateProvider\|\.family\|@riverpod' lib/` returns nothing, and `lib/providers.dart` gained no new provider declaration.
- [ ] `dart analyze` is clean; `flutter test` is green.

## Traps

- **Implementing `show` as the speech-failure path.** It collapses a user's deliberate silent mode into an error state, and the first time speech succeeds in a quiet room the phone talks. `show` is chosen. The unconditional "every speech failure shows the words" guarantee is a *different* mechanism and must not be folded into this enum.
- **Previewing the mode.** A segmented control that speaks "both" when you tap `both` is the app making noise the user did not ask for, in settings, which is where they went to stop it making noise.
- **A modal for the picker.** `showDialog` / `showModalBottomSheet` demands a decision from someone whose decision-making is exactly what is impaired, and blocks the screen. Inline, always.
- **A Future-returning notifier method behind `onTap: () => notifier.setOutputMode(m)`.** `discarded_futures` and `unawaited_futures` both stay silent — the arrow closure looks like it returns the Future, but the target type is `VoidCallback`, so the Future and its error vanish. The setting silently fails to persist and is gone on restart, with no error anywhere. Void-returning methods make the hole unreachable by construction.
- **Capturing the watched palette in `build()` and computing `next` in the closure.** A rebuild between build and tap means the cycle steps from a stale position — the tap appears to go backwards. Resolve current inside `cycleTheme()` with `ref.read`.
- **Reverting the in-memory value when the disk write fails.** The user sees their choice appear and then undo itself: a visual change they did not cause, at the exact moment they were trying to assert control. Keep the state, log the diagnostic, surface an inline line that states the fact and the next action.
- **`shared_preferences` for these three values.** Its read is async and lands after first paint, so the app boots on the default and the palette flashes a frame later — precisely the sudden large luminance change the animation ban exists to prevent, delivered to someone mid-shutdown. And its native storage fails silently rather than loudly.
- **Adding polarity as a fourth switcher position** because it "feels more discoverable". It turns the one control a shutdown user needs into a puzzle.
- **Polarity changes jumping the user into high contrast.** Setting `light` while on `paper` must change nothing on screen. A settings row that silently repaints the whole app is an accommodation being applied without consent.
- **Gating anything on `MediaQuery.highContrastOf`.** Always false on Android. The branch is dead code, HC becomes unreachable for every real user, and the tester on an iPhone never sees it.
- **Routing `highContrast` / `boldText` / `textScaler` through the settings provider** to make the settings screen "consistent". One frame of staleness in the one area where being wrong is total failure, in exchange for losing a compiler-guaranteed rebuild. App state via Riverpod; platform/a11y state via `BuildContext`.
- **Three new providers, one per setting.** They are fields on one state object. The moment `family` is typed, the argument that Riverpod was cheap has been lost.
- **`.toUpperCase()` on the mode names** because a segmented control "looks better" that way. `SPEAK` is fine; the transform is not, because transforms are rules about all text and text includes the user's phrases.
- **Prompting the accommodation.** "Text is large. Switch to show mode?" is the app noticing something about the user and offering to help — the parental posture in indie clothes. Ship the control, visible from install, and let them find it.
- **A null returned from the settings loader for an unknown enum name.** It defers the crash to a consumer, on a device with no debugger and no telemetry. Fall back explicitly: `speak`, `bright`, `ink`.
- **`pumpAndSettle()` in any of these tests.** It waits out animations that must not exist, carries a 10-minute default timeout, and truncates its stack trace — converting a real animation bug into flake with an unreadable failure.

## Files

- `lib/data/settings_repository.dart` — `OutputMode`, the HC polarity and show-screen-brightness fields, their defaults and their corrupt-value fallbacks.
- `lib/providers.dart` — the settings `Notifier` gains `setOutputMode`, `setHcPolarity`, `setShowScreenBrightness`, `cycleTheme`; all `void`. No new provider.
- `lib/ui/settings/settings_screen.dart` — the three inline controls and their copy.
- `lib/ui/board/board_screen.dart` — unchanged except that a test now pins the theme control's presence here.
- `test/data/settings_repository_test.dart` — defaults, round-trip, corrupt-value fallbacks.
- `test/ui/settings/settings_screen_test.dart` — the controls, the copy, the zero-speak assertion, polarity behaviour in and out of HC.
- `test/ui/board/board_screen_test.dart` — the theme control is reachable with zero navigation.

## Done when

`flutter test` is green, the copy and transform greps return nothing, and a user can reach high contrast in one tap from the board while `speak`, `show` and `both` each survive a restart without the app ever having made a sound nobody asked for.
