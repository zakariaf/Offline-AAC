# E07-T03 — Reorder and hide

| | |
|---|---|
| **Epic** | E07 — Edit mode |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E07-T02 |
| **Blocks** | E07-T04 |

**Skills:** `reed-drift-schema` · `reed-tile-anatomy` · `reed-a11y-coding` · `reed-widget-conventions`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A board that cannot be rearranged is a board someone abandons: the phrase they need most stays in the top-right corner their thumb never reaches. But the obvious implementation — drag to reorder — is an accessibility failure. Drag is unreachable by TalkBack, unreachable by Switch Access, and hostile to one-handed or tremoring use. "Calm state" does not mean "high executive function": the same person who edits their board on a good day still has fatigue and motor limits on that good day. Reordering is move-up / move-down **buttons**, and removal is **hide**, because a tile the user built is their voice and deleting it is not a feature.

## Scope

Two edit-mode affordances on each filled slot, plus the repository operations behind them.

### 1. Move up / move down — buttons, never drag

In edit mode each filled slot shows a **Move up** control and a **Move down** control. Both are ordinary tap targets: `GestureDetector` with `behavior: HitTestBehavior.opaque`, wrapped in `Semantics(button: true, label: ...)`. No `Draggable`, no `LongPressDraggable`, no `ReorderableGridView`, no `Dismissible`, no `onLongPress`, no `onPan*` — anywhere in this task. Any behaviour reachable by touch must be reachable by a labelled, focusable control, and here the labelled control is the only mechanism.

Semantic labels use the **display label**, never the vocalization: `Move Overwhelmed up`, `Move Overwhelmed down`. A scanning user must not hear the whole sentence on every scan step.

Movement is **vertical only** within a column: `(row, col)` ↔ `(row − 1, col)` for up, `(row, col)` ↔ `(row + 1, col)` for down. At `row == 0` there is no Move up control; at `row == rows − 1` there is no Move down control. Bounds come from `boards.grid_rows` / `boards.grid_cols` on the board row and are enforced in `BoardRepository` — never `const kRows = 4`, never a SQL `CHECK`. The 2×3 crisis layout ships alongside the 3×4 phone default and must work here unchanged.

### 2. A move is a swap of `button_id`, in one transaction

`grid_slots` has `PRIMARY KEY (board_id, row_index, col_index)` with a **nullable** `button_id`. Position is the key. A move therefore **never touches `row_index` or `col_index`** — it swaps the `button_id` values of two existing slot rows.

```dart
// RIGHT — both slots already exist; only their contents trade places.
Future<void> moveUp(int boardId, int row, int col) async {
  if (row == 0) throw ...; // callers must not be able to reach this; see Traps
  await db.transaction(() async {
    final int? here  = await _buttonIdAt(boardId, row, col);
    final int? above = await _buttonIdAt(boardId, row - 1, col);
    await _setButtonIdAt(boardId, row,     col, above);
    await _setButtonIdAt(boardId, row - 1, col, here);
  });
}

// WRONG — mutates a primary-key column. Collides with the row already there,
// or silently creates a coordinate no tile occupies.
await (db.update(db.gridSlots)..where((s) => ...)).write(
  GridSlotsCompanion(rowIndex: Value(row - 1)));

// WRONG — delete + insert. Loses the coordinate; invites a reflow.
await (db.delete(db.gridSlots)..where((s) => s.buttonId.equals(id))).go();
```

Swapping with an empty slot (`button_id IS NULL`) is legal and is the normal case: the tile moves up, an empty slot lands where it was. The empty slot does **not** collapse and the tiles below do **not** shift. A board always holds exactly `grid_rows × grid_cols` slot rows before and after every move — assert that.

Set `buttons.user_edited = 1` and refresh `buttons.updated_at` on the moved button(s) as part of the same transaction.

### 3. Hide — a flag on the button, never a NULL in the slot

Each filled slot gets a **Hide** control in edit mode; hidden tiles get **Unhide**. Hiding writes `buttons.hidden = 1` (default 0) and `user_edited = 1`. It does **not** touch `grid_slots` at all. The slot keeps its `button_id`, so the coordinate, the phrase, the vocalization, the display text and the colours all survive intact and Unhide is a one-tap reversal.

Rendering:

- **Speak mode:** a slot whose button has `hidden = 1` renders exactly like an empty slot — ground, nothing else, `ExcludeSemantics(child: SizedBox.expand())`. No fill, no keyline, no target, no semantics node. Excluding it (rather than `enabled: false`) means TalkBack and Switch Access **skip** it instead of burning a scan step; under linear autoscan at 1s/step every wasted step is real seconds someone spends unable to speak.
- **Edit mode:** the hidden tile is still visible and still addressable — it must be, or it can never be unhidden. Show it with the tile's normal `RoundedSuperellipseBorder` r = 20dp keyline and a non-colour indication that it is hidden (its Unhide control, present and labelled). Never signal "hidden" by colour alone.
- Neither path reflows. Nothing moves.

`buttons.is_system = 1` (the repair phrase) cannot be hidden: no Hide control is rendered for it, and `BoardRepository` rejects the call rather than performing it silently.

### Explicitly out of scope

- **Delete.** Not in this task. The invariant is stated here only so nobody implements Hide as Delete: deleting means `DELETE FROM buttons` and letting `onDelete: KeyAction.setNull` write NULL into the slot — the button goes, the slot survives, empty, in place. Never `DELETE FROM grid_slots`.
- Editing label / vocalization / display_text / colour (E07-T02).
- Horizontal moves and cross-column moves.
- Any change to `priority` or to traversal order (see Traps).
- Undo history. Hide **is** the undo for removal.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] Source-grep test over `lib/` finds zero occurrences of `Draggable`, `LongPressDraggable`, `ReorderableGridView`, `ReorderableListView`, `Dismissible`, `onLongPress`, `onDoubleTap`, `onPan`.
- [ ] Repository test: `moveUp` on a 3×4 board with a tile at (2,1) and an empty slot at (1,1) leaves the tile at (1,1), an empty slot at (2,1), and **exactly 12 rows** in `grid_slots` for that board.
- [ ] Repository test: after any move, `SELECT COUNT(*) FROM grid_slots WHERE board_id = ?` equals `grid_rows * grid_cols`, and no `(row_index, col_index)` pair is missing or duplicated.
- [ ] Repository test: `moveDown` on the tile at (0,0) of a full column leaves the tile that was at (1,0) sitting at (0,0) — a true swap, not an overwrite, and no `button_id` appears in two slots.
- [ ] Repository test: a move sets `user_edited = 1` on the moved button.
- [ ] Repository test on a 2×3 board proves the same operations respect `grid_rows = 2` / `grid_cols = 3` — bounds read from the board row, not a constant.
- [ ] Repository test: `hide` sets `buttons.hidden = 1` and leaves `grid_slots.button_id` unchanged and non-NULL for that coordinate.
- [ ] Repository test: `hide` on a button with `is_system = 1` throws and mutates nothing.
- [ ] Widget test: in speak mode a slot with a hidden button produces **no semantics node** (assert with `isSemantics(...)`, not the deprecated `containsSemantics(...)`).
- [ ] Widget test: in edit mode the same slot exposes a `button: true` node labelled with the **display label**, plus a labelled Unhide control.
- [ ] Widget test: a tile at row 0 renders no Move up control, and a tile at the last row renders no Move down control — asserted by absence of the semantics node, not by a disabled-looking pixel.
- [ ] Widget test: tapping Move up on a tile at row 0 is impossible because no target exists; there is no code path that accepts the tap and does nothing.
- [ ] Widget test: the edit-mode grid renders at `TextScaler.linear(2.0)` with the move/hide controls present and no overflow.
- [ ] Zero-animation test still passes: `tester.binding.hasScheduledFrame` is `false` after a single `pump()` following a tap on any control added here.
- [ ] Repository test: `PRAGMA foreign_keys` returns `1` on the connection under test.

## Traps

- **Swapping outside a transaction.** Two sequential `UPDATE`s with a crash or an exception between them leave one `button_id` in two slots or in none. The board is now lying about where a phrase is, forever, and no telemetry will ever say so. Wrap the read-read-write-write in `db.transaction`.
- **Reading both slots after the first write.** Read `here` and `above` *before* writing either. Read-modify-read-modify overwrites one tile with the other and destroys a phrase.
- **Moving by mutating `row_index`.** It is a primary-key column. `UPDATE ... SET row_index = row_index - 1` either collides with the row already at that coordinate or, with FK enforcement and the composite PK doing their job, throws — and the "fix" someone reaches for is a surrogate `id` or an `order` column on `grid_slots`. Both are banned. Never add a surrogate `id`, never add `order` / `position` / `index` to that table. That single change permits two rows claiming the same `(row_index, col_index)` and re-enables the exact silent reflow the schema exists to make unrepresentable.
- **Delete-then-insert as a "simpler" swap.** It removes a slot row. A board with 11 slot rows has lost a coordinate; the grid materializer will either throw or backfill from the neighbour. Slots are never deleted, only re-pointed.
- **Implementing Hide as `button_id = NULL`.** It looks identical on screen and it is unrecoverable — the coordinate forgets which phrase lived there and Unhide has nothing to restore. Hide touches `buttons` only.
- **Implementing Hide as `DELETE FROM buttons`.** Same catastrophe with an FK cascade on top. Hide is a flag.
- **A no-op Move up at row 0.** If the control renders and the handler quietly returns, the user taps and nothing happens. Silence is the worst bug this app produces, and mid-edit it teaches the user the app is broken. Do not render the control at the boundary.
- **Hiding the repair phrase.** `is_system = 1` exists so the repair phrase cannot be lost. Guard it in the repository, not only in the widget — the widget is not the enforcement boundary.
- **Forgetting `user_edited = 1`.** A moved or hidden tile that still reads `user_edited = 0` is a tile a future seed step or default-set update will happily overwrite. `user_edited = 1` is a hard stop against exactly that; a move is the user touching the tile.
- **Deriving `sortKey` from the new row/col.** Traversal order is authored: `sortKey: OrdinalSortKey(priority.toDouble())`, never inherited from layout. Moving a tile changes where a thumb finds it and deliberately does **not** change what TalkBack reads first. Do not "fix" this by computing sortKey from position — that reintroduces the row-major accident where the highest-priority phrase is the 8th-to-11th thing announced.
- **Reaching for `withClampedTextScaling` when the edit-mode controls overflow at 200%.** Banned; a source-grep test catches it. The controls must fit by layout, not by clamping the user's setting. Same for `FittedBox` and `TextOverflow.ellipsis` on any label.
- **An unlabelled icon on the move controls.** Every `Icon` gets a `semanticLabel` or an `ExcludeSemantics` wrapper. There is no third option, and an unlabelled arrow icon is invisible to a screen reader — which makes the accessible alternative to drag itself inaccessible.
- **`Card` / `elevation` / `BoxShadow` on the control chrome.** Banned on the tile permanently. Depth is the tonal ladder plus the keyline; nesting a chip inside the tile takes `inner = outer − padding` via `Geom.innerRadius`, never a second hardcoded radius.
- **A `_buildMoveButton(...)` method.** Extract a `StatelessWidget`. A method's subtree has no `Element`, cannot be `const`, and `find.byType` cannot reach it in a test — and tests are the only feedback loop this app has.
- **Capturing button content into the control's closure.** Resolve at tap time from the immutable `(row, col)`: `onTap: () => onMoveUp(slot.row, slot.col)`. A closure holding `button.id` from a previous build moves the wrong tile after a fast re-tap.
- **Adding a `GlobalKey` to make the swap "animate" or the state survive.** No `GlobalKey`, no `ObjectKey`, no animation. The slot key is `ValueKey((row, col))` and nothing else.

## Files

- `lib/data/repositories/board_repository.dart` — `moveUp`, `moveDown`, `hide`, `unhide`; bounds from the board row; `is_system` guard; all writes in one transaction.
- `lib/ui/widgets/phrase_tile.dart` — mode-dependent rendering of hidden slots; edit-mode move/hide controls; semantics.
- `lib/ui/widgets/` — new private control widget(s) for Move up / Move down / Hide / Unhide.
- `test/data/board_repository_move_test.dart` — swap, slot-count, 2×3 bounds, `user_edited`, FK pragma.
- `test/data/board_repository_hide_test.dart` — hide/unhide, slot untouched, `is_system` rejection.
- `test/ui/edit_mode_reorder_test.dart` — semantics, boundary controls absent, 200% scale, zero-animation.

## Done when

A tile can be moved up, moved down, hidden and unhidden entirely through labelled buttons that TalkBack and Switch Access can reach; every operation swaps or flags, never deletes or renumbers; and the board still holds exactly `grid_rows × grid_cols` slot rows with nothing reflowed.
