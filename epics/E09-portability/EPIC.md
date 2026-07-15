# E09 — Portability and the crash log

> A user-initiated export that carries a whole board to a new phone, a manifest that keeps that board out of Google Drive, and a bounded on-device log that is the only field signal this product will ever have.

| | |
|---|---|
| **Status** | Not started |
| **Tasks** | 3 |
| **Depends on** | E01 (E09-T02 on E01-T01 — the manifest and its policy test; E09-T03 on E01-T06 — the handlers in `main()` that call `record`), E03 (E09-T01 on E03-T02 — export reads the board through `BoardRepository`, never raw drift) |

## Why this epic exists

The two strongest facts about Reed are that it has no account and no server. They are the privacy claim, and they are also the reason a board is one dropped phone away from gone. There is no sync to fall back on, no "log in on the new device," no support inbox that can recover it. Six months of hand-curated phrases — someone's voice, unmergeable, irreplaceable — live in one SQLite file in the app support directory, and the default Android behaviour that would preserve them is `android:allowBackup="true"`, which uploads that file to Google Drive. That default is unacceptable here for a reason that is not abstract: a board holds phrases like *"I am being hurt,"* and a phrase like that implies an adversary who is frequently the person with access to the user's Google account. So the epic takes the durability obligation away from the platform and hands it to the user: backup off, export visible in settings, and the export is the migration path. A durability feature the user cannot see is not a trade this app gets to make on their behalf.

The crash log is the same argument pointed inward. Nobody will ever learn that Reed crashed in the field. A user who cannot speak does not file a bug report, and there is no analytics SDK and never will be — a crash reporter is the tempting fix precisely because it looks like the fix. The on-device log is what is left: bounded, synchronous, flushed, incapable of throwing, and redacted, because it is exportable and `record` will happily capture a vocalization. A log that leaks *"I need to leave, I'm not able to talk right now"* into a maintainer's inbox has converted the one diagnostic into a disclosure.

## What "done" means

- Export writes a file the user chose the location of, and a round-trip test proves it: seed a board with a full grid including at least one empty slot, export, wipe, import, and assert every tile is at the same `(row_index, col_index)` — empty slot still empty, not collapsed, not backfilled by its neighbour.
- Import never overwrites a `user_edited = 1` tile. A test writes a user-edited tile, imports a payload targeting the same coordinate, and asserts the user's row is untouched.
- Media referenced by an export resolves after import on a different documents directory — paths in the payload are relative, and a test that swaps the documents base still renders both images.
- `flutter test test/policy` passes with a test asserting `android:allowBackup="false"` in `android/app/src/main/AndroidManifest.xml` and an explicit `dataExtractionRules` with an empty `<cloud-backup>` and a permissive `<device-transfer>`.
- No copy anywhere says "nothing leaves your device," and no copy promises iCloud/Google exclusion as a certainty. The settings control reads `Keep my board off cloud backup`.
- A redaction test writes a `SpeakFailure` carrying a known phrase, calls `record`, and asserts the phrase's characters never appear in the log file's bytes.
- The log is size-bounded: a test writes past the cap and asserts the file stops growing and the newest entry survives.
- `record` cannot throw: a test points it at an unwritable path, calls it, and asserts no exception escapes.
- Export and import are reachable from settings without a modal, a dialog, or a bottom sheet, and every failure string is inline and non-blocking.
- Nothing under `lib/` outside the data layer imports `package:drift` — the exporter reads `BoardGrid`, and the existing policy grep proves it.

## The tasks

| id | title | size | depends on |
|---|---|---|---|
| E09-T01 | Export and import | M | E03-T02 |
| E09-T02 | Backup configuration | S | E01-T01 |
| E09-T03 | The on-device crash log | S | E01-T06 |

**E09-T01 — Export and import.** This is the whole answer to "what happens when the phone dies," and it is the only answer, because E09-T02 deliberately removes the other one. It reads through `BoardRepository` — the join that materializes `BoardGrid` already exists there, and no widget and no exporter imports `package:drift`. The payload carries coordinates, not order, because the schema's entire position-is-identity argument evaporates the moment a serializer emits a list and a deserializer re-indexes it. It carries `label`, `vocalization` and `display_text` as three distinct fields, and media as paths relative to the documents directory. Import is where the `user_edited` hard stop is enforced a second time, in a code path a migration test does not cover. Errors here are inline and non-blocking and state the fact then the next action; there is no modal and no apology.

**E09-T02 — Backup configuration.** Small, and it is the task that makes a sentence in the store listing true. `android:allowBackup="false"` plus explicit `dataExtractionRules` buys *"phrase tiles survive a new phone; nothing ever reaches Google Drive"* — and only buys it once the manifest actually says so, which is why the policy grep from E01-T05 is the deliverable rather than a code review. The settings control is worded `Keep my board off cloud backup` and is blunt on purpose: for a user whose adversary is someone with the phone's account password, euphemism costs them the control, and phrasing it as an optimisation or burying it under "advanced" is the failure. Do not improve this by conditioning cloud upload on end-to-end encryption — E2EE backups still leave the device and still assume a screen lock this population may not have. Off is the stronger promise.

**E09-T03 — The on-device crash log.** `CrashLog.open()` is already the first line of `main()` from E01-T06; this task fills in what `record` does. Four properties, all load-bearing: synchronous and `flush: true` (a buffered write loses exactly the startup crash you needed), size-bounded (nothing is watching the disk fill), redacted **inside `record`** rather than at the call sites, and incapable of throwing. The bare `catch (_)` is the single licensed silent catch in the codebase and its comment is the safeguard — it runs inside `FlutterError.onError` and `PlatformDispatcher.instance.onError`, so a throw re-enters the handler and recurses until the app dies. It also unwraps `ProviderException` to its cause before logging, or every entry reads `ProviderException` and the one diagnostic that exists is destroyed. Test this harder than the tiles.

## Skills this epic draws on

**Data and schema**
- `reed-drift-schema` — the invariants the payload format must preserve: position as the primary key, an empty cell as a row with `button_id IS NULL`, the `label` / `vocalization` / `display_text` split, `user_edited` as a hard stop, media paths relative to the documents directory and never absolute.

**Privacy and claims**
- `reed-privacy-claims` — the banned "nothing leaves your device" sentence, the approved three-clause wording, the backup rules (`allowBackup="false"` + explicit `dataExtractionRules`), the iOS asymmetry, and the rule that the log is a privacy artifact before it is a diagnostic.
- `reed-store-and-legal` — why export is not sharing: a local-only field is not UGC, and any import-from-URL flips that instantly and drags Apple 1.2 in whole.
- `reed-policy-tests` — the ~10-line grep that keeps `allowBackup="false"` true forever, read through `xmlOf` so the rule's own comment cannot fail the rule.

**Errors**
- `reed-error-model` — `SpeakFailure.logLine` versus `spokenText` and why they are separate members, redaction inside `record`, the licensed bare catch, `ProviderException` unwrapping.
- `reed-no-silent-failures` — typed `on` clauses around every import/export write, `rethrow` never `throw e`, no dropped Future in a settings toggle callback.
- `reed-app-startup` — where `CrashLog.open()` sits in the sequence and why nothing may precede it.

**Copy**
- `reed-copy-voice` — `Keep my board off cloud backup`, export/import failure strings that state the fact then the next action, no "we", no apology, no modal.

## The shape of the promise

Three sentences have to stay simultaneously true, and this epic is what keeps them that way:

| The sentence | What has to be true in the repo |
|---|---|
| "Phrase tiles survive a new phone." | E09-T01 exists, is visible in settings, and round-trips coordinates and media. |
| "Nothing ever reaches Google Drive." | E09-T02's manifest says `allowBackup="false"` with explicit `dataExtractionRules`, and a policy grep keeps saying it. |
| "There is no analytics SDK and no crash reporter." | E09-T03 is the entire replacement, and the banned-imports test is what stops the replacement from being replaced. |

Drop any one and the other two become either false or unaffordable. That is why the three sit in one epic despite sharing no code.

## Sequencing

There is no chain inside this epic. All three tasks depend on work outside it and on nothing here, so all three can run in parallel the moment E01 and E03-T02 are in. Nothing in the project blocks on any of them, which makes this the epic that gets deferred — and deferring E09-T02 in particular means every build shipped to a tester has been uploading boards to Drive, which is a claim the listing already makes and a promise already broken by the time anyone checks.

The one real ordering constraint is against E08: both E09-T01's export entry point and E09-T02's toggle land on the settings screen, so build them behind whatever E08 exposes rather than inventing a second surface. And E09-T03's redaction test must exist before any copy invites a user to send a log — that copy does not get written first and backfilled.

## Risks specific to this epic

- **The exporter reintroduces ordering.** A JSON array of tiles is the natural serialization and it is the one shape the schema spent its whole design budget making unrepresentable. A list plus an index on import is a reflow with extra steps: the user presses the square they always press and says the wrong sentence. Emit coordinates.
- **Absolute media paths in the payload.** The DB stores relative; a serializer that resolves to absolute "for convenience" produces a file that imports cleanly onto a new device and renders every image blank forever, with no error and no telemetry. The container path is the thing that changed — that is the entire point of the export.
- **The wrong base directory.** Media is relative to the documents directory; the database file lives in the support directory. Joining a media path against the support base fails silently, permanently, invisibly.
- **Import "reconciling" user edits.** Merge logic looks reasonable at the code-review altitude and is a data-loss bug. There is no merge better than leaving someone's phrase alone.
- **Redaction at the call site instead of inside `record`.** Call-site discipline fails the first time someone interpolates an exception whose `toString()` embeds the phrase — a drift statement, a `PlatformException.message` echoing the utterance. `record` is the choke point; scrubbing there covers handlers nobody wrote yet.
- **Someone "fixes" the licensed bare catch.** Converting it to a rethrow or a log-to-the-same-file makes the error handler's error re-enter the error handler. The comment is the only thing standing between the codebase and that recursion; deleting it during a cleanup is the plausible failure.
- **A privacy sentence written before the manifest backs it.** `allowBackup="false"` is a claim-enabling change, not a routine one. Check the manifest before shipping the sentence, not after — this audience reads the permissions list adversarially and one caught overclaim is unrecoverable.
- **Import-from-URL as an obvious extension.** It is not an extension. It creates a counterparty, converts a local text field into UGC, and drags in moderation, reporting, blocking and a re-rating. It is a policy decision with an engineering component, not the reverse.

## Out of scope

- **The database file copy before `onUpgrade`, and "Restore previous board"** — that is E03-T05. It is protection against a migration bug, not against a lost phone; the two are complements and neither is a reason to skip the other.
- **The migration tests that prove rows survive a version bump** — E03-T04. The export round-trip proves a different thing and does not substitute for either direction.
- **The settings screen itself** — E08. This epic contributes two controls to it, not a surface.
- **`main()`'s error handlers and their ordering** — E01-T06. This epic implements what `record` does once the handlers already call it.
- **Cloud sync, board sharing, an account** — not deferred, ruled out. Each one reopens every store question in `reed-store-and-legal` and breaks the strongest claim the product has.
- **A crash reporter, Sentry, Crashlytics, any analytics SDK** — banned. The absence of field signal is the cost of the privacy promise, and the on-device log is the whole compensation.
