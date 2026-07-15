---
name: reed-widget-conventions
description: Widget composition for Reed — extract a StatelessWidget instead of a `_buildX` method, `GestureDetector` plus `HitTestBehavior.opaque` for tap-only wiring, `ValueKey((row, col))` and never `GlobalKey`, drift row classes over `freezed`/`equatable`, and `const` that is never hand-tuned. Use when building or refactoring PhraseTile or any widget, adding `onTap`/`onLongPress`/`Draggable`/`Dismissible`, hand-rolling a data class or `copyWith`, or reviewing widget structure in a diff. Not for ripples, splashes, or durations.
---

# Reed widget conventions

Composition rules for a one-screen app: a fixed 3x4 grid of phrase tiles, a type-to-speak field, on-device TTS, a poster mode, an edit mode, settings. Zero animation, zero telemetry, ~25 source files.

## Extract a widget, not a method

```dart
// WRONG — a method. Its output is part of the PARENT's build. The parent
// rebuilds, this rebuilds, and there is no Element boundary to stop it.
// It cannot be const, and find.byType cannot reach it in a test.
Widget _buildTile(BuildContext context, GridSlot slot) { ... }

// RIGHT — a widget. Gets its own Element and its own const-ness.
class PhraseTile extends StatelessWidget { ... }
```

The mechanism, stated honestly: a method's returned subtree has no `Element` of its own, so `Element.updateChild` never gets a chance to compare old and new widget and short-circuit. A separate widget class does get that chance.

**At 12 tiles, rebuilt approximately never, this buys no measurable performance.** Do not extract widgets for speed — there is no frame budget to miss in an app with no animation. Extract them because they buy three real things:

- a unit a test can address by type (`find.byType(PhraseTile)`), which matters more than usual: the analyzer and the test suite are the whole feedback loop, since nobody will ever report a field crash and a user mid-shutdown cannot file a bug.
- a subtree that *can* be `const`.
- a name a stranger can grep, in a repo a stranger may inherit.

Private widget classes (`_TileFace`) are the right size for the visual leaf of a tile. Keep the public widget doing semantics and gesture wiring; keep the private one doing paint and type.

## const

The mechanism is real: `const` expressions are canonicalized at compile time, so two identical `const` widgets are literally the same object. That makes `Element.updateChild`'s `child.widget == newWidget` identity check true and prunes the subtree rebuild.

**The runtime saving here is unmeasurable.** Twelve flat tiles, no animation.

Keep `prefer_const_constructors` on anyway, for two non-performance reasons:

1. `dart fix --apply` writes it, so it costs nothing.
2. `const` documents "this widget has no dynamic inputs" to the next reader.

**Budget for hand-tuning const: zero minutes.** Never restructure a widget tree to make something const-able. Never add a `const` constructor to a class that would otherwise want a non-final field. If a reviewer's only finding is a missing `const`, the review found nothing.

## Keys

Keys matter in exactly one situation: the framework must decide whether an `Element` can be reused for a new `Widget` at the same position in the child list. The classic bug is a tile's `button_id` flipping `null → set`, the `Element` and its `State` being reused, and stale `State` bleeding into the new tile.

**The schema sidesteps this.** `grid_slots` has `PRIMARY KEY (board_id, row, col)`. Position is part of the identity; slots never reorder; the child list is a fixed 12 in fixed order. There is no list to shuffle and no `State` to leak.

So the whole key policy is:

| Situation | Key |
|---|---|
| A slot in the grid | `ValueKey((row, col))` — cheap, and makes intent legible |
| Everything else on the speak path | none |
| A tile that wants `State` | **stop** — that is the signal to reconsider the design, not to add a key |

Never add `ObjectKey`, never add `GlobalKey`, never add a key-per-button. `GlobalKey` in particular forces a global registry lookup and enables cross-tree Element reparenting — machinery for a problem this app does not have. Do not add keys because a lint blog said to; a key on a stateless widget in a fixed-order list changes nothing at all.

## Immutability, data classes, copyWith

Do not add `freezed`. Not because it is dead — it is maintained — but because it is **redundant**: drift's generator already emits an immutable row class with `==`, `hashCode`, `toString`, and `copyWith` for every table. That is the exact list freezed is recommended for. Adding it means a second generator producing overlapping output on the same classes, plus a hand-written drift-row → freezed-model mapping layer. That mapping is the "separate API and domain models" pattern, which is for large apps with an API. There is no API here — no network, no server, no accounts.

Do not add `equatable` either. The only thing it would buy is `==` on a hand-written class used as a `Map` key, and that is `Object.hash(...)` plus five lines.

The decision rule for any new shape:

| Shape | Use |
|---|---|
| Persisted (`boards`, `buttons`, `grid_slots`, `images`, `sounds`, `settings`) | **drift's generated row class, directly.** It IS the domain model. Write nothing |
| Ephemeral multi-return inside one layer | **a record** — `(int row, int col)` |
| Sealed variant (`SpeakOutcome`, `SpeakFailure`) | **`final class`, `const` ctor, `final` fields.** No `==` needed — switch on the type, never compare instances |
| A joined shape drift generates no class for | **hand-written.** drift emits a row class per *table*, never per join. A displayable tile is `grid_slots ⟕ buttons ⟕ images`, so `Tile` is hand-written |
| Must be a `Map` key and isn't the above | manual `==` + `Object.hash(...)` |

**Records never cross a layer boundary.** They have no name, no doc comment, and a positional shape that silently changes meaning when reordered — `(int, int)` is fine as a coordinate inside the board layer and is not a domain type anywhere else.

For hand-written immutable classes: `@immutable`, a `const` constructor, `final` fields. Four lines replaces a code generator. Write `copyWith` by hand only when a call site actually needs it — an unused `copyWith` with a `Object? sentinel` dance is pure surface area.

## Gestures: tap only, direct touch only

**Tap only. No long-press, no double-tap, no drag, no swipe, no multi-touch, anywhere on the speak path.**

```dart
// WRONG — InkWell animates. splashFactory: NoSplash.splashFactory kills only
// the SPLASH; InkResponse.updateHighlight() independently creates an
// InkHighlight with a 200ms pressed fade, which schedules a second frame.
InkWell(onTap: onTap, child: face)

// RIGHT — no ink, no animation, no second frame scheduled.
GestureDetector(
  behavior: HitTestBehavior.opaque, // the whole cell is the target
  onTap: onTap,
  child: face,
)
```

`HitTestBehavior.opaque` is load-bearing: without it, only the painted child is hittable and the padding around a short label is dead space — a near-miss on a tile is silence, and silence is the worst outcome this app can produce.

Why each banned gesture is banned:

- **Long-press.** It collides with dwell-style assistive input, where holding *is* the ordinary way to activate. It is also an invisible state machine: nothing on screen says a press is being timed, nothing says how long, and a slow, tremoring, or distracted press either fires the wrong thing or fires nothing. Edit is a **visible mode toggle** — a button that changes the screen — never a hidden gesture.
- **Drag / swipe.** An accidental swipe silently repoints muscle memory: a user who has learned "bottom-left is *I need to leave*" taps a tile that has quietly moved and speaks the wrong sentence out loud, on behalf of someone who cannot verbally correct it. Reordering happens in edit mode through explicit controls, never `Draggable`/`LongPressDraggable`/`ReorderableGridView`/`Dismissible`.
- **Double-tap.** It forces a delay before the single tap resolves, or worse, eats it. Latency on the speak path is the bug.
- **Multi-touch / scale.** Nothing zooms. Text size is the platform's `TextScaler`, and it is never clamped.

**Every gesture needs a visible button fallback.** If an action can only be reached by a gesture, it cannot be reached at all by a switch-access user, a screen-reader user, or a person in a shutdown. State the rule the strict way: any behaviour reachable by touch must be reachable by a labelled, focusable control.

Zero animation is a design rule, not a preference — animation costs latency and, for this audience, adds distress. It is enforced by a test asserting `tester.binding.hasScheduledFrame` is `false` after a single `pump()` following a tap. Any `InkWell`, `InkResponse`, ripple, implicit `Animated*`, `AnimatedContainer`, `Hero`, or `PageRouteBuilder` transition fails it.

## Resolve at tap time, not at build time

```dart
// WRONG — captures the vocalization into the closure. A fast re-tap after an
// edit speaks a STALE sentence.
onTap: () => speak(button.vocalization),

// RIGHT — resolve from the immutable (row, col) primary key at tap time.
onTap: () => onSpeak(slot.row, slot.col),
```

The position is the stable identity; the content behind it is not. This is the same fact that makes keys unnecessary and closures dangerous.

## Where widget state comes from

App state comes from Riverpod. **Platform accessibility state comes from `BuildContext`, at build time**, via `MediaQuery.boldTextOf(context)` and `MediaQuery.highContrastOf(context)`. `MediaQuery` is already an `InheritedWidget` with correct-by-construction invalidation; routing it through Riverpod trades a compiler-guaranteed rebuild for a manual push-and-sync that is stale for one frame — in the one area where being wrong is total failure, because an inaccessible accessibility app is not a degraded app, it is a broken one.

Never read or clamp `textScaler`. Text scales itself; the job is a layout that survives it.

## Review checklist for a widget diff

- A `Widget _buildX(BuildContext ...)` method appeared → make it a class.
- `InkWell`, `InkResponse`, or any `Animated*` on the speak path → `GestureDetector` + `HitTestBehavior.opaque`.
- `onLongPress`, `onDoubleTap`, `onPan*`, `Draggable`, `Dismissible` → remove; use a visible control.
- A gesture with no button equivalent → add the button.
- `GlobalKey` or `ObjectKey` → delete.
- `freezed`, `equatable`, or a hand-rolled mirror of a drift row class → use the drift row class.
- A closure capturing tile content instead of `(row, col)` → resolve at tap time.
- A missing `const` → let `dart fix` handle it; do not spend review on it.
