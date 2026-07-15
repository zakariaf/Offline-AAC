# data-architecture

> Phase: **research** · Agent `aef8073646b1d36c1` · Run `wf_3a8e3c64-43a`

## Result

## Summary

The AAC domain already has a data model worth stealing: the Open Board Format (OBF/OBZ, MIT, JSON, from CoughDrop/OpenAAC). Its field vocabulary (board → buttons → grid.order matrix → images/sounds, load_board for navigation) is the right shape, and I confirmed the real field list from the reference gem's source. But OBF is a partial standard: supported by CoughDrop, Cboard, Grid 3, Sensory Boards — NOT by the iOS incumbents this app targets (Proloquo2Go, TouchChat use proprietary backups). Recommendation: model internally on OBF semantics and export .obz as a portability/trust feature, not as real interop with Proloquo. On storage the 2026 landscape has consolidated: Drift is healthy (v2.34.2 published within a day of research), Isar's author went silent and forked three ways, original Hive is abandoned, Realm hit EOL Sept 30 2025. Drift wins — not for speed but for migrations and ACID atomicity on a hand-customized board. Biggest finding is a backup landmine: Android Auto Backup is on by default with a hard 25MB/app quota, and once exceeded the app stops backing up entirely — tile photos will silently blow this and destroy the backup the user believes they have. Encryption at rest needs no SQLCipher (iOS already defaults to NSFileProtectionCompleteUntilFirstUserAuthentication); the real risk is cloud backup, and for phrases like "I am being hurt" the threat model includes an abuser with access to a shared iCloud account — making a backup opt-out a safety feature, not a preference.

### Open Board Format (OBF/OBZ) is a real, MIT-licensed, JSON-based AAC interop format whose field model maps almost exactly onto this app's needs

*Confidence: high, **LOAD-BEARING***

Confirmed the actual field list by reading the reference implementation source (open-aac/obf lib/obf/external.rb). Board: id, locale, format, name, default_layout, background, url, data_url, default_locale, label_locale, vocalization_locale, description_html, license, buttons, images, sounds, grid. Button: id, label, vocalization, action, actions, left, top, width, height, border_color, background_color, load_board, translations, hidden, url, image_id, sound_id. load_board nests {id, url, data_url, path}. Image/Sound: id, width/height or duration, license, protected, url, data, data_url, content_type, path. Grid parsed via OBF::Utils.parse_grid (rows/columns/order matrix). .obz = ZIP with manifest.json {format, root, paths:{images,sounds,boards}} mapping ids to paths. Critically: 'vocalization' is separate from 'label' — the spoken text differs from the tile caption, which is exactly the adult-AAC need (tile reads 'Overwhelmed', speaks 'I need to leave, I am not able to talk right now').

- https://raw.githubusercontent.com/open-aac/obf/master/lib/obf/external.rb

- https://github.com/open-aac/obf

- https://www.openaac.org/docs.html

### OBF adoption is real but partial — and specifically absent from the incumbents this product is positioned against

*Confidence: high, **LOAD-BEARING***

Confirmed OBF import/export in CoughDrop (it is CoughDrop's native format), Cboard, Grid 3, Sensory Boards, PiCom, Talking Buttons. I could NOT find evidence that Proloquo2Go/AssistiveWare or TouchChat import OBF; AssistiveWare docs describe only their own backup formats (.p2g-style backups via AirDrop/Dropbox/iTunes). So 'import your Proloquo board' is NOT deliverable via OBF. Governance is also thin: the canonical spec is a Google Doc linked from openaac.org, not a versioned spec repo.

- https://coughdrop.zendesk.com/hc/en-us/articles/201800485-What-file-format-does-CoughDrop-use-for-import-export

- https://boards.sensoryapphouse.com/

- https://www.assistiveware.com/support/proloquo2go/protect-share/save-and-restore-selected-backups-using-other-storage-services

- https://www.openaac.org/docs.html

### The OBF reference implementation is only sporadically maintained — treat the spec as stable prior art, not a living dependency

*Confidence: high*

open-aac/obf gem commit history: most recent commit June 15 2025 (a Ruby 3 URI.escape compatibility fix merged from an outside contributor), with the prior activity dating to July 2022. Isolated maintenance, not active development. Implication: hand-roll OBF read/write in Dart against the documented field set rather than waiting for or depending on any official tooling. There is no Dart OBF library of consequence; cboard-org/react-obf is JS.

- https://github.com/open-aac/obf/commits/master

- https://github.com/cboard-org/react-obf

### Drift is the only relational Flutter DB that is unambiguously healthy in 2026

*Confidence: high, **LOAD-BEARING***

pub.dev/packages/drift: v2.34.2 published ~23 hours before this research, 2.43k likes, 160 pub points, 973k downloads, verified publisher simonbinder.eu, supports Android/iOS/Linux/macOS/Web/Windows. Built-in transactions, schema migrations, joins. Independently corroborated: 'Actively developed by Simon Binder with regular releases through 2026, and now sponsored by Stream and PowerSync' — recommended as default choice for relational data, migrations, and offline-first.

- https://pub.dev/packages/drift

- https://luci-studio.com/blog/the-flutter-local-database-landscape-in-2026-a-maintenance-first-guide-fe6d267c/

### Isar is effectively unmaintained and has fragmented into three competing forks — disqualifying for a solo dev on a decade-long accessibility tool

*Confidence: high, **LOAD-BEARING***

Original author went silent: 'long gaps between commits, no responses on the project's channels'; official v4 never reached a stable trustworthy release. Survives via at least three forks: isar_community, isar_plus (by Simon Choi), and isar_db. Guidance is explicit: 'Treat Isar and original Hive as legacy you migrate off, not platforms you build on.' Fork fragmentation is the tell — a solo dev cannot arbitrate which fork wins.

- https://luci-studio.com/blog/the-flutter-local-database-landscape-in-2026-a-maintenance-first-guide-fe6d267c/

- https://pub.dev/packages/isar_plus

- https://pub.dev/packages/isar_community

### Realm/Atlas Device SDK is dead — EOL September 30, 2025

*Confidence: high, **LOAD-BEARING***

MongoDB deprecated Atlas Device SDKs September 2024; end-of-life and no longer maintained by MongoDB as of Sept 30 2025. MongoDB officially ended mobile support that day. The client-side DB persists as unmaintained open source. Its main value was the sync layer, which this app explicitly does not want. Original Hive likewise abandoned by its author (who repositioned Isar as successor, which then also went quiet); Hive CE is a community continuation carrying higher risk. sqflite remains healthy as the raw-SQL baseline; ObjectBox is maintained but commercially backed with sync you don't need.

- https://www.couchbase.com/blog/realm-mongodb-eol-day-2025/

- https://loopcafe.substack.com/p/realm-is-deprecated-what-now

- https://luci-studio.com/blog/the-flutter-local-database-landscape-in-2026-a-maintenance-first-guide-fe6d267c/

### Android Auto Backup is ON by default, capped at 25MB per app, and silently stops backing up once exceeded — a data-loss trap for photo tiles

*Confidence: high, **LOAD-BEARING***

Apps targeting API 23+ automatically participate; android:allowBackup defaults to true. Quota is 25MB per app per user, stored in a private Google Drive folder, free, not counting against user quota, only most recent backup retained. Critical failure mode: 'once its backed-up data reaches 25MB, the app no longer sends data to the cloud.' Included by default: shared prefs, internal storage getFilesDir(), databases via getDatabasePath(), getExternalFilesDir(). Excluded by default: getCacheDir(), getNoBackupFilesDir(). 100 user photos at ~200KB = 20MB, so a modest photo board silently kills backup for the DB too. Backups run when idle + charging + Wi-Fi + >=24h since last.

- https://developer.android.com/identity/data/autobackup

### Android offers a precise privacy lever: back up app data ONLY when client-side E2E encryption is active, plus an uncapped device-transfer channel

*Confidence: high, **LOAD-BEARING***

Android 9+ supports E2E-encrypted backup using a client-side secret, requiring the user to have set a screen lock (PIN/pattern/password). dataExtractionRules (API 31+) splits <cloud-backup> from <device-transfer>, allowing different rules per channel. requireFlags="clientSideEncryption" on an <include> makes that data go to the cloud only if E2EE is on; BackupAgent can check FLAG_CLIENT_SIDE_ENCRYPTION_ENABLED. Device-transfer (D2D, e.g. Pixel new-phone setup) is a separate domain and is the recommended channel for large files exceeding the 25MB cloud quota. Pre-API-31 uses android:fullBackupContent with backup_rules.xml. Domains: root, file, database, sharedpref, external, plus device_* variants.

- https://developer.android.com/identity/data/autobackup

### On iOS, app data IS in iCloud backup by default — and under Standard Data Protection, Apple holds the keys

*Confidence: high, **LOAD-BEARING***

Files in Documents and Library/Application Support are included in iCloud backup by default; Library/Caches is not. Flutter's path_provider getApplicationDocumentsDirectory maps to NSDocumentDirectory (backed up); getApplicationSupportDirectory maps to NSApplicationSupportDirectory (also backed up, and not user-visible — the right home for a DB). Crucially: with Standard Data Protection, 'the keys to your backups are secured in Apple data centers' — Apple holds them. Only with Advanced Data Protection (opt-in) is iCloud Backup end-to-end encrypted with keys Apple does not have. Opt-out uses isExcludedFromBackup, which Apple warns 'exists only to provide guidance to the system... it's not a mechanism to guarantee those items never appear in a backup'.

- https://support.apple.com/en-us/102651

- https://support.apple.com/guide/security/security-of-icloud-backup-sec2c21e7f49/web

- https://developer.apple.com/documentation/foundation/urlresourcevalues/isexcludedfrombackup

- https://pub.dev/documentation/path_provider/latest/path_provider/getApplicationDocumentsDirectory.html

### App-level encryption (SQLCipher) is unnecessary — both platforms already encrypt app data at rest by default

*Confidence: high, **LOAD-BEARING***

iOS: NSFileProtectionCompleteUntilFirstUserAuthentication is the default class for all third-party app data not otherwise assigned, and has been since iOS 7. Even unassigned files are stored encrypted; all class keys except NSFileProtectionNone are wrapped with a key derived from device UID + user passcode, and decryption can only happen on-device with the correct passcode. Android uses file-based encryption with equivalent semantics. So a stolen powered-off phone already protects the board. Adding SQLCipher defends only against a very narrow attacker (post-first-unlock, root/jailbreak) while adding real cost.

- https://support.apple.com/guide/security/data-protection-classes-secb010e978a/web

### If encryption is ever added, the SQLCipher path is now obsolete — the guidance changed under drift 2.32.0

*Confidence: high*

Direct from drift docs: sqlcipher_flutter_libs 'is no longer necessary after upgrading to drift 2.32.0 and can be removed'; from version 0.7.0 that package no longer does anything. Current approach is NativeDatabase with SQLite3MultipleCiphers, configured via pubspec hooks: user_defines: sqlite3: source: sqlite3mc, then PRAGMA key in the setup callback. Caveats: check the `cipher` pragma at runtime to prove you're on the encrypted build, and you cannot apply PRAGMA key to an existing unencrypted DB — that needs PRAGMA rekey with a temp-file migration. That migration cost is a reason to decide encryption at v1 rather than bolt it on.

- https://drift.simonbinder.eu/platforms/encryption/

- https://pub.dev/packages/sqlcipher_flutter_libs

### SQLite's own benchmarks favor in-DB BLOBs under ~100KB, but filesystem storage is still the better call here for non-performance reasons

*Confidence: high, **LOAD-BEARING***

SQLite's intern-v-extern-blob study: 'For BLOBs smaller than 100KB, reads are faster when the BLOBs are stored directly in the database file. For BLOBs larger than 100KB, reads from a separate file are faster.' At 10KB, in-DB is 1.5-2.4x faster; at 500KB+ external wins (ratios 0.25-0.82). Recommends 8192-16384 byte page size. However: files-on-disk with paths in the DB map directly onto OBF's image.path/sound.path, allow selective exclusion from Android backup domains (impossible for rows inside one DB file), and keep the DB small enough to sit comfortably under the 25MB quota. Downscaled tile photos (<=512px JPEG q80, ~30-60KB) land in the range where the perf difference is small and cached by Flutter after first paint anyway.

- https://www.sqlite.org/intern-v-extern-blob.html

- https://developer.android.com/identity/data/autobackup

### Per-tile recorded audio is well-supported by the data model and cheap in storage — it de-risks the project's stated TTS-quality risk

*Confidence: medium, **LOAD-BEARING***

OBF already has first-class sounds (sound_id on button; sound objects with duration, content_type, data/url/path) and .obz packages audio alongside images, so recorded audio is not a schema extension — it's a spec feature. Storage math: mono AAC/m4a at ~32-48kbps is ~4-6KB/sec, so a 3-second phrase is ~12-18KB; 200 recorded phrases ~2.4-3.6MB, comfortably inside the 25MB Android quota (unlike photos). This directly addresses the stated risk 'TTS must sound acceptable' — a user or loved one can record the handful of high-stakes phrases where synthetic voice is inadequate, while TTS covers the long tail and the type-to-speak box.

- https://raw.githubusercontent.com/open-aac/obf/master/lib/obf/external.rb

- https://developer.android.com/identity/data/autobackup

### The threat model for intimate phrases includes a trusted-party adversary with cloud account access — which reframes backup as a safety decision

*Confidence: medium, **LOAD-BEARING***

This is reasoning from the product's own stated content, not a fetched source. Phrases named in the brief ('I am being hurt', medical info) imply users who may be abused by, or dependent on, someone who shares or administers their Apple/Google account — common for disabled adults with a caregiver, and for DV survivors. Under iOS Standard Data Protection, iCloud Backup keys are held by Apple and the backup is restorable by whoever controls the account. Android E2EE backup is gated on the user having a screen lock. Therefore an explicit, discoverable 'keep my board off cloud backup' toggle is an accommodation, not a power-user preference. Confidence is medium because it is an inference about user threat models, not a measured claim.

- https://support.apple.com/guide/security/security-of-icloud-backup-sec2c21e7f49/web

- https://developer.android.com/identity/data/autobackup

## Product implications

- **[must-have-mvp]** Use Drift (SQLite) as the local DB. Normalize to boards / buttons / images / sounds with a grid order matrix, and put the DB in getApplicationSupportDirectory(), not Documents.
  - Drift is the only relational option that is unambiguously maintained in 2026 (v2.34.2 shipped within a day of this research, verified publisher, Stream/PowerSync sponsorship). The decisive factors are not speed — at <2000 tiles everything is fast — but (a) first-class schema migrations for a data model users hand-customize, and (b) ACID atomicity so a crash mid-edit cannot corrupt the board a distressed user depends on. Application Support is backed up like Documents but is not user-visible in the Files app, which is correct for an internal DB.
- **[must-have-mvp]** Model the internal schema on OBF's field semantics — especially label vs vocalization as separate fields — from day one.
  - OBF's vocabulary was designed for exactly this domain and encodes a distinction the product needs: the tile caption ('Overwhelmed') differs from the spoken string ('I need to leave, I can't talk right now'). Adopting the spec's semantics internally makes export a projection rather than a lossy translation later. Costs nothing now; retrofitting label/vocalization separation after users have customized boards is a painful migration.
- **[should-have-v1]** Ship .obz export before .obz import, and describe it as 'your board is a file you own', not as Proloquo interop.
  - OBF is genuinely supported by CoughDrop, Cboard, Grid 3 and Sensory Boards — but NOT by Proloquo2Go or TouchChat, the very apps this product targets. Promising import from Proloquo would be a broken promise. Export is the honest, cheap, high-trust version: it is simultaneously the no-account backup mechanism, the anti-lock-in statement that differentiates against $299 incumbents, and a hedge if the app is ever abandoned. Import is more work (arbitrary third-party boards, symbol licensing, external URLs) and is v1-not-MVP.
- **[must-have-mvp]** On Android, set explicit dataExtractionRules: include the DB in <cloud-backup> with requireFlags="clientSideEncryption", and route the images/audio directory to <device-transfer> only.
  - Two verified facts force this. First, the 25MB quota is a silent killer — once exceeded the app stops backing up to the cloud entirely, so a user with 100 photo tiles loses the DB backup too, without any warning. Keeping media out of the cloud domain keeps the small, precious DB safely under quota. Second, requireFlags="clientSideEncryption" means board contents only leave the device if the user's own E2EE-with-screen-lock is active — which lets you make a strong privacy claim that is literally true rather than aspirational. Defaults here are wrong for this app and must be overridden deliberately.
- **[must-have-mvp]** Offer an explicit, plainly-worded 'Keep my board off cloud backup' toggle (isExcludedFromBackup on iOS, exclusion from cloud-backup domain on Android).
  - For phrases like 'I am being hurt', the realistic adversary is often someone with access to the user's Apple/Google account — a caregiver or abuser. Under iOS Standard Data Protection Apple holds the backup keys, so the board is recoverable by whoever controls the account. This is a safety accommodation for the exact population the product serves, not a settings-screen nicety. Caveat to honor honestly in the UI: Apple documents isExcludedFromBackup as guidance, not a guarantee.
- **[must-have-mvp]** Tell the truth about cloud backup rather than claiming 'nothing ever leaves the device': no account, no server, no analytics — but your board is included in the device backup you control, in your account, never ours.
  - The absolutist claim is false the moment iCloud/Google backup is on, and this audience will check. The defensible and still-excellent claim: there is no account, no server of ours, and nothing is transmitted to the developer — ever. If system backup is on (a setting the user owns), the board rides along encrypted into the user's own Apple/Google account. Being precise here is the trust asset; overclaiming and getting caught would be fatal in r/autism and AAC communities that are already burned by infantilizing, data-hungry apps.
- **[should-have-v1]** Support photos on tiles, but downscale on import (<=512px, JPEG q80) and store as files on disk with paths in the DB — never as DB BLOBs, never at original camera resolution.
  - Photos of actual family members are a major dignity/utility win over cartoon symbol sets and are a direct answer to the infantilization problem. But a 4MB camera original per tile destroys the backup story and bloats migrations. Files-with-paths mirrors OBF's image.path, enables per-directory backup exclusion (impossible for rows inside one DB file), and keeps the DB small. Acknowledged tension: SQLite's own benchmarks say sub-100KB BLOBs read faster in-DB — but backup-domain control and .obz export ergonomics outweigh a difference Flutter's image cache mostly erases after first paint.
- **[should-have-v1]** Support per-tile recorded audio, with a simple precedence rule: if a tile has a recording, play it; otherwise TTS.
  - This is the cheapest available mitigation for the brief's own top risk ('TTS must sound acceptable'). It is already in the data model (OBF sound_id), and the storage math is benign — ~12-18KB per 3-second phrase at 32-48kbps mono AAC, so ~200 phrases fit in ~3MB. It also unlocks something TTS cannot: a loved one's voice, or the user's own pre-shutdown voice, for the phrases that matter most. High emotional payoff, low technical cost, no schema churn.
- **[must-have-mvp]** Reset to the home board on every launch. Persist customization and settings; do not persist navigation state or scroll position.
  - Both sides are real: resuming saves taps for a returning user, and losing a deep board position is annoying. But the deciding case is the one the product exists for — someone mid-shutdown in an ER opens the app and must land somewhere known within one glance. Nondeterministic entry points ('why am I on the Food board?') impose cognitive load precisely when the user has none to spare. Determinism is the accommodation; tap-saving is an optimization. Mitigate the cost by putting the highest-stakes phrases on home rather than by restoring state.
- **[must-have-mvp]** Version the schema from v1 with Drift migrations, write migration tests against generated schema snapshots, and always treat user data as unmergeable ground truth on update.
  - This app's data is 100% hand-authored by a user who may be unable to speak without it — a botched migration is not a bug, it's the loss of someone's voice. Drift's schema versioning plus generated schema files make migrations testable rather than hopeful. The default-vocabulary corollary: never overwrite or 'upgrade' tiles the user has touched; ship new default content as additive, opt-in, and clearly separate from user-authored tiles.
- **[explicitly-avoid]** Do not add SQLCipher/SQLite3MultipleCiphers for MVP.
  - Both platforms already encrypt app data at rest — iOS defaults every third-party app file to NSFileProtectionCompleteUntilFirstUserAuthentication, keyed to device UID + passcode. SQLCipher would add build complexity, key-management-in-secure-storage work, and cold-start cost, while defending only a narrow attacker (post-first-unlock with root/jailbreak). The genuine exposure is cloud backup, addressed above. Note the one-way door: converting an existing unencrypted DB later requires PRAGMA rekey with temp-file migration, so if a specific threat model ever justifies encryption, decide it deliberately rather than drifting into it.
- **[explicitly-avoid]** Do not use Isar, original Hive, Realm, ObjectBox, or hand-rolled JSON files as the store of record.
  - Isar's author went silent and it has fragmented into isar_community / isar_plus / isar_db — a solo dev cannot pick a winner. Hive's author abandoned it. Realm reached EOL Sept 30 2025 and its value was the sync layer this app rejects. ObjectBox is maintained but commercial and centered on sync you don't need. Plain JSON is genuinely viable at <2000 tiles and deserves an honest mention — but it lacks atomic writes (crash mid-save corrupts the board) and turns every schema change into bespoke hand-written migration code. For a decade-lived accessibility tool maintained by one person, maintenance is the feature.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
PRODUCT IDEA UNDER RESEARCH — "Dignified offline AAC for adults & teens with situational speech loss"

Who it's for: Autistic adults and teens who go non-speaking during shutdowns/meltdowns/sensory overload, plus people with selective mutism, aphasia, or post-seizure speech loss. Communities: r/autism, r/AutisticAdults, r/selectivemutism, AAC communities.
The problem: Mainstream AAC apps are built for young children — cartoon avatars, "parental" account gates, kiddie vocabulary — infantilizing for adults, so they abandon them. Premium options (Proloquo2Go/TouchChat/LAMP) run ~$299 and are iOS-only.
Why offline is essential: It's a disability accommodation, not a networked service. The user must be able to "speak" instantly — in a shop, an ER, a car with no signal, mid-shutdown — with zero login, zero loading, full privacy.
The core job: Tap a phrase/symbol tile (or type) and the phone speaks it aloud, instantly, offline, adult-appropriate design, no account.
MVP: grid of large customizable phrase tiles + "type to speak" box + on-device TTS. Editable categories. No sign-up. Nothing leaves device. Dark, calm, adult visual design.
Risks: TTS must sound acceptable; design must feel adult without being cold; must be usable one-handed by someone in distress.
Target stack: Flutter (cross-platform iOS + Android; user prefers Flutter over React Native).
Today's date: 2026-07-15. Prefer recent sources (2024-2026).


YOUR DIMENSION: Data model, local storage, and offline-first architecture in Flutter for 2026.

Research using WebSearch and WebFetch (pub.dev, benchmarks, GitHub).

Answer specifically:
- What is the right AAC data model? Research how AAC boards are modeled: boards, buttons, grids, links, categories, vocabulary sets, "pagesets". Look at the Open Board Format (OBF / .obz) from Open AAC / CoughDrop — is it a real interop standard? Should this app import/export OBF? What about Proloquo/TouchChat/Grid proprietary formats?
- Local DB choice in Flutter 2026: Drift (SQLite), Isar (is it maintained? there were maintenance concerns — verify current status), Hive / Hive CE, ObjectBox, sqflite, Realm (Atlas Device SDK was deprecated — verify), sembast, or just JSON files. For a small phrase set (<2000 tiles) with images, what's right? Consider: cold start speed, no-network guarantee, migrations, and solo-dev maintainability.
- Backup/restore WITHOUT a server: the user has no account and nothing leaves the device — but they will get a new phone or lose the phone. How do you handle backup while keeping the privacy promise? Options: iCloud/Google Drive app-scoped backup (is it "leaving the device"?), iOS/Android automatic device backup (does app data get included by default? Documents vs Library/Caches, allowsCloudBackup / android:allowBackup), manual export to a file, AirDrop/share sheet, QR code, local file. What's the honest recommendation? What's the privacy story to tell the user?
- Does iOS automatic iCloud backup include app documents by default? Android auto-backup default behavior and 25MB limit?
- Custom images on tiles (user photos): storage, size, migration. Photos of family members etc. Should tiles support photos?
- Custom recorded audio per tile (user's own voice or a loved one's voice, or a pre-recorded phrase): is this better than TTS for some phrases? Storage implications.
- Settings/state: what persists? Should the app remember scroll position/last board? Should it RESET to home on relaunch (a distressed user should always land in a known state) — argue both sides.
- Migration/versioning strategy for a data model that users have hand-customized. What happens on app update?
- Encryption at rest: is it needed? These phrases are intimate ("I am being hurt", medical info). iOS Data Protection classes, Android encryption defaults. What's appropriate?

Give a concrete recommendation with reasoning.
````

</details>
