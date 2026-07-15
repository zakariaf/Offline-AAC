# E09-T01 — Export and import

| | |
|---|---|
| **Epic** | E09 — Portability and the crash log |
| **Status** | Not started |
| **Size** | M |
| **Depends on** | E03-T02 |
| **Blocks** | Nothing |

**Skills:** `reed-drift-schema` · `reed-privacy-claims` · `reed-error-model` · `reed-copy-voice`

> Read these skills first. They carry the exact values this task must hit.

## Why this exists

`allowBackup="false"` plus explicit `dataExtractionRules` means the board never reaches Google Drive — and it also means that when the phone dies, the board dies with it. The database lives in `getApplicationSupportDirectory()`, app-private, unreachable by any file manager. Without a user-initiated export there is no backup story at all, and the privacy promise turns into a data-loss promise. This is the clause that buys the sentence *"phrase tiles survive a new phone; nothing ever reaches Google Drive"* — durability is served by making export obvious in settings, not by an invisible upload the user never asked for.

The import half carries a harder rule: a board is months of hand-curated phrases, it is unmergeable, and there is no merge better than leaving someone's phrase alone. Import must never write over a tile the user has touched.

## Scope

Two concrete final classes — `lib/data/board_export.dart` and `lib/data/board_import.dart` — plus two settings controls. Both classes take `AppDatabase` and the media helper; neither is an interface, neither has a DAO wrapper.

### 1. The file format

A zip. Inside it, mirroring Open Board Format — whose semantics the schema already borrows for field names:

```
manifest.json          { "format_version": 1, "reed_version": "<pubspec version>", "exported_at": "<ISO 8601>", "root": "boards/<id>.json" }
boards/<id>.json       one per board row
images/<n>.jpg         the media file bytes
sounds/<n>.<ext>
```

Each board JSON carries the board row (`name`, `locale`, `grid_rows`, `grid_cols`, `is_root`), a `buttons` array, and a grid block:

```json
"grid": {
  "rows": 3,
  "columns": 4,
  "order": [[1, 2, null, 3], [4, null, 5, 6], [7, 8, 9, 10]]
}
```

`order` is **exactly `rows × columns`** entries. A `null` is an empty slot — a real cell that holds its coordinate — and it must serialize as `null`, never be omitted, never be compacted out. That array is the on-disk form of `PRIMARY KEY (board_id, row_index, col_index)`; a file that drops nulls is a file that reflows the board on the way back in.

Every button carries all three text fields as separate keys — `label`, `vocalization`, `display_text` — never collapsed into one. `vocalization: null` means *falls back to label*, and that null is meaningful; do not resolve the fallback at export time. Also carried: `hidden`, `is_system`, `user_edited`, `background_color`, `border_color`, `image_id`, `sound_id`, `load_board_id`, `created_at`, `updated_at`.

`images` entries carry `path` (the in-zip path, e.g. `images/3.jpg`), `content_type`, `width`, `height`, `license`, `attribution`. Symbol-set attribution travels with the board or the board is a licence violation on the other phone.

**`settings` is not exported.** Not `voice_id`, not `rate`, not `pitch`, not `theme`. A `voice_id` from another phone does not resolve on this one, and the schema's own note on that path is the single most likely real-world silent failure: `NoVoiceSelected`, discovered by a user mid-shutdown who tapped a tile and got nothing. Portability of the board is the goal; portability of a device-specific voice handle is a bug with a nice name.

### 2. Export

- Build the zip in the **cache/temp directory**, hand it to the system share sheet, delete the staging file when the sheet closes.
- Media bytes are copied out of the documents directory, resolved through the one helper that owns the documents base (`media_store.dart`). Never hand-build a media path here. Never join a media path against the support directory — that is where the DB lives, and the two bases are not interchangeable.
- Exported media is already ≤512px / JPEG q80 / ~30–60KB because `media_store.dart` downscales at import. Do not re-encode on the way out; do not ship an original.
- Hidden buttons **are exported**. `hidden = 1` is not deleted; a round trip that drops hidden buttons destroys content the user chose to keep.
- Filename: `reed-board-YYYY-MM-DD.zip`.

### 3. Import

The rule that shapes everything: **import creates a new board. It never writes into an existing one.** Ship an imported board the same way new default content ships — additive, opt-in, clearly separate. There is no merge UI, no conflict picker, no "keep mine / keep theirs", no per-tile diff. Those are all ways of asking a user to authorise damage.

In one `transaction`:

1. Parse and validate the whole file **before any write** (see the rejection list below).
2. Insert new `boards` rows. Insert `images` / `sounds` rows for the bundled media, writing bytes through `media_store.dart` and storing the path **relative to the documents directory**.
3. Insert `buttons` with **freshly generated ids**. Keep a `Map<int, int>` from file-local id → new DB id. Never insert with the id from the file.
4. Allocate `grid_rows × grid_cols` slot rows per board and fill `button_id` from the remap table — `null` where `order` had `null`. Update slot rows; never insert a second row for a coordinate.
5. Remap `image_id`, `sound_id` and `load_board_id` through the same tables.
6. Set `is_root = 1` on the imported root board and `is_root = 0` on the previous root.

Step 6 is the only thing that changes about the board the user already had, and it changes nothing inside it: every button, every slot, every `user_edited = 1` survives untouched, and switching back in settings restores it exactly. Because nothing is overwritten, this path needs no `backup.dart` copy — the old board *is* the backup.

After the transaction commits, run `PRAGMA foreign_key_check`. It must return zero rows.

**Reject the whole file, write nothing, on any of:**

| condition | why |
|---|---|
| `format_version` absent, not an int, or > 1 | A newer file that parses "well enough" imports a subset and silently drops fields |
| `order` length ≠ `rows`, or any row length ≠ `columns` | The coordinate set is wrong; there is no safe repair |
| an id in `order` with no matching button | Dangling coordinate |
| a `label` longer than **16 characters**, or absent/null | The editor refuses at 16 and never silently truncates. Import gets the same rule; an ellipsis on an AAC utterance is a *different utterance* |
| more than one `is_system` button in a board | `is_system` is undeletable. A file setting it on every button hands the user a board they cannot edit |
| `load_board_id` chaining more than one level, or forming a cycle | The schema is one level only |
| a zip entry path that is absolute or contains `..` | Zip slip — a crafted archive writing outside the app container |
| a media entry whose bytes are absent from the zip | Renders blank forever, with no error and no telemetry |

### 4. Failure handling

Import failures are **environment failures**, not `speak()` failures: `on FormatException`, `on ArchiveException`, `on SqliteException`, `on FileSystemException`. Catch with an `on` clause at the call site, map to inline copy.

**Do not add a second sealed vocabulary.** The error model names exactly one sealed type — `SpeakOutcome` — because every `SpeakFailure` resolves the same way (show the words) and the compiler is the only thing that can enforce that. Import has a user in front of it who can pick a different file. No `ImportOutcome`, no generic `Result<T>`.

The settings controls must not wire a `Future`-returning method to a callback. `onTap: () => importer.import(f)` is flagged by **no lint** — not `discarded_futures`, not `unawaited_futures`, not `@useResult` — because the arrow closure returns the Future and the target type is `VoidCallback`, so the Future and its error both vanish. Both controls call a **void-returning** controller method that owns the `unawaited(...)` + `catchError` internally, the same shape as `SpeechController.speakNow`.

### 5. Copy

Reed's chrome is lowercase and authored lowercase in the string table — never a text transform. Settings entries, in the register of `Keep my board off cloud backup` and `Restore previous board`:

```
Export my board
Import a board
```

Nothing about where the file goes once the share sheet has it. No "back up to Drive" shortcut, no cloud destination suggestion — the export is plaintext, it contains phrases like *"I am being hurt,"* and the adversary this audience has is frequently someone with access to their phone account.

Results and errors — statement, then the next action. No apology, no "we", no exclamation mark, no hedging, no ellipsis, no **modal dialog**, ever:

```
✓  Board imported. The board you had is still here — switch back in settings.
✓  That file isn’t a Reed board. Pick another file.
✓  That board needs a newer version of Reed. Update Reed, then import again.
✓  That board didn’t import. Nothing on this phone changed.
✓  That export didn’t finish. No file was created.
```

Curly apostrophes. Engine codes, zip entry names, `SqliteException` text and JSON offsets go to the log line, never to the surface.

### Out of scope

- **Import from a URL. Any http/https scheme, anywhere in this path.** It reopens every store question — sharing, moderation, UGC — and it puts a socket in an app whose central claim is that it has none.
- Board sharing, cloud sync, a "send to a friend" affordance.
- The crash log itself, and any copy inviting a user to send one. That copy is forbidden until redaction exists and is tested.
- A merge mode, a conflict resolver, a dry-run preview, a partial import.
- Importing another vendor's `.obf`/`.obz`. The format borrows OBF semantics; it does not claim OBF compatibility, and nothing in the copy or the listing may say it does.
- `backup.dart` / restore-previous-board — that path exists and is not this one.

## Acceptance criteria

- [ ] `dart analyze` is clean.
- [ ] `grep -rniE "http://|https://|Uri\.parse|HttpClient" lib/data/board_import.dart lib/data/board_export.dart` returns nothing.
- [ ] The merged Android manifest contains **no** `android.permission.INTERNET`. A test reads the merged manifest and asserts its absence, and the same test still asserts the `<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>` block is present.
- [ ] `grep -rn "package:drift" lib/ui/` returns nothing — the settings controls call the controller, not the importer.
- [ ] `grep -rniE "ImportOutcome|Result<|sealed class Import" lib/` returns nothing.
- [ ] Round-trip test, against `NativeDatabase.memory()`: seed a 3×4 board with 12 buttons, empty **two** slots, hide one button, export, import into a fresh DB, and assert every remaining tile sits at its **original `(row, col)`** — assert each coordinate, not the count.
- [ ] Round-trip test: the two empty slots come back as slot rows with `button_id IS NULL` at their original coordinates. Not vanished, not collapsed, not backfilled by a neighbour. The imported board holds exactly `grid_rows × grid_cols` slot rows.
- [ ] Round-trip test: the hidden button exists with `hidden = 1` after import.
- [ ] Round-trip test: `user_edited = 1` survives the round trip on the buttons that carried it.
- [ ] Round-trip test: text is byte-identical. Use a fixture with `’`, `…`, `—`, an emoji, and a literal `\n` break hint, and assert equality on all three of `label`, `vocalization`, `display_text` — with three distinct strings per button so a field swap cannot pass.
- [ ] Round-trip test: a button with `vocalization == null` still has `vocalization == null` after import (the fallback was not resolved at export).
- [ ] Import test: importing into a DB that already holds a user-edited board leaves **every row of the old board bit-for-bit unchanged** — same button ids, same `user_edited`, same `label`/`vocalization`/`display_text`, same slot occupancy. Only `is_root` differs.
- [ ] Import test: the imported buttons have ids that do not collide with the existing board's ids, and every `grid_slots.button_id` in the new board points at a row that exists.
- [ ] Import test: `PRAGMA foreign_keys` returns `1` on the connection the importer uses, and `PRAGMA foreign_key_check` returns zero rows after the import commits.
- [ ] Rejection tests, one per row of the rejection table. Each asserts the DB row counts for `boards`, `buttons` and `grid_slots` are **identical before and after** the attempt.
- [ ] Redaction test: import a file containing the phrase `I need to leave, I'm not able to talk right now`, force a parse failure at that offset, and assert those characters never appear in the crash log file bytes. Same test with a forced `SqliteException`.
- [ ] Media test: after import, `images.path` is relative — assert `!p.isAbsolute(row.path)` and that no stored path contains the temp/cache directory or a container UUID. Assert the file resolves under the **documents** directory, not the support directory.
- [ ] Export test: the staging file is deleted after the share sheet call returns, and no file is written under the documents directory at any point during export.
- [ ] Zip-slip test: an archive with an entry named `../../evil.txt` is rejected and no file exists outside the app container.
- [ ] Copy test / grep on the strings added by this task: no `!`, no `.toUpperCase(`, no `.toLowerCase(`, no straight `'` in a user-facing literal, no `Sorry`, `Oops`, `Please`, `we `, `just `, `simply`, `parent`, `caregiver`. No `showDialog` in this path.

## Traps

- **Compacting `order`.** `order.where((e) => e != null)` or building the array from returned rows only. It looks tidy and it is a reflow: the tile that lived at (2,1) for a year moves, the user reaches for it mid-shutdown from muscle memory and says the wrong sentence to a stranger, with no way to verbally correct it. The export must emit `rows × columns` entries with nulls in place.
- **Reusing file-local ids as DB primary keys.** Inserting a button with the id from the file either collides with an existing row or — worse — succeeds against a fresh sequence and lines the slots up with the *wrong* buttons. Remap through a `Map<int, int>` and never insert an explicit id.
- **"Smart" import.** Matching an incoming button to an existing one by label, offering to update it, reconciling `user_edited` tiles. `user_edited = 1` is a hard stop: never overwrite, never "upgrade", never reconcile — not in a migration, not in a seed, not here. User data is unmergeable ground truth. If a design requires a merge, the design is wrong.
- **`FormatException.toString()` contains the source text.** `jsonDecode` on a malformed board file throws with the offending JSON *in the message* — which is the user's phrases. `SqliteException.toString()` embeds the statement text, same problem. `CrashLog.record` is exportable and a user mailing it to a maintainer leaks the sentence they say when they cannot speak. Redact **inside `record`**, not at these call sites: call-site discipline fails silently the first time someone interpolates an exception whose `toString()` embeds a phrase.
- **Writing an absolute media path into `images.path`.** The import temp directory is gone within seconds, and the container UUID changes on the next restore anyway. The DB row survives, the file survives, and the tile renders blank forever with no error and no telemetry. Store relative to documents; resolve to absolute at read time.
- **Joining a media path against the support directory.** The DB file lives there; media does not. Two bases are deliberately in play and the wrong one fails silently, permanently, invisibly.
- **Staging the export in the documents directory.** It leaves a plaintext copy of every phrase in app storage indefinitely, and on iOS `Documents` is in iCloud backup by default — the export feature quietly undoing the backup promise it exists to replace. Cache dir, then delete.
- **A dependency that drags in `INTERNET` through manifest merger.** The share-sheet or file-picker package can merge a permission into the final manifest without a line of your code changing. No INTERNET is the strongest asset the product has — OS-enforced, pre-install-visible on the listing, verifiable without trusting Reed. Any dependency that could open a socket is a claim-breaking change, not a routine one. Read the *merged* manifest, not the source one, and assert it in a test.
- **Foreign keys are OFF unless the connection turns them on, and drift does not.** With FKs off, a slot pointing at an unremapped button id does not error — SQLite silently accepts it. The board renders blank or the join throws, later, on someone else's phone.
- **A non-transactional import.** A failure halfway through leaves half a board and a live `is_root` flag pointing at it. Parse and validate everything first; write in one `transaction`.
- **Truncating a long label on import.** Never. The editor refuses at 16 characters and never silently truncates, and an ellipsis on an AAC utterance is a different utterance. Reject the file and say so.
- **Trusting `is_system` from the file.** One crafted board and every tile is undeletable. At most one per board.
- **Exporting `settings`.** A `voice_id` from the old phone does not resolve on the new one, and the failure is `NoVoiceSelected` — discovered by a user who tapped a tile and got silence. Android garbage-collects voice data between launches anyway; a stale voice id is the last thing to make portable.
- **Dropping hidden buttons at export** because they "aren't on the board". Hide is not delete. A round trip that loses them destroys content the user deliberately kept.
- **Copy that oversells the file.** "Your board is safely backed up" is a claim about a file the app no longer controls the moment the share sheet takes it. Say what the app did, not what the destination will do — the same discipline as *declare* in the voice filter.
- **A confirmation modal before import.** No modal dialogs, ever. A modal demands a decision from someone whose decision-making is exactly what is impaired, and blocks the one screen they opened the app to use. Import is non-destructive by construction; that is what earns the right to have no modal.
- **`onTap: () => importer.import(file)`.** Caught by no lint. The Future and its error both vanish, and the user taps import and nothing happens — silence, the worst bug class here. Callbacks call void methods.

## Files

- Creates: `lib/data/board_export.dart`
- Creates: `lib/data/board_import.dart`
- Creates: `lib/data/portable_board.dart` (the file-format DTOs and their validation — hand-written, `@immutable` + `final class`, no `freezed`)
- Creates: `test/data/board_roundtrip_test.dart`, `test/data/board_import_reject_test.dart`, `test/data/board_export_test.dart`
- Creates: `test/policy/no_internet_permission_test.dart`
- Changes: the settings screen — two controls, wired to void-returning controller methods
- Changes: `pubspec.yaml` — share-sheet and file-picker packages, each audited against the merged manifest
- Reads: `lib/data/board_repository.dart`, `lib/data/media_store.dart`, `lib/data/database/app_database.dart`

## Done when

`flutter test` proves a board survives export and import with every tile at its original coordinate and every empty slot still empty, an import into a DB holding a user-edited board leaves that board bit-for-bit unchanged, and the merged manifest still declares no INTERNET permission.
