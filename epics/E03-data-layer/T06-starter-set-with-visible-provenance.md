# E03-T06 — Starter set with visible provenance

| | |
|---|---|
| **Epic** | E03 — Data layer |
| **Status** | Done |
| **Size** | S |
| **Depends on** | E03-T02 |
| **Blocks** | Nothing |

**Skills:** `reed-vocabulary-rules` · `reed-copy-voice` · `reed-drift-schema` · `reed-aac-audience`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

A validated adult phrase list does not exist in public sources. The only one-tap messages directly attested anywhere are *"too loud," "I need a break," "I want to go"* — everything else Reed ships on first launch is the author's guess at what an autistic adult will need to say mid-shutdown. Pre-filling someone's voice is presumptuous; a starter set that arrives anonymous reads as **correct**, and deviating from something correct reads as **error**. Provenance on every line converts a presumption into a gift, and marks the whole set as a placeholder to be replaced by contact with actual part-time AAC users.

## Scope

### 1. A `const` Dart list, not a JSON asset

Seeds live at **`lib/data/seed/starter_phrases.dart`** as a `const` list. Not an asset, not JSON, not YAML. A missed `pubspec.yaml` entry would make first launch an **empty board, silently** — no crash, no telemetry, no bug report from a person who cannot speak. A `const` list that does not exist is a compile error at 10am; a missing asset is an empty grid at 2am.

### 2. Every phrase carries machine-readable provenance

Comments are not enough — the provenance page is built from this data, so provenance is a **field**, not a decoration. Both: a field the page reads, and a comment the next reader sees.

```dart
enum Evidence {
  /// Directly attested as a participant one-tap message.
  attested,
  /// Implied by participant testimony, not attested as a one-tap message.
  implied,
  /// The author's own. Unvalidated. Replace after user contact.
  assumption,
}

class StarterPhrase {
  const StarterPhrase({
    required this.label,
    required this.says,
    required this.stock,
    required this.evidence,
    required this.dated,
    required this.note,
    required this.priority,
    this.isSystem = false,
  });

  final String label;      // ≤16 chars, hard. No terminal period. Curly ’.
  final String says;       // uncapped. Full sentence, normal punctuation.
  final Stock stock;
  final Evidence evidence;
  final String dated;      // '2026-07'
  final String note;       // first person, shown on the provenance page
  final int priority;      // → OrdinalSortKey(priority). NOT layout position.
  final bool isSystem;     // repair only
}
```

`display_text` is not in `StarterPhrase`: every starter ships `display_text = NULL`, which falls back to `vocalization ?? label`. The column still exists from day one (E03-T02) — retrofitting it after boards are curated is a migration across unmergeable data.

### 3. The twelve

Twelve phrases. Labels ≤16 characters, sentence case, curly apostrophes (`’`), **no terminal period**. `says` is a full sentence and takes normal terminal punctuation.

| # | label | says | evidence |
|---|---|---|---|
| 1 | `Too loud` | `It’s too loud in here.` | attested |
| 2 | `I need a break` | `I need to take a break.` | attested |
| 3 | `I want to go` | `I want to go now.` | attested |
| 4 | `Can’t talk` | `I can’t talk right now but I’m okay.` | implied |
| 5 | `Only sometimes` | `I can talk, but only sometimes.` | implied |
| 6 | `Can’t say it` | `I can’t tell you what I need right now.` | implied |
| 7 | `Wrong one` | `Sorry — that wasn’t what I meant to say.` | assumption (repair) |
| 8 | `I need\na minute` | `I need a minute.` | assumption |
| 9 | `Yes` | `Yes.` | assumption |
| 10 | `No` | `No.` | assumption |
| 11 | `Text me instead` | `Text me instead of talking. I can read.` | assumption |
| 12 | `Not an emergency` | `I’m not in danger. I just can’t speak right now.` | assumption |

Rows 1–3 are the only attested one-tap messages in any public source. Rows 4–6 trace to participant testimony (*"I can talk, but only sometimes"*, *"Just because I can say some of the things and even sound fluent, that doesn't mean I can tell you what I need."*) but were never attested as one-tap messages. Rows 7–12 are the author's own and must be tagged `Evidence.assumption`, dated `2026-07`, and marked for replacement.

Shape of each entry — the comment above the line says the same thing the field says, because the comment is for the next reader and the field is for the page:

```dart
const List<StarterPhrase> kStarterPhrases = <StarterPhrase>[
  // attested (participant one-tap message) · 2026-07
  StarterPhrase(
    label: 'Too loud',
    says: 'It’s too loud in here.',
    stock: Stock.slate,
    evidence: Evidence.attested,
    dated: '2026-07',
    note: 'One of only three one-tap messages I found directly attested by a '
        'part-time AAC user. I did not write this one.',
    priority: 1,
  ),
  // ASSUMPTION — author’s own, unvalidated · 2026-07 · replace after user contact
  StarterPhrase(
    label: 'Wrong one',
    says: 'Sorry — that wasn’t what I meant to say.',
    stock: Stock.oxblood,
    evidence: Evidence.assumption,
    dated: '2026-07',
    note: 'There is no undo. You cannot unsay speech, so repair is something '
        'you say. Replace the wording if mine is not yours.',
    priority: 4,
    isSystem: true,
  ),
];
```

`I need\na minute` ships a literal `\n` as a **break hint** — ragged text strands words and Flutter has no text-balance. It is a hint only: if scaled text exceeds 3 lines, the tile falls back to natural wrap. It is 15 characters.

### 4. Repair is a phrase, at a fixed position

`Wrong one` / `Sorry — that wasn’t what I meant to say.` / `Stock.oxblood` / `is_system = 1`. Its slot is declared once:

```dart
/// Row 3, column 1 (0-indexed) on the 3-col × 4-row default board:
/// the lower-centre thumb arc, row-major traversal position 11 of 12.
const ({int row, int col}) kRepairSlot = (row: 3, col: 1);
```

Fixed position and **replaceable like any other tile** — `is_system = 1` makes it undeletable, not uneditable. Do not build an undo stack, a special control, or a modal. Cancelling speech is a cancel: tapping the lit tile stops it. That needs no vocabulary. `oxblood` is a paper stock at OKLCH C 0.026, not an alarm — **there is no red in Reed**.

### 5. Stock assignment

Four stocks across twelve tiles, each appearing about three times, **scattered by category, never by rank**. Two are pinned by the skills: `Too loud` → `Stock.slate`, `Wrong one` → `Stock.oxblood`. Assign the rest per *category* (speech-status · exit/sensory · response · repair) using the `Stock` enum as E03-T02 defines it — do not invent a stock name. Assignment is stable forever. A category's colour must never imply a category's position, and a lighter tile must never mean a more important tile: that is a salience hierarchy and it is banned. Colour is a redundant assist; **position is the retrieval mechanism**.

### 6. Author the traversal order with the set

`priority` is authored from the phrase's importance, **not from where it lands in the grid**, and becomes `sortKey: OrdinalSortKey(priority)`. The highest-value phrases sit in the lower-centre arc for the thumb, which puts them 8th–11th in row-major traversal — 8–11 seconds under linear autoscan at 1s/step. Inheriting traversal from layout by accident is not a decision.

### 7. Zero-config launch

The seed is applied inside `beforeOpen`'s `if (details.wasCreated)` branch and **only** there. `PRAGMA foreign_keys = ON` runs **unconditionally, outside** that branch — it is per-connection.

```dart
beforeOpen: (OpeningDetails details) async {
  await customStatement('PRAGMA foreign_keys = ON'); // UNCONDITIONAL
  if (details.wasCreated) {
    await seedStarterBoard(this); // and ONLY here
  }
},
```

Seeding writes the root board (`grid_rows: 4`, `grid_cols: 3`, `is_root: true`), twelve `buttons` rows, and **exactly twelve `grid_slots` rows** — a board always holds exactly `grid_rows × grid_cols` slot rows. All twelve seeded buttons carry `hidden = 0` and `user_edited = 0`; the repair phrase carries `is_system = 1`.

Cold launch goes **straight to the Speak screen with the set already usable**. No splash, no onboarding gate, no login, no modal, no network wait, **never a wizard**. The install may itself BE the crisis. If a starter-set picker ever exists it is a dismissible strip on the grid, skippable in one tap — never a gate.

### 8. Provenance copy

This task authors the strings; another task renders them. First person, named author, saying who wrote these and why. Keep the line **"a starting point, not a prescription"** — it is a statement about the thing, not permission granted to the user. Ship it as a static page reachable from the grid, **never modal**.

Never ship:
- **A byline that changes to `Yours.` once the user edits.** That is the app noticing you did a thing and commenting approvingly. It is a gold star with better kerning.
- **"Most people replace half of them in the first week."** Telling someone what most people do so they know they are normal is reassurance nobody asked for. The edit affordance is the permission.

Use the field's own terms in the page: **part-time AAC use**, **intermittent** / **unreliable** / **insufficient** speech. Never "non-verbal", never "loses their voice", never "goes mute", never "backup for when speech fails".

### Out of scope

- The provenance **screen** widget and its route (this task ships `StarterPhrase.note` and the page's authored consts; someone else renders them).
- The first-launch `TextPainter` measurement that picks 12 vs 6 tiles.
- Any starter-set picker UI.
- Post-crisis phrase capture.
- Any default-set *update* path. New default content ships additive, opt-in, clearly separate — it is not this task.

## Acceptance criteria

- [ ] `lib/data/seed/starter_phrases.dart` declares `const List<StarterPhrase> kStarterPhrases` with exactly 12 entries. `grep -r 'starter' pubspec.yaml` returns nothing — there is no asset.
- [ ] Test: every `label` in `kStarterPhrases` has `label.characters.length <= 16`.
- [ ] Test: no `label` ends with `.`; no `label` or `says` contains `'` (U+0027) or `!`.
- [ ] Test: `kStarterPhrases.where((p) => p.evidence == Evidence.attested)` is exactly the three attested phrases; every entry has a non-empty `note` and `dated == '2026-07'`.
- [ ] Test: exactly one entry has `isSystem == true`, its label is `Wrong one`, and its stock is `Stock.oxblood`.
- [ ] Test: `kStarterPhrases.map((p) => p.priority).toSet().length == 12` — priorities are unique.
- [ ] Test: no `Stock` value appears more than 4 times or fewer than 2 times across the twelve.
- [ ] Test against `NativeDatabase.memory()`: opening a fresh DB yields `SELECT COUNT(*) FROM grid_slots` == 12, `SELECT COUNT(*) FROM buttons` == 12, and the slot at `(row 3, col 1)` holds the button whose `is_system = 1`.
- [ ] Test against `NativeDatabase.memory()`: opening a fresh DB, then closing and reopening it, still yields 12 buttons — the seed does not re-run on the second open.
- [ ] Test: `SELECT COUNT(*) FROM buttons WHERE user_edited != 0 OR hidden != 0` == 0 on a fresh DB.
- [ ] Policy test (grep over `lib/data/seed/` and the provenance consts): zero hits for `caregiver`, `parent`, `guardian`, `student`, `learner`, `progress`, `Great`, `Oops`, `Please`, `just `, `simply`, `.toUpperCase(`, `.toLowerCase(`, `non-verbal`, `mute`.
- [ ] `dart analyze` is clean.

## Traps

- **Shipping the list as `assets/starter_phrases.json`.** It looks tidier and it is the single failure this task exists to prevent: forget the `pubspec.yaml` entry and first launch is an empty board, with no exception, no telemetry, and a user who cannot speak. `const` or nothing.
- **Writing twelve confident phrases from intuition and calling it done.** This is the highest-risk shortcut available in the project. Twelve *dated, attributed* phrases cost one comment per line. The three attested ones are attested; the other nine are yours, and the file must say so.
- **Presenting counts as rates in the provenance copy.** Write "12 of 12" or "10 of 12", never "most users" or "research shows". Twelve self-selected people are not a population estimate. And check whether an apparently multiply-confirmed claim traces back to that same sample — it usually does.
- **Putting `PRAGMA foreign_keys = ON` inside `if (details.wasCreated)`.** Correct for the seed, catastrophically wrong for the pragma: it is per-connection, so every subsequent open runs with FKs off, `onDelete: setNull` silently does nothing, and a deleted button leaves a dangling `button_id` forever.
- **Seeding 12 buttons but fewer than 12 `grid_slots` rows** — e.g. inserting slots only where a button exists. An empty cell is a row with `button_id IS NULL`, not an absent row. A board that returns fewer than `rows × cols` slots has lost a coordinate.
- **Reaching for a surrogate `id` or an `order` column on `grid_slots` to express "the repair tile is at position 11".** It is at `(board_id, 3, 1)`. That is the key. Adding an ordering column re-enables reflow, and reflow means a real person taps a remembered position and says the wrong sentence out loud.
- **Deriving `priority` from the loop index while inserting.** Then traversal order is layout order by accident and the autoscan story is unauthored. `priority` is a hand-written field on every entry.
- **A straight apostrophe smuggled in by the editor's autocomplete** — `can't` instead of `can’t`. It renders as a database dump. The test greps for U+0027 for exactly this reason; do not weaken it to a warning.
- **Deciding `\n` counts as one character against the 16 cap without writing it down.** `I need\na minute` is 15 either way, but the next label will not be. Encode the answer in the length test so the editor and the seed agree.
- **A `Stock` chosen because a phrase feels urgent.** `Wrong one` is `oxblood` because oxblood is the repair category's stock, not because repair is alarming. There is no red in Reed, and a lighter tile must never read as a more important tile.
- **Softening the assumption tags before release** because "ASSUMPTION" looks unfinished in a source file someone might read. It is not unfinished; it is the honest state of the evidence, and the tag is what makes the page a gift instead of a presumption.
- **Adding a thirteenth phrase because it seems obviously useful.** Twelve is the board. A thirteenth has no slot and the seed will silently drop it or overflow — write the test that asserts `length == 12` before you write the list.

## Files

- **Creates** `lib/data/seed/starter_phrases.dart` — `Evidence`, `StarterPhrase`, `kStarterPhrases`, `kRepairSlot`, and the provenance page's authored consts.
- **Creates** `lib/data/seed/seed_starter_board.dart` — `seedStarterBoard(AppDatabase db)`: root board + 12 buttons + 12 grid_slots.
- **Creates** `test/data/seed/starter_phrases_test.dart` — the content and policy assertions.
- **Creates** `test/data/seed/seed_starter_board_test.dart` — the `NativeDatabase.memory()` seeding assertions.
- **Changes** the database class from E03-T02 — calls `seedStarterBoard` inside `beforeOpen`'s `if (details.wasCreated)` branch, below the unconditional pragma.

## Done when

A fresh install opens straight onto twelve usable tiles, every one of which can name in the source who wrote it, when, and on what evidence.


---

## What actually happened

12 phrases as a const Dart list (no asset), seeded in onCreate so it runs once per file and never overwrites a user board. Every label <=16 runes, curly apostrophes, no terminal periods, no bangs. Exactly three attested phrases with provenance; one system repair phrase (Wrong one, oxblood, at row 3 col 1). Stocks 3/3/3/3. Fresh-DB seeding and no-reseed-on-reopen both tested. Required moving Stock to the model layer (re-exported from tokens) so the seed could name it without importing UI.
