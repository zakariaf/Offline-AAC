# E05-T05 — The empty slot

| | |
|---|---|
| **Epic** | E05 — The speak screen |
| **Status** | Done |
| **Size** | XS |
| **Depends on** | E05-T02 |
| **Blocks** | Nothing |

**Skills:** `reed-tile-anatomy` · `reed-a11y-coding` · `reed-drift-schema`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A board with eleven phrases has one cell with nothing in it. If that cell paints a keyline it reads as a broken or disabled tile *and* invites a tap that does nothing — two failures from one outline. Worse, if it carries a semantics node, a Switch Access user on linear autoscan at 1s/step spends a real second of a shutdown scanning past nothing, and a TalkBack user hears an announcement for a socket with nothing installed. The empty slot is not a hole and not a bug: it is ground, and the surrounding tiles' keylines define its shape by negative space.

## Scope

The empty branch of `PhraseTile`. `GridSlot.button` is null (schema-wise: a `grid_slots` row with `button_id IS NULL` — an empty cell is a **row**, never an absent row; see `reed-drift-schema`). Render:

```dart
final button = slot.button;

if (button == null) {
  // Ground, nothing else. No fill, no keyline, no target, no ripple,
  // and NO semantics node — ExcludeSemantics, not `enabled: false`.
  return const ExcludeSemantics(child: SizedBox.expand());
}
```

What that means concretely:

- **No fill.** No `stock`, no `container`. The cell shows `ground` because nothing is painted over it. Do not paint `ground` explicitly "to be safe" — that is a fill, and it will diverge from the scaffold background the first time a palette changes.
- **No keyline.** No `RoundedSuperellipseBorder`, no `side:`, no r=20dp shape at all. The 1-physical-px keylines of the *neighbouring* tiles are what make the slot legible.
- **No hit target.** No `GestureDetector`, no `Listener`, no `HitTestBehavior.opaque`, no `InkWell`. A tap in the empty cell does nothing and gives no feedback, because there is nothing there.
- **No semantics node.** `ExcludeSemantics`, **not** `Semantics(enabled: false)` and not `Semantics(button: false)`. Disabling still produces a node; scanners still land on it. Excluding removes it from the tree so TalkBack and Switch Access **skip** it.
- **It still holds its space.** `SizedBox.expand()` inside the grid cell. The empty cell never collapses and never pulls a neighbour into its position — reflow is the failure the fixed `(board_id, row_index, col_index)` schema exists to make unrepresentable, and the widget layer must not reintroduce it.

**Edit mode is the other half of this task.** The exclusion is **mode-dependent**. In edit mode the same slot becomes a full target: keyline, a `+`, full semantics with `button: true` and a label, and a tap that opens the editor for that `(row, col)`. If the exclusion is unconditional, the editor is unusable by switch access — a switch user can never add a phrase.

Thread the mode in as a parameter of the empty branch (e.g. an `editing` bool or the existing edit-mode flag the speak screen already holds from E05-T02). Do not read edit mode from a global at the leaf; the widget test needs to drive both branches directly.

The `+` in edit mode is an `Icon` and therefore gets a `semanticLabel`, or is `ExcludeSemantics`-wrapped and the announcement comes from the outer `Semantics(label: ...)` node instead. There is no third option. Prefer the outer-label route, so the icon is decorative and the node announces once.

**Out of scope:** the edit-mode editor sheet/route itself (the `+` only needs to fire the same callback the speak screen already routes); the filled-tile face, its label, lit state, divergence tick and focus ring; the grid geometry; anything that writes to `grid_slots`. Deleting a tile writes NULL to the slot — that is data-layer work, not this task; here you only render the NULL.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] Widget test: pump `PhraseTile` with `slot.button == null`, editing false — `find.bySemanticsLabel` finds nothing for that cell, and the rendered semantics tree contains no node for it. Assert with `isSemantics(...)`, never the deprecated `containsSemantics(...)`.
- [ ] Widget test: same slot, editing false — no `GestureDetector`, no `Listener`, no `InkWell` in the subtree; a `tester.tap()` at the cell's centre invokes no callback.
- [ ] Widget test: same slot, editing false — no `RoundedSuperellipseBorder` and no `DecoratedBox`/`ShapeDecoration` painted in the subtree.
- [ ] Widget test: same slot, editing **true** — a semantics node exists with `isSemantics(isButton: true, label: <the add label>)`, and `tester.tap()` at the cell's centre invokes the add callback with the slot's `(row, col)`.
- [ ] Widget test: an 11-filled/1-empty 3×4 board renders 12 cells; the empty cell's `RenderBox` size equals its filled neighbours' and the filled tiles' rect offsets are identical to the all-12-filled case (nothing moved).
- [ ] Golden (speak mode, one empty slot): the empty cell's pixels equal the scaffold `ground` colour edge-to-edge inside its cell minus the neighbours' keylines.
- [ ] The empty cell renders unchanged at `TextScaler.linear(2.0)` — no overflow, no exception (there is no text, so this is a cheap regression guard on the `SizedBox.expand()` not being replaced by something intrinsic).

## Traps

- **`Semantics(enabled: false)` instead of `ExcludeSemantics`.** This is the reflex, it reads as "correct", and it is the bug: a disabled node is still a node. TalkBack announces it as disabled; Switch Access linear autoscan still stops on it for a full second. The whole point is that the scanner never sees it.
- **Making the exclusion unconditional.** Ship this without the edit-mode branch and a switch-access user can never add a phrase to an empty slot — the app is uneditable by exactly the population it is for. Both branches go in the same commit, or the editor is broken from day one and nobody will report it.
- **Outlining it "so the user knows a slot is there."** An outlined empty slot fails twice: it looks like a broken/disabled tile, and it invites a tap that does nothing. Negative space between the neighbours' keylines already communicates the socket.
- **Painting `ground` explicitly.** Looks identical today; drifts the moment a palette changes or the scaffold background moves, and in the high-contrast palette the stocks drop out entirely and the keyline *is* the tile — an explicit fill there is a guess about a colour system that has moved.
- **Returning `SizedBox.shrink()` or `const SizedBox()` or nothing.** The cell collapses, the grid reflows, and position-based muscle memory — the retrieval channel most likely to survive a shutdown — now points at the wrong phrase. The user presses their spot and says the wrong sentence. `SizedBox.expand()`.
- **`HitTestBehavior.opaque` left on the cell wrapper for both branches.** Copy-paste from the filled branch swallows the tap and gives the tile-shaped dead zone a hit target. Speak-mode empty cell: no behavior, no detector, nothing.
- **An unlabelled `+` icon in edit mode.** Invisible to a screen reader. Label it or `ExcludeSemantics` it under a labelled outer node.
- **Capturing the button into the edit-mode callback.** There is no button — but the same rule applies: resolve at tap time from the immutable `(row, col)` primary key, so a fast re-tap after an edit cannot act on a stale reference.

## Files

- `lib/ui/speak/phrase_tile.dart` — the `button == null` branch, plus the edit-mode variant.
- `test/ui/phrase_tile_empty_test.dart` — new: semantics exclusion, no target, edit-mode target, no-reflow.
- `test/ui/golden/` — the speak-mode golden with one empty slot.

## Done when

`PhraseTile` with a null button paints only ground, has no hit target and no semantics node at all in speak mode, becomes a fully labelled `+` target in edit mode, and holds its cell's exact size in both — with tests asserting each.
