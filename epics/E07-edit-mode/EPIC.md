# E07 — Edit mode

> A visible toggle, a two-field form that refuses at 16 characters, explicit move and hide controls, and nothing else — the editor that fits in one screen because every feature it turns down is a feature the incumbent shipped.

| | |
|---|---|
| **Status** | Not started |
| **Tasks** | 4 |
| **Depends on** | E05 (the grid and the tile widget it edits), E03 (the schema the edits land in) |

## Why this epic exists

The board only works if it is the user's board. The starter set is twelve dated assumptions written by one person who is not the user — a validated adult phrase list does not exist in public sources, and only three of the twelve are attested anywhere. Without an editor, the app ships someone else's guesses as someone's voice. The edit affordance *is* the permission; no copy is allowed to grant it.

And this is where the product dies if it dies. The editor is the surface with unlimited appetite: once you can change a tile you can obviously add a tile, and then you need somewhere to put it, and then you need a second board, and then categories, and then a category picker, and then a symbol library, and then you are the incumbent — thousands of symbols deep, with a grid nobody in a shutdown can navigate. Every scope refusal in this epic is load-bearing. There is no version of "just one more affordance" that is free.

The third stake is data. Edits are unmergeable ground truth: `user_edited = 1` is a hard stop that no seed step, no default-set update, and no migration may cross. There is no telemetry and no server. If this epic writes to the wrong slot, or lets a delete reflow the grid, or overwrites a phrase someone curated for months, nobody will ever learn it happened — and the person it happened to cannot phone it in while unable to speak.

## What "done" means

- `edit` is reachable as a labelled, focusable control on the speak screen. `grep -rn 'onLongPress\|onDoubleTap\|onPan\|Draggable\|Dismissible\|ReorderableGridView' lib/` is empty.
- In edit mode, an empty slot is a full target — keyline, a `+`, full semantics. In speak mode the same slot is `ExcludeSemantics` and appears in no traversal. One test asserts both, per mode.
- The editor form shows **"What you see"** and **"What it says"**. `says` is collapsed and mirrors `label` until explicitly opened.
- A test types a 17th character into the label field and asserts the field still holds 16 — refused at the boundary, never truncated after the fact, never ellipsized.
- A test edits a tile and asserts `buttons.user_edited == 1`, and that a subsequent default-set seed leaves the row untouched.
- A test hides a tile and asserts the row still exists with `hidden = 1`; a test deletes a button and asserts its `grid_slots` row survives with `button_id IS NULL` and **every other slot's `(row_index, col_index)` is unchanged**.
- A move is asserted as a write of two `button_id` values across two fixed slot rows — never an ordering recompute, never a row delete-and-insert.
- `flutter test test/ui` passes the edit-mode surface at `TextScaler.linear(2.0)`; `grep -rn 'withClampedTextScaling\|textScaleFactor\|FittedBox' lib/` stays empty.
- Every editor control has a `semanticLabel` a screen reader can act on, and the whole edit → change → exit loop is walked once on a real device with TalkBack and once with Switch Access.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E07-T01 | The edit mode toggle | S | E05-T02 |
| E07-T02 | Editing a tile's text | S | E07-T01 |
| E07-T03 | Reorder and hide | S | E07-T02 |
| E07-T04 | Editor accessibility | S | E07-T03 |

**E07-T01 — The edit mode toggle.** A visible mode switch: a labelled control that changes the screen, lowercase chrome (`edit`), never a hidden gesture. Long-press is banned outright here and the reason is not taste — it collides with dwell-style assistive input, where holding *is* ordinary activation, and it is an invisible state machine nothing on screen describes. The toggle also flips the one behaviour E05-T05 deliberately left mode-dependent: the empty slot's `ExcludeSemantics` lifts and the socket becomes a real target with a keyline and a `+`. Get that flip wrong in either direction and you either burn twelve scan steps on nothing in speak mode, or ship an editor a switch user cannot reach a single empty slot in.

**E07-T02 — Editing a tile's text.** Two fields, which is the whole content model: `label`, hard-capped at 16 characters, and `says`, uncapped, defaulting to `label`. They are named "What you see" and "What it says" — not label/value, not short/long — and `says` stays collapsed and auto-mirroring until someone opens it, because most users never will. The cap is enforced by refusal at 16, not by silent truncation and not by an ellipsis: an ellipsis on an AAC utterance is a different utterance. This task is also where `user_edited = 1` gets written and where the no-content-filter rule is either honoured or quietly broken — no profanity warning, no confirmation, no "are you sure", and no capitalising the first letter for someone. Straight-to-curly on save is the single sanctioned edit to a user's string, and it happens on save, never under a live cursor.

**E07-T03 — Reorder and hide.** Both operations, expressed as writes that cannot reflow. Position is the primary key: `grid_slots` is keyed `(board_id, row_index, col_index)` with a nullable `button_id`, so a move is two `button_id` writes into two slots that already exist, and hide is `buttons.hidden = 1` on a row that stays where it is. Removing content is never a reason to destroy it; deleting, if it happens at all, deletes the *button* and lets `onDelete: setNull` empty the slot in place. The controls are explicit and visible — `Draggable`, `LongPressDraggable`, `ReorderableGridView`, and `Dismissible` are all banned, because an accidental drag silently repoints muscle memory and the user speaks the wrong sentence on the worst day of their week, out loud, with no way to verbally correct it.

**E07-T04 — Editor accessibility.** The editor is the surface most likely to ship inaccessible, because it is the surface nobody imagines being used in a crisis — and that is exactly the reasoning that produces an editor only a sighted touch user can operate. Every control gets `Semantics(button: true)` and a real label; every icon is labelled or explicitly excluded; the form survives 200% text without a clamp. The parts automation genuinely cannot reach — a focus trap in the form, exiting edit mode with a switch, the scan highlight against every palette — are walked by hand or they are not covered at all, and this task says which is which rather than letting a green suite imply coverage it does not have.

## Skills this epic draws on

**Content and copy**
- `reed-vocabulary-rules` — the `label`/`says`/`display_text` split, the 16-character cap and the refuse-don't-truncate rule, `user_edited` as a hard stop, no filtering, no generation, no phrase transforms.
- `reed-copy-voice` — "What you see" / "What it says", lowercase chrome, no apology, no praise, no "are you sure", no byline that changes once the user edits.

**Data**
- `reed-drift-schema` — position as the primary key, the nullable `button_id`, `hidden` and `user_edited`, delete-the-button-not-the-slot, `PRAGMA foreign_keys` being what makes `setNull` real.

**Surface and correctness**
- `reed-tile-anatomy` — the empty slot as ground with no semantics in speak mode and a full `+` target in edit mode; the divergence tick as the only affordance for `says ≠ label`.
- `reed-widget-conventions` — a visible toggle instead of a gesture, `GestureDetector` + `HitTestBehavior.opaque`, no `Draggable`/`Dismissible`, drift row classes rather than a hand-rolled mirror.
- `reed-a11y-coding` — `Semantics(button: true)` with a display label, labelled or excluded icons, `boldText` from context, no clamp anywhere near the form.
- `reed-a11y-testing` — `isSemantics` not the deprecated `containsSemantics`, `await expectLater` on any guideline, and the honest statement that focus traps in edit mode are verified by hand or not at all.

## Sequencing

A hard chain, end to end: T01 → T02 → T03 → T04. This is unusual for this repo and it is real, not managerial. T02 cannot start against a placeholder toggle because the mode flag is what decides whether a slot is a target at all, and T03's controls live inside the surface T02 builds. T04 is last because it audits the finished surface; the semantics it asserts are authored inside T01–T03 as they are written, never bolted on afterwards — if T04 is doing original work rather than proving it, the three tasks before it were done wrong.

Nothing in this epic blocks anything outside it. That is the trap. An epic that blocks nothing is an epic that slips, and the thing that slips is the only mechanism by which the board stops being a stranger's twelve guesses.

The one external dependency worth naming: E05-T05 must have made the empty slot's semantics exclusion mode-dependent rather than unconditional. If it hardcoded `ExcludeSemantics`, T01 is a change to E05's tile, not an addition to it.

## Risks specific to this epic

- **Scope creep with a plausible face.** "Add a tile" needs a slot; a full board needs a second board; a second board needs a picker. Each step is individually reasonable and the destination is the product this app exists to be an alternative to. The refusal has to happen at the first step, because none of the later ones look like the mistake.
- **An `order` or `position` column added to make reordering easier.** It makes reordering easier and it permits two rows claiming the same `(row_index, col_index)`. No test and no crash surfaces it. It manifests only as a real person saying the wrong sentence out loud. If a change to this epic requires a surrogate key on `grid_slots`, the change is wrong.
- **Delete implemented as a row delete on `grid_slots`.** Loses the coordinate and invites the reflow the schema exists to make unrepresentable. Delete the button; the slot survives, empty, in place.
- **`PRAGMA foreign_keys` off on the connection under test.** `onDelete: setNull` is the entire mechanism behind delete, and with FKs off SQLite does not error — it silently does nothing. The slot keeps pointing at a deleted row and the tile renders blank forever.
- **A seed or default-set update that "upgrades" edited phrases.** `user_edited = 1` is the only thing standing between a curated board and months of someone's voice being replaced by better-written strangers' guesses. Additive and opt-in, or not at all.
- **Silent truncation at 16.** `maxLength` on a `TextField` that accepts-and-clips, or an `ellipsis` in the preview, turns a refusal into a different utterance without ever going red.
- **A modal.** A dialog to confirm an edit, a save, a delete, or a phrase is a decision demanded from someone whose decision-making is the impaired thing — and it blocks the one screen they opened the app to use. Inline, non-blocking, no exceptions.
- **Long-press as the toggle.** It is the default instinct for "enter edit mode", it collides with dwell input, and it is unreachable by switch and screen-reader users entirely.
- **An editor gesture with no button equivalent.** Any behaviour reachable by touch must be reachable by a labelled, focusable control, or it is not reachable by half this audience.
- **`.toLowerCase()` or `.toUpperCase()` in the editor.** A transform written for chrome survives into a path that renders a user's phrase, and then the app lowercases someone's name. No lint catches that day.

## Out of scope

- **Adding, deleting, or creating tiles beyond what a fixed 12 slots hold, and any second board.** There are twelve sockets. Filling an empty one is T01's `+`; there is no board management, no category, no subcategory, no `load_board_id` navigation in v1. This is a refusal, not a deferral.
- **A symbol or image picker.** `buttons.image_id` and the `images` table exist in E03 and stay unused here. Media import, downscaling, and relative-path handling are E03's `media_store.dart`, not an editor feature.
- **Undo.** There is none, by design. You cannot unsay speech, and repair is a phrase the user says — `Wrong one` is one of the twelve starters, fixed in position and replaceable like any other tile. An undo stack is a bystander's fear of the user built as a primitive.
- **Post-crisis phrase capture.** The pull-only "add what you needed to say and couldn't" affordance. It is passive and always-present, never a prompt, a badge, a notification, or a timed check-in — and it is its own surface, not a button in this editor.
- **The starter phrases and their provenance page.** E03. This epic edits whatever twelve strings arrive and never comments on the fact that they were edited.
- **The grid, the tile widget, and the lit state.** E05. This epic changes a mode flag those widgets already read.
- **Settings — palette, voice, the 12-or-6 layout.** E08. Editing a phrase and configuring the app are different jobs, and merging them is the first step toward a settings screen that is also a board manager.
- **Backup and restore.** `backup.dart` and "Restore previous board" are E03. They outrank every test in this epic for the failure nobody enumerated, and they are still not edit mode.
