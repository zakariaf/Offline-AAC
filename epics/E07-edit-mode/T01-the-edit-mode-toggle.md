# E07-T01 — The edit mode toggle

| | |
|---|---|
| **Epic** | E07 — Edit mode |
| **Status** | Not started |
| **Size** | S |
| **Depends on** | E05-T02 |
| **Blocks** | E07-T02 |

**Skills:** `reed-widget-conventions` · `reed-a11y-coding` · `reed-tile-anatomy`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

Every other AAC board hides editing behind a long-press. Long-press collides head-on with dwell-style assistive input, where holding *is* the ordinary way to activate — a dwell user cannot reach edit mode at all, and worse, may fall into it by accident and never know why the board stopped speaking. It is also an invisible state machine: nothing on screen says a press is being timed, nothing says how long, and a slow or tremoring press either fires the wrong thing or fires nothing. This task makes edit a **visible mode toggle** — a labelled, focusable button that changes the screen — and flips the one rule that decides whether the editor is usable by switch access at all: in edit mode the empty slot becomes a real target.

## Scope

**The state.** Edit mode is state, not a route. There is no navigation, no `Navigator.push`, no `PageRoute`. Add a `bool editing` field to `BoardUiState` and a `toggleEditing()` method on `BoardController` (`lib/ui/board/board_controller.dart`) — the `Notifier` that already owns the board's UI state. **Do not add a new provider for this.** Provider count going up is a smell, not progress; the ViewModel that already exists is the right owner.

```dart
// lib/ui/board/board_controller.dart
class BoardController extends Notifier<BoardUiState> {
  void toggleEditing() => state = state.copyWith(editing: !state.editing);
}
```

`editing` starts `false` on every launch. It is **not persisted** — a board that reopens in edit mode is a board that does not speak when tapped, and the user has no idea why.

**The toggle control.** One visible button in the board screen's chrome. Extract it as a `StatelessWidget` (`lib/ui/board/edit_mode_button.dart`), never a `Widget _buildEditButton(...)` method — a method's subtree has no `Element` of its own and `find.byType` cannot reach it in a test, and tests plus the analyzer are the entire feedback loop here.

Wiring, exactly:

- `GestureDetector` with `behavior: HitTestBehavior.opaque` — **not** `InkWell`. `splashFactory: NoSplash.splashFactory` kills only the splash; `InkResponse.updateHighlight()` independently creates an `InkHighlight` with a 200ms pressed fade and schedules a second frame.
- `onTap` only. No `onLongPress`, no `onDoubleTap`, no `onPan*`, no `Draggable`, no `Dismissible` — anywhere in this diff.
- `Semantics(container: true, button: true, label: ...)` on the outside.
- The label states the mode the button will put you in, and changes with state: `'Edit board'` when resting, `'Done editing'` when `editing` is true. A label that never changes is a lie to a screen reader about what the button does.
- The icon inside is decorative — the `Semantics` node above already announces it — so wrap it in `ExcludeSemantics`, or give it a `semanticLabel`. There is no third option; an unlabelled `Icon` is invisible to a screen reader.
- Non-colour channel for the on/off state. The button's own state must be readable without colour — the semantics label change is one channel; the icon shape is a second. A tint alone is invisible under `invertColors` and under Android's Grayscale colour-correction mode.
- `boldText` is honoured by not hardcoding `fontWeight` on the button's text: read `MediaQuery.boldTextOf(context)` at build time. Platform a11y state comes from `BuildContext`, never from Riverpod.

**The rule this flips: the empty slot.** Today (E05-T05) an unfilled slot is ground and nothing else — no fill, no keyline, no target, and `ExcludeSemantics(child: SizedBox.expand())`, so TalkBack and Switch Access **skip** it rather than burning a scan step on nothing. Under linear autoscan at 1s/step every wasted step is real seconds someone spends unable to speak.

In edit mode the same cell becomes a full target:

| | resting | edit mode |
|---|---|---|
| keyline | none | `1.0 / MediaQuery.devicePixelRatioOf(context)`, `keyline` colour, `strokeAlignInside` |
| shape | — | `RoundedSuperellipseBorder`, radius **20dp** (`Geom.tileRadius`) |
| content | nothing | a `+`, centred |
| hit target | none | the full rect, via `HitTestBehavior.opaque` |
| semantics | `ExcludeSemantics` | `Semantics(button: true, label: 'Add phrase')` |

**Make the exclusion mode-dependent, or the editor is unusable by switch access** — a switch user cannot reach a node that is not in the semantics tree, so with a static `ExcludeSemantics` they can never add a phrase to an empty slot. This is the whole reason the task exists.

`PhraseTile` therefore takes an `editing` flag and branches on it:

```dart
if (button == null) {
  return editing
      ? Semantics(
          container: true,
          button: true,
          label: 'Add phrase',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onEditSlot(slot.row, slot.col),
            child: const ExcludeSemantics(child: _EmptySlotFace()),
          ),
        )
      : const ExcludeSemantics(child: SizedBox.expand());
}
```

Resolve at tap time from the immutable `(row, col)` primary key. Never capture slot content into the closure.

**Never `Border.all()`** for the empty-slot keyline: it defaults to 1.0 *logical* px = 3 physical pixels on a modern phone. That is a rule, not a hairline. In high contrast the keyline is promoted to a solid **3dp** — the same promotion the filled tile uses.

Filled tiles in edit mode still hold their space, still render their label at 20 / w600, and do **not** speak on tap — the tap routes to the editor instead. Wiring what that tap opens is E07-T02; this task passes an `onEditSlot(int row, int col)` callback and can land it as a no-op or a `TODO`-free stub the next task fills.

**Out of scope:** the edit sheet/screen itself, adding or changing a phrase, `says`/`label` fields, reordering, deleting, persistence of any edit, any confirmation UI. All of that is E07-T02 and later. This task is the toggle, the flag, and the empty slot's mode-dependent semantics.

## Acceptance criteria

- [ ] `grep -rn 'onLongPress\|onDoubleTap\|onPanStart\|Draggable\|Dismissible' lib/ --include='*.dart'` returns nothing.
- [ ] `grep -rn 'InkWell\|InkResponse' lib/ui/board/ --include='*.dart'` returns nothing.
- [ ] A widget test taps the edit button by `find.byType(EditModeButton)` and asserts `BoardController`'s state flips `editing` false → true → false.
- [ ] A widget test asserts the button's semantics with `isSemantics(button: true, label: 'Edit board')` resting and `isSemantics(button: true, label: 'Done editing')` after one tap. Use `isSemantics(...)`, **not** `containsSemantics(...)` — the latter is deprecated after v3.40.0-1.0.pre.
- [ ] A widget test on a board with at least one empty slot asserts: resting, the empty cell produces **no** semantics node; in edit mode, it produces `isSemantics(button: true, label: 'Add phrase')`.
- [ ] A widget test asserts the empty cell occupies the same `tester.getRect(...)` in both modes — it never collapses and never pulls the next tile into its position.
- [ ] `tester.binding.hasScheduledFrame` is `false` after a single `pump()` following a tap on the edit button.
- [ ] Both modes render at `TextScaler.linear(2.0)` with no overflow. No `MediaQuery.withClampedTextScaling`, no `textScaleFactor`, no `FittedBox`, no `TextOverflow.ellipsis` anywhere in the diff.
- [ ] `dart analyze` is clean.

## Traps

- **Reaching for long-press "just for the developer."** It ships. It collides with dwell input and it is invisible. There is no debug-only gesture; there is only a gesture.
- **Making edit a route.** `Navigator.push` to an edit copy of the board duplicates the grid, duplicates the geometry, and guarantees the two drift apart. Four destinations, no deep links: modes are state.
- **Persisting `editing`.** A board that reopens in edit mode is a board that silently does not speak. Silence is the worst bug this app can produce, and nobody will report it — no telemetry, and a user who cannot speak does not file a bug report.
- **A static `ExcludeSemantics` on the empty slot.** The most likely defect in this task: everything looks right on a touchscreen and the editor is completely unreachable by switch access. The `+` is painted, and it is not in the semantics tree.
- **Leaving `enabled: false` instead of excluding, in the resting mode.** A disabled node still burns a scan step. Excluding is what makes the scanner skip it.
- **A semantics label that does not change with the mode.** `label: 'Edit'` on both states tells a screen-reader user nothing about which mode they are in — and the mode is the entire point of the control.
- **Signalling edit mode by tinting the chrome.** Colour-only state is invisible under `invertColors`, under Grayscale colour-correction, and to every screen-reader user. The label change is mandatory; the tint is optional decoration on top.
- **Reading edit mode through Riverpod inside `PhraseTile` and platform a11y state through Riverpod too.** App state comes from Riverpod. Platform a11y state (`MediaQuery.boldTextOf`, `MediaQuery.highContrastOf`) comes from `BuildContext` at build time — a provider trades a compiler-guaranteed rebuild for a manual sync that is stale for one frame.
- **`Border.all()` on the `+` slot.** 3 physical pixels. It reads as a table border and it will not match the tile keyline beside it.
- **A second radius constant for the empty slot.** Use `Geom.tileRadius` (20dp). Constants drift apart and the grid stops looking machined.
- **`GlobalKey` on the button to poke it from a test.** Never. The widget is addressable by type; that is why it is a widget.
- **`ContinuousRectangleBorder` on the `+` slot** because it is the shape name people remember. Banned — it centres its stroke regardless of `strokeAlign`, and it degenerates at exactly this radius. `RoundedSuperellipseBorder` is first-party and has a GPU path in Impeller.

## Files

- `lib/ui/board/board_controller.dart` — `editing` on `BoardUiState`, `toggleEditing()`.
- `lib/ui/board/edit_mode_button.dart` — new. The visible toggle.
- `lib/ui/board/board_screen.dart` — place the button in the chrome; thread `editing` to the grid.
- `lib/ui/board/phrase_tile.dart` — `editing` flag; mode-dependent empty-slot branch; the private `_EmptySlotFace`.
- `test/ui/board/edit_mode_button_test.dart` — new.
- `test/ui/board/phrase_tile_test.dart` — empty-slot semantics in both modes, rect stability.

## Done when

Tapping a labelled, focusable button flips the board into edit mode, every empty slot becomes a `+` with a real keyline and a real `button: true` semantics node that switch access can reach, and no long-press exists anywhere in `lib/`.
