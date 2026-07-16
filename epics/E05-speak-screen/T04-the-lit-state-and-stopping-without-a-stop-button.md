# E05-T04 — The lit state, and stopping without a STOP button

| | |
|---|---|
| **Epic** | E05 — The speak screen |
| **Status** | Done |
| **Size** | M |
| **Depends on** | E04-T05, E05-T01 |
| **Blocks** | E05-T07 |

**Skills:** `reed-tile-anatomy` · `reed-motion-policy` · `reed-speech-service` · `reed-no-silent-failures`

> Read these skills first. They carry the exact values this task must hit.

> **Superseded on two points — see EPIC.md "Design update — 2026-07-16".** The board now reflows columns and scrolls vertically at large text sizes, so the lit state and speech commit on **`onTap`** (after winning the gesture arena), not `Listener.onPointerDown` — otherwise every scroll attempt would speak. The haptic still fires on `onTapDown` for immediate feedback. The no-scroll premise this task leans on no longer holds. Everything else here — the luminance step, the 2 dp/`ink` keyline promotion, the 120 ms hold, the latch guard timer, no STOP button, barge-in — stands, and the lit-state coverage lives in `test/ui/lit_state_test.dart`.

## Why this exists

A user taps a tile mid-shutdown. They need to know, within a few tens of milliseconds and without hearing anything, that the tap landed — motor imprecision means "did I actually hit it?" is a live question, and re-tapping a tile that is already speaking is how a phrase gets said twice to a stranger. They also need to be able to stop a phrase that is coming out wrong, without a red emergency bar sitting on their board designing for a bystander's fear of them. The lit state answers both: pointer-down lights the tile, it stays lit while the words are in the air, and tapping the lit tile stops it.

## Scope

Build the lit state and the stop/switch behaviour into the tile widget and the speak-screen controller. **One state, two jobs**: press feedback and the speaking indicator are the same signal. There is no separate press state, and there is no separate speaking indicator.

### The lit state

| | value |
|---|---|
| fill | `stockLit` — OKLCH L ±0.09 toward the ink |
| keyline | 1 physical px → **2dp**, colour → `ink` |
| duration | **zero**; `splashFactory: NoSplash.splashFactory` at the theme root |
| minimum hold | **120ms** |
| trigger | `Listener.onPointerDown` — **not** `onTap` |
| order | haptic (`HapticFeedback.selectionClick`) → `setState(lit)` → TTS |

The keyline promotion from a hairline (`1.0 / MediaQuery.devicePixelRatioOf(context)`) to 2dp in `ink` is not decoration — it is the deliberate second channel. **Feedback is never single-channel and never chroma-only.** A chroma flood at matched luminance ("change chroma, hold lightness") computes to 1.02:1 in colour and **1.015:1 under Android's Grayscale colour-correction mode — literally invisible**, so a user in colour-correction mode who is not sure their tap landed gets nothing. The luminance step measures 1.34–1.48:1 and survives grayscale (1.36–1.48:1) and protan (1.34–1.52:1). Do not substitute a chroma change for the L step, and do not drop the keyline promotion as "redundant".

In high contrast the lit state is a **full inversion** — it is the only signal available at 19.43:1, and the user opted in. The stocks drop out entirely there, so never assume a tinted fill exists to step.

Lit label contrast floor is **WCAG AA 4.5:1 and APCA |Lc| ≥ 45** — deliberately lower than the resting floor (AAA 7:1 / Lc ≥ 60). It is a 1–3s transient the user triggered on a label they had just finished reading: it must stay *identifiable*, not *readable*. Do not "fix" it upward.

Expose lit through `Semantics`, never colour alone.

### Pointer-down, not tap

```dart
Listener(
  onPointerDown: (_) => controller.onTilePressed(row, col),
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,  // the full rect is the target, always
    child: face,
  ),
)
```

`onTap` fires on pointer *up*, delaying every channel of feedback by the entire press duration. `onPointerDown` + Android's touch pipeline (~20–40ms) + one frame (8–16ms) lands feedback at ~30–55ms with **no artificial delay**. This fires before gesture disambiguation, which is safe **only because the grid never scrolls** — that makes the no-scroll rule load-bearing, not aesthetic. Do not introduce a scrollable ancestor around the grid, and do not add one later "for small screens" without revisiting this.

Never `InkWell` — `InkResponse.updateHighlight()` mounts an `InkHighlight` with a 200ms pressed fade that `NoSplash.splashFactory` never touches.

### The 120ms minimum hold

A fast tap must never be imperceptible. The floor is **a `Timer` that clears a boolean**, not a fade-out and not an animation. If TTS completes at 40ms, the tile stays lit until 120ms have elapsed since pointer-down, then clears. Do not "smooth" it, do not implement it with `AnimatedContainer`, `Curve`, or any `Duration` passed to a transition.

### Stopping: no STOP button

- Tap the **lit** tile → stop. `SpeechService.stop()`, clear the latch.
- Tap a **different** tile → switch. The existing barge-in path already does `stop()` before `speak()`; the lit latch moves to the new tile.
- Tap a tile while **nothing** is lit → speak.

There is no STOP control on the board, no red bar, no cancel affordance. Coding a cancel as an emergency control designs for a bystander's fear of the user, not for the user.

Route this through the void-returning controller from E04-T05. **A callback must never touch a Future.**

```dart
/// VOID-RETURNING ON PURPOSE. `onPointerDown: (_) => c.onTilePressed(r, c)` is
/// safe precisely because there is no Future to drop. Do not "improve" this to
/// Future<void>: `onTap: () => speech.speak(p)` is caught by NO lint —
/// not discarded_futures, not unawaited_futures, not @useResult.
void onTilePressed(int row, int col) { ... }
```

Resolve the tile at press time from `(row, col)` — **never** from a value captured in `build()`. A stale capture speaks the *previous* phrase aloud to a stranger on behalf of someone who cannot correct it verbally.

Never wrap this in a Command pattern. Its `if (_running) return` swallows the re-tap; a re-tap on a *different* tile means "say this NOW" and must never be dropped.

### The latch timeout

**Guard the lit latch with a timeout that force-clears it.** `flutter_tts` completion-handler reliability varies by OEM. The `speak()` seam already carries `_speakTimeout = Duration(seconds: 8)`; the latch guard is a separate, independent timer in the controller so that a completion handler that never fires cannot leave a tile lit forever. A stuck-lit tile is a lie about what the app is doing, and nobody will ever report it — there is no telemetry and a user who cannot speak does not file bugs. When the guard fires, clear the latch and record one line to the crash log.

Every `SpeakFailure` clears the latch too, on the same path that puts the words on screen. A failure must never leave the tile lit.

### Out of scope

- The tile's resting anatomy — shape, keyline, inset, label, divergence tick, empty slot (E05-T01).
- The `SpeechService` impl, `SpeakOutcome`, `voice_filter`, and the on-screen fallback (E04-T05).
- Focus ring rendering (gutter, offset 2dp, width 3dp, radius 22dp, colour `focus`).
- The show-screen poster and its flash.
- Any STOP, cancel, pause, or replay control. Do not add one.

## Acceptance criteria

- [ ] `flutter analyze` is clean; no `Duration`, `Curve`, `Tween`, `Animated*`, `AnimationController`, or `InkWell` appears in the tile or controller diff except the latch-guard `Timer` and the 120ms floor.
- [ ] Widget test: `Listener` `onPointerDown` (not `onTap`) drives the lit state — a test that sends only a pointer-down event and `pump()`s once finds the tile lit, with no pointer-up.
- [ ] Widget test: after pointer-down + `pump()`, `tester.binding.hasScheduledFrame` is `isFalse` for every tile, with the reason `'Tapping "${t.label}" scheduled another frame => something animates.'`
- [ ] Widget test: fast tap — pointer-down/up with the fake TTS completing at 40ms — the tile is still lit at `pump(const Duration(milliseconds: 119))` and not lit at `pump(const Duration(milliseconds: 1))` after it. Use `pump(duration)`; **never** `pumpAndSettle`.
- [ ] Widget test: pressing the lit tile calls `stop()` and clears the latch, and does **not** call `speak()` again.
- [ ] Widget test: pressing a different tile while one is lit records exactly `['stop', 'speak', 'stop', 'speak']` on the fake and leaves only the new tile lit.
- [ ] Widget test: the fake never fires its completion handler → the latch clears at the guard timeout, asserted with `pump(duration)` past the guard, and one line lands in the crash log.
- [ ] Widget test: every `SpeechEnv.detectable` value → the tile is not lit after the failure resolves, and the fallback text is on screen.
- [ ] Semantics test: the lit tile's `SemanticsNode` announces the state — a test that asserts on semantics only, with the colour scheme unread, passes.
- [ ] Golden or unit assertion: lit fill is `stockLit` and lit keyline is 2dp in `ink`; a contrast unit test asserts lit label ≥ 4.5:1 and |Lc| ≥ 45 against `stockLit` on every stock.
- [ ] Grep test over `test/` for `pumpAndSettle` stays green.
- [ ] Manual, on a real device: tap a tile, tap it again mid-phrase — audio stops. Tap tile A then tile B mid-phrase — B speaks, A goes dark. Turn on Settings → Accessibility → Colour correction → Grayscale and confirm the lit state is still visible.

## Traps

- **Wiring to `onTap` because it is what every Flutter tile does.** `onTap` fires on pointer up. The entire press duration is added to every channel of feedback — haptic, visual, audio. The delay is invisible in a simulator and obvious to someone with motor imprecision holding a phone during a shutdown.
- **Reaching for a chroma flood because it looks better in the design tool.** Matched-luminance accent computes to 1.02:1 in colour and 1.015:1 in grayscale. It is invisible to exactly the user who most needs the confirmation. The step must be luminance, and the keyline promotion must stay.
- **Deleting the 2dp/`ink` keyline promotion as redundant with the fill step.** It is the second, non-chroma channel. Single-channel feedback is banned.
- **Implementing the 120ms floor as a fade, a `Curve`, or an `AnimatedContainer` "so it doesn't snap".** It is a boolean and a `Timer`. Snapping is the design.
- **`if (_running) return` anywhere on this path** — the Command-pattern instinct. It swallows the re-tap, which is precisely the "stop" gesture *and* precisely the "say it again NOW" gesture. Both become silence.
- **`onPointerDown: (_) => speech.speak(phrase)`.** Verified: caught by no lint — not `discarded_futures`, not `unawaited_futures`, not `@useResult`. The arrow closure returns the Future so every rule considers it used; the `VoidCallback` target type discards it, and the error with it. Route through the void handler.
- **`unawaited(...)` with no `catchError` attached.** Same silence, with a permission slip.
- **Trusting the completion handler.** OEM behaviour varies. Without the independent guard timer, one manufacturer's engine leaves a tile lit until the user force-quits, and you will never find out.
- **Assuming `speak()`'s 8s timeout covers the latch.** It covers the *engine call*, not the *completion callback*. An engine that returns 1 immediately and then never fires completion sails past `_speakTimeout` entirely.
- **Clearing the latch on `SpokeAloud()` but forgetting the `SpeakFailure` arm.** The failure arm shows the words on screen and must clear the light too, or the board says "speaking" while the screen says "not spoken".
- **Adding a scrollable ancestor around the grid.** Pointer-down fires before gesture disambiguation; a scroll parent will claim the pointer and the lit state starts flickering on scroll attempts. The no-scroll rule is what makes pointer-down legal.
- **Reading `MediaQuery.disableAnimationsOf(context)` to pick a duration.** If a path is choosing between two durations, that path already violates the policy. There is nothing to disable.
- **Capturing the phrase in `build()`.** Resolve from `(row, col)` at press time or a stale board edit speaks the wrong sentence to a stranger.
- **Adding a STOP button because a tester asked for one.** The lit tile *is* the stop control. A red emergency bar on someone's board is a design about a bystander's fear, not about the user's need.

## Files

- `lib/ui/board/phrase_tile.dart` — `Listener.onPointerDown`, lit fill/keyline, `Semantics`, the 120ms floor.
- `lib/speech/speech_controller.dart` — `onTilePressed(row, col)`, the lit/stop/switch state machine, the latch guard timer.
- `test/ui/board/phrase_tile_lit_test.dart` — new.
- `test/speech/speech_controller_lit_test.dart` — new.
- `test/ui/board/no_scheduled_frame_test.dart` — extend to cover pointer-down.

## Done when

Pointer-down lights a tile within one frame with a luminance step and a promoted keyline that survive grayscale, the light persists for at least 120ms and until speech actually ends, tapping the lit tile stops it and tapping another switches, and a completion handler that never arrives cannot leave a tile lit.
