# E05 — The speak screen

> Twelve chips of dyed paper stock in fixed positions, a type field in the worst position on the screen, and a lit state that is both the press feedback and the speaking indicator — with nothing that moves, nothing that scrolls, and no STOP button.

| | |
|---|---|
| **Status** | Not started |
| **Tasks** | 8 |
| **Depends on** | E02 (tokens and theme), E03 (the grid to render), E04 (something to speak with), E00 (the switch-access spike that E05-T06 is answerable to) |

## Why this epic exists

This is the product. Everything else in the repo exists so that this screen can be tapped by someone whose speech has just gone, one-handed, in a room with other people in it.

That is not a mood — it is the constraint that decided every rule here. It is why pointer-down and not `onTap`: `onTap` fires on pointer *up* and delays every channel of feedback by the entire press duration, while `onPointerDown` plus Android's touch pipeline (~20–40ms) plus one frame (8–16ms) lands at ~30–55ms. It is why the grid never scrolls: pointer-down fires before gesture disambiguation and is only safe because there is no scrollable ancestor to disambiguate against. It is why the lit state is a luminance step and not a chroma flood — a matched-luminance accent flood computes to 1.02:1 in colour and **1.015:1 under Android's Grayscale colour-correction mode**, which is to say invisible, which is to say a user with motor imprecision gets no confirmation their tap landed. And it is why the type field sits at the top, in the worst position: the ability to type implies more capacity than the ability to tap, so typing earns the worst spot and tiles earn the thumb.

Get this screen wrong and the failure is silence. Nobody reports silence. There is no telemetry, and a user who cannot speak does not file a bug.

## What "done" means

- `flutter test test/ui` passes: the `Device.all` × `[1.0, 1.3, 1.5, 2.0, 3.0]` × `[false, true]` bold matrix, **one `testWidgets` per tuple**, with no `takeException()` suppression and no `ignoreOverflowErrors` helper anywhere in `test/`.
- A label-fit test on `Device.small` (360×800, the tightest shipped 3×4) asserts every starter label's rendered height ≤ `slot.height − 32.0` and its line count ≤ 3, at every scale.
- A `getRect` invariant at 2.0×: tiles in a row share a `top`, tiles in a column share a `left`, `moreOrLessEquals(epsilon: 0.5)`. This replaces goldens; there are none.
- Tapping a tile records the **vocalization** in `FakeSpeechService.spoken` while `find.text(...)` finds the **label**. The two strings are never swapped.
- The loop over `SpeechEnv.detectable` passes: for every world, `spoke || showedFallback`.
- `expect(tester.binding.hasScheduledFrame, isFalse)` after a single `pump()` following a tap on each tile.
- `simulatedAccessibilityTraversal` order equals **priority** order, not layout order; the empty slot appears in no traversal at all.
- `grep -r 'package:drift' lib/ui` is empty, and `grep -rn 'withClampedTextScaling\|textScaleFactor\|FittedBox' lib/` is empty.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E05-T01 | The tile widget | M | E02-T03 |
| E05-T02 | The grid | S | E05-T01, E03-T02 |
| E05-T03 | The type-to-speak field | S | E05-T02 |
| E05-T04 | The lit state, and stopping without a STOP button | M | E05-T01, E04-T05 |
| E05-T05 | The empty slot | XS | E05-T02 |
| E05-T06 | Traversal order | S | E05-T02, E00-T06 |
| E05-T07 | Speak-screen widget tests | M | E05-T04 |
| E05-T08 | Wire the screen to the repository | S | E05-T02, E03-T02 |

**E05-T01 — The tile widget.** The chip: `RoundedSuperellipseBorder` at r=20dp, an opaque stock fill, a keyline at `1.0 / MediaQuery.devicePixelRatioOf(context)` with `strokeAlignInside`, a 16dp inset, a bottom-anchored start-aligned 20/w600 label at −0.20 tracking and height 1.15, max 3 lines, and the 6dp divergence tick when `says != label`. It is where the epic's whole vocabulary of refusals is established: no `Card`, no `elevation:`, no `BoxShadow`, no `Border.all()`, no `ContinuousRectangleBorder`, no `InkWell`, no `FittedBox`. The public widget does semantics and gesture wiring; a private `_TileFace` does paint and type. Everything downstream in this epic renders, tests, or wires this one class.

**E05-T02 — The grid.** Three columns, four rows, `crossAxisSpacing: Geom.gapColumn` (14) and `mainAxisSpacing: Geom.gapRow` (22) — note the axis trap, because getting them backwards is silent and looks almost right. `Scaffold(backgroundColor: t.ground)` full-bleed under the system bars, content in `SafeArea` plus a 24dp margin, `resizeToAvoidBottomInset: false`. Tile size is computed, never hardcoded and never floored. It exists as a separate task from T01 mostly to keep the plane's rules — unequal gutters, no dividers, no scrolling, no reflow — from being negotiated inside a tile diff.

**E05-T03 — The type-to-speak field.** The 13th cell: `container` fill, the same superellipse via `ShapedInputBorder` (there is no `RoundedSuperellipseInputBorder`), 72dp tall, spanning three columns, at the top. **Never `autofocus: true`** — a keyboard covering the grid at cold launch buries the twelve phrases someone opened the app to reach. Material, styled, never rebuilt: reimplementing IME composition is a multi-month trap. Its copy is lowercase chrome, sentence case, real apostrophes.

**E05-T04 — The lit state, and stopping without a STOP button.** The hardest task in the epic and the one with the most ways to look correct. One state, two triggers: pointer-down lights the tile and it stays lit until TTS completes. Zero duration, `stockLit` fill, keyline promoted to 2dp `ink`, a 120ms minimum hold implemented as a `Timer` clearing a boolean and never as a fade, the order haptic → `setState(lit)` → TTS. Stopping is re-tapping the lit tile; there is no STOP control, which means barge-in ordering (`stop` before every `speak`) is the mechanism and must be pinned. It depends on E04-T05 because the latch is only honest if it is driven by a real `SpeakOutcome` — and it must carry a timeout that force-clears it, since `flutter_tts` completion handlers vary by OEM and a stuck-lit tile is a lie the user will never report.

**E05-T05 — The empty slot.** Ground and nothing else: no fill, no keyline, no target, and `ExcludeSemantics` — **not** `enabled: false`. XS in code and load-bearing in behaviour: excluded means TalkBack and Switch Access *skip* it, and under linear autoscan at 1s/step every burned step is a real second someone spends unable to speak. It still holds its space; a collapsed cell drags the next tile into a position muscle memory has already claimed. It depends on `grid_slots.button_id` being nullable, which is why `reed-drift-schema` is in its list. In edit mode the same slot becomes a full target — make the exclusion mode-dependent or the editor is unusable by switch access.

**E05-T06 — Traversal order.** `sortKey: OrdinalSortKey(tile.priority.toDouble())`, authored from priority, never from the grid index. The lower-centre arc is a thumb optimisation that actively pessimises linear scanners: under Flutter's default row-major order, "I need to leave" is the 8th-to-11th thing announced. One argument buys lower-centre placement *and* first-in-traversal. It depends on E00-T06 because the spike is where the real-device behaviour was observed — the test here is a regression guard on intent, never conformance evidence.

**E05-T07 — Speak-screen widget tests.** The scale × bold × device matrix, the label-fit assertion, the `getRect` grid invariant, the vocalization-vs-label assertion, and the `hasScheduledFrame` spot check. It depends on E05-T04 rather than on the grid because the tests that matter most assert what happens when speech fails, and there is nothing to assert until the lit state and the fallback exist.

**E05-T08 — Wire the screen to the repository.** `gridProvider` as a `StreamProvider` over `watchGrid`, consumed as an `AsyncValue` with every arm handled, no widget importing `package:drift`, no optimistic state, and `onTap: () => controller.speakSlot(slot.row, slot.col)` — coordinates, resolved at tap time, never a value captured in `build()`. It blocks E01-T06 because the cold-launch sequence needs a screen that is actually fed by something.

## Skills this epic draws on

**The surface**
- `reed-tile-anatomy` — the chip's shape, fill, keyline, inset, label anchoring, the divergence tick, the lit state, the empty slot, the focus ring in the gutter.
- `reed-grid-layout` — 3×4, 14/22 gutters, the 24dp margin, edge-to-edge with inset targets, the field as the 13th cell, the 12-or-6 layout setting.
- `reed-typography` — the `tile` role at 20/w600/−0.20/1.15 and the `field` role at 22/w500; no italic, no `FittedBox`, no all-caps, curly apostrophes.
- `reed-colour-system` — `ground` / `container` / `stock` / `stockLit`, the keyline colour, and the two-tier contrast floor the lit label sits under.
- `reed-motion-policy` — zero duration, `GestureDetector` not `InkWell`, the 120ms hold as a `Timer` and not a fade, `pump()` not `pumpAndSettle()`.
- `reed-copy-voice` — the field's placeholder and every string this screen authors: lowercase chrome, no apology, no praise.

**Correctness**
- `reed-a11y-coding` — `Semantics(button: true)` with the display label, `OrdinalSortKey` from priority, `boldText` from `BuildContext`, no clamping.
- `reed-widget-conventions` — a widget not a `_buildX` method, `HitTestBehavior.opaque`, `ValueKey((row, col))`, tap only, resolve at tap time.
- `reed-speech-service` — barge-in before every speak, the sealed `SpeakOutcome` the lit latch reads, the `SpeechEnv` worlds.
- `reed-no-silent-failures` — the arrow-callback hole no lint catches, the void-returning `speakNow`, no `default:` over a sealed outcome.
- `reed-riverpod-usage` / `reed-layering-rules` / `reed-async-rules` — `gridProvider`, `ref.read` in callbacks, no drift import in `lib/ui`, no dropped Futures, `ref.mounted` across await gaps.
- `reed-drift-schema` — only the one fact E05-T05 needs: `button_id` is nullable, and a null is a socket, not a bug.

**Proof**
- `reed-widget-test-harness` — `useDevice` then `pumpApp`, `overrideWithValue`, `find.bySemanticsLabel` for behaviour and `find.byKey` for geometry.
- `reed-text-scale-testing` — the matrix, one `testWidgets` per tuple, the fit assertion, the four wrong fixes.
- `reed-a11y-testing` — `isSemantics` (never the deprecated `containsSemantics`), `simulatedAccessibilityTraversal`, and the honest limits of what a traversal test proves.
- `reed-testing-strategy` — what earns a test here and what is a jank remedy for an app with no frames to miss.

## Sequencing

E05-T01 is the gate. T02, T04, and everything after are consumers of the tile class, and none of them can start against a placeholder without re-doing the work when the real one lands.

After T02 the epic fans out wide: T03, T05, T06, and T08 touch different files and share nothing but the grid's existence. T04 runs in parallel with all of them, gated on E04-T05 rather than on anything in E05 after T01 — it is the long pole and should start the moment the tile paints. T07 is last by dependency and should not be treated as last by attitude: it depends on T04 only because its highest-value assertions are about failure, and everything it tests was built assuming it would exist.

The critical path into this epic runs E02-T03 → E05-T01 → E05-T02 → E05-T08 → E01-T06. E03-T02 feeds both T02 and T08 from the side. T03, T05, and T06 block nothing, which is the trap: T05 is fifteen lines that decide whether a switch user wastes twelve seconds per pass, and nothing downstream will force it to happen.

## Risks specific to this epic

- **`onTap` instead of `Listener.onPointerDown`.** Works, looks fine, and adds the entire press duration to time-to-first-word. No test catches it; the only signal is the stopwatch from E00-T04.
- **A scrollable ancestor added later.** The moment anything above the grid scrolls, pointer-down starts losing to gesture disambiguation and taps go missing intermittently. The no-scroll rule is load-bearing, not aesthetic, and nothing in the type system says so.
- **The stuck-lit tile.** An OEM whose `flutter_tts` completion handler never fires leaves a tile lit forever, claiming the app is speaking when it is not. Only the force-clear timeout prevents it, and only a device catches it if the timeout is missing.
- **`crossAxisSpacing` and `mainAxisSpacing` swapped.** 22 across and 14 down still renders a grid. It reads as a table instead of a page and nothing goes red.
- **`Border.all()` reintroduced.** Defaults to 1.0 *logical* px — three physical pixels on a 3× phone. The engraved keyline becomes a table border and the diff looks like a simplification.
- **A clamp added at 2am.** `withClampedTextScaling` turns a red matrix green while silently cancelling the user's own OS setting, with contrast and tap-target still passing. `FittedBox` and `ellipsis` are the same bug in disguise. The grep policy test is the only thing standing there.
- **`takeException()` in a `tearDown`.** Clears `_pendingExceptionDetails` before `testWidgets` rethrows, converting the whole overflow net into a no-op across the entire suite, from a file nobody thinks about.
- **Looping scales inside one `testWidgets`.** Overflow is reported once per `RenderObject`; scales 2..n silently report nothing. The loop must be around the `testWidgets` call, never inside it.
- **The label and the vocalization swapped.** Two `String`s the type system cannot tell apart. A screen-reader user hears a paragraph on every scan step, or a stranger hears the wrong sentence — spoken on behalf of someone who cannot verbally correct it.
- **A closure capturing tile content.** `onTap: () => speak(tile.vocalization)` speaks the *previous* phrase after an edit. `(row, col)` is the primary key; use it.
- **A minimum tile size.** If 76dp appears in this epic, it is invented. It is in no standard, it is non-binding at real tile sizes (~89–106 × 125–146dp), and at 200% it measures the wrong thing entirely.

## Out of scope

- **The `SpeechService` itself, `voice_filter`, the audio session, `SpeakOutcome`'s definition.** E04. This epic is a caller.
- **Show mode.** The poster, the fitted 32–140 type, the flash on entry — its own surface, governed by `reed-show-screen`. E05 only produces the tap that can lead there and the on-screen fallback text when speech fails.
- **Edit mode.** The `+` slot, the 16-character refusal, reordering by explicit control. E06. E05-T05 only makes the empty slot's semantics exclusion mode-dependent so the editor *can* exist.
- **Settings.** The palette switcher, the 12-or-6 layout choice, voice selection. E08. This screen reads the layout, it does not offer it — and it never prompts.
- **The colour tokens and the theme.** E02. E05 spends `ground`/`stock`/`stockLit`/`keyline`; it never types a hex.
- **The starter phrases and their provenance.** E03-T06. This epic renders whatever twelve strings arrive.
- **Goldens.** Not deferred — refused. The `getRect` invariants and the overflow matrix catch everything a golden would, with a failure message a human can read.
