# E07-T02 — Editing a tile's text

| | |
|---|---|
| **Epic** | E07 — Edit mode |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E07-T01 |
| **Blocks** | E07-T03 |

**Skills:** `reed-vocabulary-rules` · `reed-drift-schema` · `reed-copy-voice`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A starter set written from intuition is a placeholder. The edit affordance is the only permission the user gets — no copy pre-authorises them, so the editor has to actually work the first time they reach for it. And once they touch a tile, that phrase is theirs: unmergeable ground truth that no seed step, migration, or default-set update may ever touch again. There is no telemetry; if an update eats a hand-curated phrase, nobody will ever learn it happened and the person it happened to cannot phone in a bug report while unable to speak.

## Scope

Tap a tile in edit mode → an editor for that tile's text. That is the whole editor for now.

**The two fields, named exactly this way in the UI:**

| UI name | column | cap | behaviour |
|---|---|---|---|
| **What you see** | `buttons.label` | **16 characters, hard** | NOT NULL. Sentence case, no terminal period. |
| **What it says** | `buttons.vocalization` | **uncapped** | Nullable; NULL ⇒ falls back to `label`. **Collapsed by default and auto-mirrors `label` until explicitly opened.** Most users never open it. |

Not "label"/"value". Not "short"/"long". The strings are `What you see` and `What it says`.

`buttons.display_text` is **out of scope** for this task — leave it NULL; it falls back to `vocalization ?? label`.

### The cap refuses; it does not truncate

The label field **refuses at 16 characters**. It does not accept-and-clip, it does not ellipsize, it does not silently drop the 17th character after the fact. An ellipsis on an AAC utterance is a **different utterance** — the tile is a *handle* for the utterance, and that is exactly what makes "never truncate" safe elsewhere in the app.

Use a `LengthLimitingTextInputFormatter(16)` on the label field only. Never put a formatter, a cap, or a counter on **What it says** — `vocalization` is uncapped by design, because it holds `I can’t talk right now but I’m okay.`

Show the remaining/used count as a plain statement, no exclamation, no error register, no colour alarm (there is no red in Reed). At the cap the field simply stops accepting input.

### Mirroring, and where it stops

While **What it says** has never been explicitly opened, it mirrors `label` live and `vocalization` is persisted as **NULL** — do not write a copy of the label into `vocalization`. NULL is the fallback the schema already specifies; writing a duplicate string means a later label edit leaves a stale vocalization behind and the tile speaks the old phrase.

The moment the user opens **What it says** and types, mirroring stops permanently for that button and `vocalization` is written for real.

### user_edited is a one-way latch

```dart
// The moment the user touches a tile, and forever after.
await (db.update(db.buttons)..where((Buttons b) => b.id.equals(id))).write(
  ButtonsCompanion(
    label: Value(label),
    vocalization: Value(vocalization), // Value(null) while mirroring
    userEdited: const Value(true),
    updatedAt: Value(clock.now()),
  ),
);
```

`buttons.user_edited` goes to 1 on the first save and **never goes back to 0**. It is a hard stop: no seed step, no migration, no default-set update, no "upgrade" pass may overwrite or reconcile that row afterwards. New default content ships **additive, opt-in, and clearly separate** — never as a merge.

### Never transform the user's phrase

The **single** sanctioned edit is straight-to-curly apostrophe normalisation (`'` → `’`), applied **on save only, never mid-typing**. Retyping a character under someone's cursor is a possession violation on a text field.

Everything else is banned: no `.toLowerCase()`, no `.toUpperCase()`, no title-casing, no capitalising the first letter "for" them, no trimming a deliberate `…`, no appending a period. Reed's strings are Reed's to style; the user's strings are theirs.

**No content filter. No profanity warning. No confirmation step. No "are you sure."** The lexicon is adult — profanity, sex, medical terms, job and community terminology. Filtering a disabled person's own speech is the paternalism this product exists to oppose.

### Copy in the editor

Lowercase chrome (`edit`, `save`, `cancel` — authored lowercase in the string table, never `.toLowerCase()`). Sentence case in semantic labels, because a screen reader speaks a sentence. No exclamation marks, no praise, no "Great", no "Saved!", no "You're all set". Second person, present, active. Never "just" or "simply".

The save-failure string, if you need one, follows state-the-fact-then-the-next-action and is **inline and non-blocking — no modal dialog, ever**:

```
✗  Your board may not have saved. Please try again later.
✓  That tile didn’t save. Tap it to edit and save again.
```

### Explicitly OUT of scope

- Colour/stock picker, image picker, sound picker, `load_board_id`.
- `display_text`.
- Moving, reordering, or swapping tiles.
- Deleting or hiding a tile (`hidden`, the NULL-the-slot path).
- Creating a new tile in an empty slot.
- Undo. **There is no undo** — you cannot unsay speech, and repair is a phrase (`Wrong one`), not a mechanism.

## Acceptance criteria

- [ ] `flutter analyze` is clean.
- [ ] Widget test: the editor's two fields are labelled exactly `What you see` and `What it says`.
- [ ] Widget test: **What it says** is collapsed on open for a button whose `vocalization` is NULL.
- [ ] Widget test: entering 20 characters into **What you see** leaves the field holding exactly 16 characters, and the 16 are the **first** 16 typed — no ellipsis character anywhere in the field or the saved row.
- [ ] Widget test: entering 200 characters into **What it says** leaves all 200 in the field and all 200 in the saved `vocalization`.
- [ ] Repository test: saving a tile where **What it says** was never opened writes `vocalization` as **NULL**, not a copy of the label.
- [ ] Repository test: saving any edit sets `buttons.user_edited` to 1.
- [ ] Repository test: a seed/default-set update pass leaves a row with `user_edited = 1` byte-identical in `label` and `vocalization`.
- [ ] Repository test: `user_edited` is never written back to 0 by any code path in `lib/` (grep plus the test).
- [ ] Test: saving `I can't talk` persists `I can’t talk` (curly). Test: typing `I can't` and reading the controller mid-typing still shows the straight apostrophe — normalisation happens on save only.
- [ ] Test: a label containing profanity saves unchanged, with no warning, no dialog, no confirmation step.
- [ ] Test: saving does not alter case and does not append a terminal period — `wtf no` round-trips as `wtf no`.
- [ ] Grep the diff for `!` in a string · `.toUpperCase(` · `.toLowerCase(` · `'` in a user-facing literal · `Sorry` · `Oops` · `Please` · `Great` · `we ` · `just ` · `simply` · `caregiver` · `parent` · `student` · `learner`. Zero unexplained hits.
- [ ] No `showDialog` / `AlertDialog` in the edit path.

## Traps

- **`LengthLimitingTextInputFormatter` on the wrong field.** Putting a cap on **What it says** is a silent content amputation of the actual utterance. The cap is 16 and it belongs to `label` alone.
- **Accept-and-clip instead of refuse.** Validating on save and calling `substring(0, 16)` looks identical in a happy-path test and is exactly the banned behaviour: the user typed a phrase and the app kept a different one. Refuse at input time.
- **Mirroring by writing a copy.** If you persist `vocalization = label` while mirroring, the next label edit leaves the old vocalization behind and the tile speaks a phrase that is no longer on it — the wrong sentence at the worst possible moment. Persist NULL and let the schema's fallback do the work.
- **The divergence tick.** `says ≠ label` shows one 6dp hairline tick, top-right, in `keyline`. That is the entire affordance. Do not render `says` under the label as small dim text — at 60% ink it is APCA Lc −39.0 on `ground`, i.e. unreadable, and it fails AA outright on `slate` (4.24:1) and `oxblood` (3.94:1). Verifying `says` belongs in edit mode, where nobody is in a shutdown.
- **Curly-quote normalisation running on every keystroke.** An `onChanged` that rewrites the controller moves the cursor under the user's finger. Normalise in the save handler.
- **`user_edited` set on open rather than on save.** Tapping a tile to look at it is not touching it; a cancelled editor must not latch the flag. But equally: do not defer the latch behind a "did anything change" diff — the flag is about ownership, not deltas.
- **A future seed step that "helpfully" backfills.** The hard stop lives in the repository, not in a comment. Any default-content path must filter `user_edited = 0` in its own `WHERE`, and the test above is the only thing that will ever catch a regression.
- **Reaching for `FittedBox` / `AutoSizeText` / `overflow: TextOverflow.ellipsis`** when a 16-char label looks tight in the preview. All three are the same bug wearing a costume. `Text(tile.label, style: theme.textTheme.titleLarge, softWrap: true)` — one uniform size for all twelve, text wraps, the user's `TextScaler` is obeyed.
- **A widget importing `package:drift`.** Unpacking rows belongs in `BoardRepository`. The editor talks to the repository.
- **`\n` in a shipped label** (`I need\na minute`) is a break *hint*. If the user's edit keeps it, keep it; if scaled text exceeds 3 lines, fall back to natural wrap. Do not strip it and do not treat it as a character the user shouldn't have.

## Files

- `lib/features/edit/tile_editor.dart` — new. The two-field editor.
- `lib/features/edit/edit_strings.dart` — new or extended. `What you see`, `What it says`, lowercase chrome, the save-failure line.
- `lib/data/repositories/board_repository.dart` — `updateButtonText(...)` writing `label`, `vocalization`, `user_edited = 1`, `updated_at`; the curly-apostrophe normalisation on save.
- `test/features/edit/tile_editor_test.dart` — new.
- `test/data/board_repository_edit_test.dart` — new. Real `NativeDatabase.memory()`, never a Map-backed fake.

## Done when

A user can tap a tile, change what it shows and optionally what it says, the 17th label character is refused rather than swallowed, and that tile is marked `user_edited = 1` and is never overwritten again.
