# E05-T08 — Wire the screen to the repository

| | |
|---|---|
| **Epic** | E05 — The speak screen |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E03-T02, E05-T02 |
| **Blocks** | E01-T06 |

**Skills:** `reed-riverpod-usage` · `reed-layering-rules` · `reed-async-rules` · `reed-widget-conventions`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Up to now the grid has been drawing whatever it was handed. This task connects it to the real board on disk, reactively, so that a tile edited in edit mode is a tile that speaks the new sentence on the very next tap. It is also where the app's nastiest silent bug is either designed out or designed in: if a tap closure captures the tile it saw at build time, a fast re-tap after an edit speaks the *previous* phrase — the wrong words, out loud, to a stranger, on behalf of someone who cannot verbally correct them. Position is the primary key and cannot go stale; content behind it can.

## Scope

Build the reactive read from `BoardRepository` into the grid, and the tap path back out.

**The provider chain already declared in `lib/providers.dart`** (from E05-T02 / E03-T02) — do not add to it:

```dart
final boardRepositoryProvider =
    Provider<BoardRepository>((ref) => BoardRepository(ref.watch(databaseProvider)));

// isAutoDispose defaults to FALSE for hand-written providers. False is right here:
// the grid IS the app.
final gridProvider = StreamProvider<BoardGrid>(
  (ref) => ref.watch(boardRepositoryProvider).watchGrid(kDefaultBoardId),
);
```

**The screen watches, never subscribes.** The board surface is a `ConsumerWidget` that does `ref.watch(gridProvider)` in `build()` and handles **every** `AsyncValue` arm — data, loading, error. Riverpod owns the `StreamSubscription` lifecycle, so there is no `StreamSubscription` field, no `initState`, no `dispose()` cancel, and `cancel_subscriptions` has nothing to complain about. Do not hand-roll a `listen()` in `initState` "for control".

An **empty slot renders as an empty tile that holds its space** in the fixed 3x4 layout — never as a collapsed cell, never as a shrunk row. Loading and error arms must not collapse the grid either.

**The tap path passes coordinates, never content.**

```dart
// WRONG — captures the watched value in build(). A fast re-tap after an edit
// speaks the PREVIOUS tile's sentence.
onTap: () => controller.speak(tile.vocalization),

// RIGHT — (row, col) is the grid_slots primary key. Position cannot go stale.
onTap: () => controller.speakSlot(slot.row, slot.col),
```

`BoardController.speakSlot` resolves the tile **now**, via `ref.read`, and returns **`void`**:

```dart
// VOID, deliberately. Do not "improve" this to return a Future.
void speakSlot(int row, int col) {
  final tile = ref.read(gridProvider).valueOrNull?.tileAt(row, col);
  if (tile == null) return;
  unawaited(_speak(tile.vocalization).catchError(_recordAndShow));
}
```

The `void` return is the structural fix, not a style choice: `onTap: () => s.speak('x')` is flagged by **neither** `discarded_futures` **nor** `unawaited_futures` — the arrow closure returns the Future so the lints think it is handled, but the target type is `VoidCallback`, so the Future *and its error* are dropped. A void-returning method makes that hole unreachable by construction. Keep the comment saying so.

`ref.watch` in `build()` and inside provider bodies. `ref.read` inside callbacks only. A `ref.read` in `build()` gives a value that never updates — a screen frozen on stale data with no error. If `speakSlot` ever writes `state` after an `await`, guard with `if (!ref.mounted) return;`.

**No widget imports `package:drift`.** The repository — not a widget — unpacks the `grid_slots ⟕ buttons ⟕ images` join from `List<TypedResult>` via `readTable()` / `readTableOrNull()` and materializes `BoardGrid`. drift generates a row class per table and never per join; `BoardGrid` (dimensions × nullable tiles) is a shape the schema deliberately does not have.

Slot children use `ValueKey((row, col))`. Nothing else on the speak path gets a key. No `GlobalKey`, no `ObjectKey`.

Gestures: `GestureDetector` with `behavior: HitTestBehavior.opaque` — without it, the padding around a short label is dead space and a near-miss is silence.

**Out of scope:** the `SpeechService` implementation and the lit-state latch (E04); tile paint and typography; edit-mode writes; the type-to-speak field; any change to the schema or to `watchGrid`'s signature; tests *of the providers themselves* (testing that `ref.watch` propagates tests the framework).

## Acceptance criteria

- [ ] `rg -l "package:drift" lib/ui/` returns nothing.
- [ ] `rg "ref\.read" lib/ui/board/` shows reads only inside callbacks/notifier methods — zero inside a `build()` body.
- [ ] `grep -rn "StreamSubscription" lib/ui/` returns nothing; the board surface has no `initState`/`dispose` pair for the grid stream.
- [ ] `BoardController.speakSlot` has return type `void` and takes `(int row, int col)`. No method on the tap path returns `Future`.
- [ ] Every `onTap` in the board tree passes `(row, col)`; `rg "onTap.*vocalization" lib/` returns nothing.
- [ ] Widget test via `pumpApp` (`test/support/harness.dart`), with `databaseProvider.overrideWithValue` on a real `NativeDatabase.memory()`: pump the board, assert 12 `find.byType(PhraseTile)`.
- [ ] Staleness test: pump the board, write a new vocalization for (0,0) through `BoardRepository`, `pump()`, tap (0,0), assert `FakeSpeechService` received the **new** vocalization. This test must fail if the closure captures the tile.
- [ ] Empty-slot test: a board where (2,3) has a null `button_id` still renders 12 tiles and the grid geometry is unchanged; tapping the empty slot speaks nothing (no `FakeSpeechService.speak` call) and throws nothing.
- [ ] Every `AsyncValue` arm is handled — the loading and error arms render a grid-shaped shell, asserted by a test, not a bare `CircularProgressIndicator` that collapses the layout.
- [ ] `dart analyze` is clean with `use_build_context_synchronously`, `unawaited_futures`, `discarded_futures`, `cancel_subscriptions` at error.

## Traps

- **The capture bug, restated because it is the whole task.** `onTap: () => speak(tile.vocalization)` reads *correct* and is the most idiomatic way to wire a Flutter tile. It captures the value `build()` saw. After an edit, a tap that lands before the rebuild speaks the old sentence. Pass `(row, col)`; resolve at tap time with `ref.read`.
- **The lint hole no lint sees.** `onTap: () => s.speak('A')` produces **no diagnostic** from `discarded_futures`, `unawaited_futures`, or `unused_result` on this toolchain. A green analyzer here proves nothing. The only defence is the `void` return type on the controller method.
- **Someone "improves" `speakSlot` to `Future<void>`** so it can be awaited in a test. That reopens the hole for every call site. Await something the controller exposes for tests instead, or assert on the fake.
- **`unawaited(...)` without a `catchError`** silences the lint and keeps the bug: the error goes to `PlatformDispatcher.onError`, detached from the UI, and the user gets nothing. `unawaited(x)` is only honest when `x` terminates in a `catchError` or is provably total.
- **`ref.read(gridProvider)` in `build()`** compiles, renders once, and never updates again. No exception, no test failure unless the staleness test exists. Write the staleness test.
- **A `Command`-style `if (_running) return;` guard** creeping onto the tap path. A re-tap means "say it again" / "I need this NOW". Swallowing it *is* the silence bug. Barge-in is the policy.
- **Reaching for `family`** to pass `(row, col)` into a per-tile provider. The moment `family` is typed, the argument that Riverpod was cheap here has been lost. Twelve tiles read one `BoardGrid`.
- **A `FakeBoardRepository` or Map-backed fake database.** It happily accepts a row the real `PRIMARY KEY (board_id, row_index, col_index)` rejects and never executes a migration step. Override `databaseProvider` with real in-memory sqlite3.
- **Unpacking the join in the widget** because "it's just a `readTableOrNull`". That drags `package:drift` into `lib/ui/` and puts three indistinguishable `String`s — `label`, `vocalization`, `displayText` — where a swap means a stranger hears the wrong sentence.
- **Optimistic state on the grid.** A local SQLite write is single-digit milliseconds, so the revert path can never fire — and a state that appears then reverts is a visual change the user did not cause, which the zero-animation rule forbids.
- **`pumpAndSettle` in the new tests.** Banned: zero animation means one frame settles it, and it only adds a 10-minute-timeout flake vector with a truncated stack trace. `pump()` does not advance the fake clock — use `pump(duration)`.
- **Routing `boldText` / `highContrast` / `textScaler` through a provider** while wiring state. App state via Riverpod; platform/a11y state via `MediaQuery.boldTextOf(context)` at build time, in the widget.

## Files

- `lib/ui/board/board_screen.dart` — `ConsumerWidget`, `ref.watch(gridProvider)`, all `AsyncValue` arms.
- `lib/ui/board/board_controller.dart` — `BoardController extends Notifier<BoardUiState>`, `void speakSlot(int row, int col)`.
- `lib/ui/board/phrase_tile.dart` — `onTap` passes `(row, col)`; `ValueKey((row, col))`.
- `lib/providers.dart` — read-only here; confirm `gridProvider` exists and do not add providers.
- `test/ui/board/board_screen_test.dart` — new: 12-tile render, staleness, empty slot, AsyncValue arms.

## Done when

The grid renders live from real in-memory SQLite through `gridProvider`, no widget imports `package:drift`, every tap passes `(row, col)` into a `void` controller method, and the staleness test fails when the closure captures a tile.
