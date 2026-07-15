# E08-T04 — Haptics and the low-stimulus mode

| | |
|---|---|
| **Epic** | E08 — Settings |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E08-T01 |
| **Blocks** | Nothing |

**Skills:** `reed-motion-policy` · `reed-copy-voice` · `reed-riverpod-usage`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A tap that buzzes confirms itself without asking the user to hear the phone or read the screen — that matters when auditory processing has gone with the speech. But this audience is *selected* for sensory sensitivity, so the same pulse is an assault for the next person. Both are true, so the pulse ships on by default and comes off without hunting for it. The low-stimulus mode is the same shape at a larger scale: the need is state-dependent, it arrives in the middle of an episode, and the user must be the one who decides it arrived — this task ships the mode and **rejects the automation** that would guess it.

## Scope

Two independent controls. Neither one touches the other.

### 1. Haptics

One short pulse on tile activation. `HapticFeedback.selectionClick()` — the API E05-T04 already names in the lit-state ordering. Not `vibrate()`, not `heavyImpact()`, not a plugin.

The ordering is fixed by E05-T04 and is **dispatch order, not completion order**:

```dart
// lib/ui/board/phrase_tile.dart — inside Listener.onPointerDown
if (ref.read(settingsProvider).haptics) {
  unawaited(HapticFeedback.selectionClick());   // dispatch, never await
}
setState(() => _lit = true);
controller.speakSlot(slot.row, slot.col);
```

- `ref.read`, at press time, inside the callback — never a value captured out of `build()`.
- The `haptics` boolean is already a `ReedSettings` field and an existing `settings` k/v key (E03-T03). This task consumes it; it does not create it.
- The gate wraps **only** the pulse. Speech is outside the `if`, always.

**The control.** In `lib/ui/settings/settings_screen.dart`, a top-level row, no submenu, no dialog, no confirmation:

```
haptics: on          semanticLabel: 'Haptics: on. Tap to change.'
haptics: off         semanticLabel: 'Haptics: off. Tap to change.'
```

Same pattern as the theme control: lowercase chrome, current value shown, tap cycles. From the board it is `settings` → `haptics: on`. Two taps, zero navigation decisions, no scrolling to reach it — `haptics` and `low stimulus` are the **first two rows** of the settings surface, because they are the two a person reaches for while in the state that made them open it.

Tapping `haptics: on` while haptics are on fires no confirming pulse. The last thing someone turning haptics off should receive is a haptic.

### 2. Low stimulus

Three effects, and one of them is free:

| effect | mechanism |
|---|---|
| desaturate | `AacTheme.copyWith(usesStocks: false)` — every tile collapses to `ground` behind its keyline. The dyed stocks go. `copyWith` already exists and is mandatory on the extension. |
| fewer tiles | effective grid = `GridSize` 2×3. The 2×3 layout is an existing shipping layout; which slots it surfaces is grid work, not this task. |
| zero animation | **nothing to do.** Reed animates nothing, in every mode, always. This line exists so nobody implements it. |

**It derives; it never writes.** `lowStimulus` is its own state. It does **not** write `theme` and does **not** write `grid_size` — a mode that clobbers the settings it overrides hands back the wrong ones when it turns off, and a user whose standing preference was already 2×3 would be silently reset to 3×4 on the way out.

```dart
// pure, no provider — provider count going up is a smell, not progress
AacTheme effectiveTheme(AacTheme base, bool lowStimulus) =>
    lowStimulus ? base.copyWith(usesStocks: false) : base;

GridSize effectiveGridSize(ReedSettings s) =>
    s.lowStimulus ? GridSize.g2x3 : s.gridSize;
```

Consumed in `lib/ui/app.dart` (theme) and wherever the board reads its dimensions. No new provider. No `StateProvider`. No `family`.

**Persistence: yes.** `low_stimulus` becomes the **eighth** `settings` key, stored `'true'` / `'false'`, parsed with an explicit `== 'true'`, added to `ReedSettings` with a `setLowStimulus(bool)` on `SettingsRepository`. This is precisely the growth the k/v table exists for — preference #8 is an `insertOnConflictUpdate`, not a `TableMigration`, and `schemaVersion` does not move. E03-T03's "seven keys and only seven" becomes eight here and the count in that task is updated in the same commit.

State-dependent does not mean ephemeral. Someone in low stimulus whose app is killed by the OS must come back in low stimulus. Like `theme` and `grid_size`, it is loaded in `main()` before `runApp` and reaches the **first painted frame** synchronously — it changes both the palette and the tile count, so a late arrival is a reflow the user did not cause.

**The control:**

```
low stimulus: off    semanticLabel: 'Low stimulus: off. Tap to change.'
low stimulus: on     semanticLabel: 'Low stimulus: on. Tap to change.'
```

### The automation is rejected. Write this down in the code.

Nothing turns low stimulus on or off by itself. Not a heuristic on tap rate, not time of day, not a failed-speech counter, not a sensor, not `MediaQuery.disableAnimationsOf`, not a first-launch guess. Nothing prompts it either — no strip, no caption, no "Text is large. Switch to 6 tiles?". The app does not know what state anyone is in, and guessing at it out loud is the parental posture. Ship the control, visible from install, and let them find it.

Put a comment on `setLowStimulus` saying so, in those terms, so the next person to read it knows the absence is a decision and not an omission.

### Out of scope

- The settings screen shell, its layout, and every other row (E08-T01).
- The lit state, the 120ms hold, `Listener.onPointerDown` (E05-T04) — this task adds one gated line inside an ordering that already exists.
- Which six slots the 2×3 layout shows, and its ~180dp tile geometry — grid work.
- A ninth setting for haptic strength or pattern. On/off is the control.
- Low stimulus touching `haptics`. They are orthogonal: haptics may be the *only* channel left for someone in a low-stimulus state, and switching it off for them would be the app deciding on their behalf. Two rows, two decisions.
- Any change to `boards.grid_rows` / `boards.grid_cols`. Those remain the layout's bounds.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] `grep -rn "HapticFeedback" lib/` matches exactly one call site, in `lib/ui/board/phrase_tile.dart`, and it is `selectionClick`.
- [ ] `grep -rniE "VIBRATE|vibration|vibrate\(" lib/ android/ pubspec.yaml` returns nothing. No plugin, no manifest permission.
- [ ] `grep -rn "await HapticFeedback" lib/` returns nothing.
- [ ] `grep -rniE "autoDetect|shouldSuggest|suggestLowStimulus|overwhelm|calmMode|panicMode|detectShutdown" lib/` returns nothing.
- [ ] `grep -rn "disableAnimationsOf\|accessibleNavigationOf" lib/` returns nothing in the low-stimulus path.
- [ ] `grep -rn "StateProvider\|\.family\|@riverpod" lib/providers.dart` returns nothing, and `lib/providers.dart` gains **zero** lines from this task.
- [ ] Widget test: mock `SystemChannels.platform` via `tester.binding.defaultBinaryMessenger.setMockMethodCallHandler`; with `haptics: true`, one tile press logs exactly **one** call to method `'HapticFeedback.vibrate'` with argument `'HapticFeedbackType.selectionClick'`.
- [ ] Widget test: with `haptics: false`, that log is **empty** and `FakeSpeechService` still received the phrase. The silence guard — a gate that early-returns past `speakSlot` is the worst bug in the app.
- [ ] Widget test: against one shared call log, the haptic entry precedes the `FakeSpeechService.speak` entry.
- [ ] Widget test: tapping the `haptics: on` row logs zero platform haptic calls.
- [ ] Test: `setLowStimulus(true)` stores the literal string `'true'` in the `low_stimulus` row — assert the raw column value.
- [ ] Test: a fresh DB with no `low_stimulus` row ⇒ `ReedSettings.defaults().lowStimulus == false`, no throw. A garbage value (`''`, `'True '`, `'1'`) ⇒ `false`, logged, no throw.
- [ ] Test: `effectiveTheme(kInk, true).usesStocks == false` and `effectiveTheme(kInk, true).stock(Stock.tan) == kInk.ground` for all four `Stock` values; `effectiveTheme(kInk, false)` is `kInk` unchanged.
- [ ] Test: with `gridSize = GridSize.g2x3` stored, `setLowStimulus(true)` then `setLowStimulus(false)` leaves the raw `grid_size` row and the raw `theme` row **byte-identical** to before. The mode never writes what it overrides.
- [ ] Widget test: after `pump()` following a low-stimulus toggle, `tester.binding.hasScheduledFrame` is `false`. No `pumpAndSettle` anywhere in this task's tests.
- [ ] Golden or widget test: `low stimulus: on` renders 6 tiles, `off` renders the stored preference's count, in one frame each.
- [ ] Reading `lib/main.dart`: `low_stimulus` arrives via the same pre-`runApp` `load()`; there is no `AsyncValue` between `ProviderScope` and the first frame.
- [ ] Every string added: lowercase chrome, no `!`, no question, no "Sorry", no "just"/"simply", no "we". Semantic labels are exactly the four sentences above.
- [ ] All repository tests run against `NativeDatabase.memory()`. No test asserts that `ref.watch` propagates.

## Traps

- **`await HapticFeedback.selectionClick()` before `speakSlot`.** It is a platform-channel round-trip. Awaiting it inserts the channel latency into every spoken phrase, in an app whose entire premise is instant speech, and it is invisible on a fast simulator. Dispatch with `unawaited`; the ordering is the order the calls are *made*.
- **The dropped-Future hole.** `HapticFeedback.selectionClick()` returns a `Future`. Written bare inside a `VoidCallback` it is flagged by neither `discarded_futures` nor `unawaited_futures` — the arrow "returns" it, the target type swallows it. Use `unawaited(...)` explicitly so the intent is legible; do not let a `Future` sit unmarked in a tap path.
- **The gate swallowing the speech.** `if (!haptics) return;` at the top of the press handler is one keystroke away from correct and turns every tile into a dead rectangle for every user who turned haptics off. The `if` wraps one line.
- **Reading `haptics` out of `build()` into the closure.** A captured `ref.watch` value in an `onTap` is a preference frozen at the last rebuild — the user turns haptics off, walks back to the board, and it still buzzes. `ref.read` inside the callback.
- **Low stimulus writing `grid_size` or `theme`.** It looks like the simple implementation and it destroys the preference underneath. Turning the mode off then restores 3×4 over someone's standing 2×3. Derive; never write.
- **A duration branch.** `lowStimulus ? Duration.zero : const Duration(milliseconds: 150)` — the `else` arm is a policy violation that shipped. There is no motion to reduce in either mode. Delete the animation, not the flag check.
- **Crossfading the mode.** Twelve dyed chips fading to six grey ones is exactly the sudden unexpected change the ban exists to prevent, and the `ThemeExtension.lerp` step function makes it *worse* alone: the tiles snap at the midpoint while the `ColorScheme` around them crossfades. `themeAnimationStyle: AnimationStyle.noAnimation` is already at the root — do not add motion beneath it. The switch is one frame, and the user caused it.
- **`low_stimulus` arriving after the first frame.** The board paints 12 dyed tiles, then reflows to 6 grey ones. Every launch, for the person who is in this mode precisely because change is expensive right now. It loads in `main()` with `theme` and `grid_size` or it is broken.
- **Naming it `calm mode`, `panic mode`, `sensory mode`, `overwhelm mode`.** Every one of those narrates the user's emotional state and the app does not know it. `low stimulus` describes what changes on the screen. Keep it.
- **Auto-activation creeping back in as auto-*de*activation.** "Turn it off after 30 minutes of use" is the same rejected mechanism with the sign flipped, and it fires the accommodation off at the moment it is still needed. Nothing toggles this but a finger.
- **Wiring `MediaQuery.disableAnimationsOf` or `accessibleNavigationOf` to the mode.** It reads as respectful and it is auto-personalisation through the back door — plus a11y flags never select behaviour here beyond layout and semantics, and they never route through Riverpod anyway.
- **Prompting it.** "Text is large. Switch to 6 tiles?" is the app noticing something about the user and offering to help. So is a first-launch tip. So is a strip. The row in settings is the whole affordance.
- **Adding `package:vibration` or `android.permission.VIBRATE`.** `HapticFeedback` needs neither. The manifest-derived permissions list is the *only* fact backing the privacy claim — the one thing anyone can independently check — and a VIBRATE line on it costs that for a pulse already available for free.
- **"Fixing" haptics that do nothing.** If the user disabled touch feedback at the OS level, the pulse is a no-op on some OEMs while the row still reads `haptics: on`. That is not Reed's bug and Reed does not detect it, narrate it, or route around it with a plugin.
- **Burying the control.** A submenu, a dialog, or a scroll to reach `low stimulus` is a navigation decision demanded of someone whose decision-making is exactly what is impaired. First two rows, tap to cycle, no confirmation.

## Files

- `lib/data/settings_repository.dart` — changed. `low_stimulus` key, `ReedSettings.lowStimulus` (default `false`), `setLowStimulus(bool)` with the no-automation comment, total parse with fallback + log.
- `lib/ui/settings/settings_screen.dart` — changed. The `haptics` and `low stimulus` rows, first two, with their semantic labels.
- `lib/ui/board/phrase_tile.dart` — changed. One gated `unawaited(HapticFeedback.selectionClick())` inside the existing `onPointerDown` ordering.
- `lib/ui/app.dart` — changed. `effectiveTheme` / `effectiveGridSize` applied above the board.
- `test/data/settings_repository_test.dart` — changed. `low_stimulus` cases.
- `test/ui/settings/settings_screen_test.dart` — changed. Row copy, labels, toggle-fires-no-pulse.
- `test/ui/board/phrase_tile_test.dart` — changed. The platform-channel haptic log, on and off, and the ordering assert.
- `epics/E03-data-layer/T03-settingsrepository.md` — changed. Seven keys becomes eight.

## Done when

The pulse fires once per press and stops the moment the row says `haptics: off`; `low stimulus: on` paints six undyed tiles on the next frame and on the first frame of the next launch, without having written a single byte over the user's theme or grid preference, and nothing in the app can turn it on but a finger.
