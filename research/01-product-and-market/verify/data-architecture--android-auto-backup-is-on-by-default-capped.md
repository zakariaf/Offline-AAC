# data-architecture--android-auto-backup-is-on-by-default-capped

> Phase: **verify** · Agent `a149cf754354f40aa` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Android Auto Backup is ON by default for apps targeting API 23+ (android:allowBackup defaults to true), capped at 25MB per app per user, and when exceeded the system stops uploading that app's data with no notification to the user — a real data-loss trap for photo tiles, since the 25MB is an app-wide aggregate so images crowd out the phrase database. Three corrections: (1) as of July 7, 2026, Android backup app data DOES count against the user's Google Account/Google One storage (the autobackup developer page's "does not count toward the user's personal Google Drive quota" line is stale; the Google One help page and the Large Backups API doc both state it now counts) — rolling out to new backup users July 7, 2026 and existing accounts over the following months; (2) backups require backup-enabled + >=24h since last + idle + Wi-Fi — charging is NOT a condition; (3) the stoppage is not permanent — the system periodically re-checks and resumes Auto Backup once data falls back under 25MB, and onQuotaExceeded() only fires for apps with a custom BackupAgent, so a plain Auto Backup app gets no developer signal either.

**Evidence:** I checked the claim against the primary source (developer.android.com/identity/data/autobackup), the companion Large Backups API doc, and the Google One storage help page.

WHAT CONFIRMS (verbatim from the primary doc):
1. Default-on: "Apps that target Android 6.0 (API level 23) or higher automatically participate in Auto Backup." android:allowBackup — "The default value is true, but we recommend explicitly setting the attribute in your manifest." CONFIRMED.
2. 25MB quota: "Every app can allocate up to 25 MB of backup data per app user." CONFIRMED, and it is an aggregate per-app figure, so photo tiles genuinely do crowd out the SQLite DB. The researcher's core architectural point survives.
3. Include/exclude lists: CONFIRMED exactly as stated — shared prefs, getFilesDir()/getDir(), getDatabasePath() (incl. SQLiteOpenHelper), getExternalFilesDir() are in; getCacheDir(), getNoBackupFilesDir() are out. The doc also excludes getCodeCacheDir(), which they omitted (harmless).
4. Only most recent backup retained: "Only the most recent backup is stored. When a backup is made, any previous backup is deleted." CONFIRMED.

WHAT BREAKS:
A. "Free, not counting against user quota" — REFUTED as of 8 days ago. The autobackup page still says "The saved data does not count toward the user's personal Google Drive quota," but that page is STALE. Effective July 7, 2026, Google began counting all Android backup data — app data explicitly included — against Google Account storage. The Google One help page now lists "App data" under data managed through Android backup settings that consumes the 15GB shared quota. Google's own Large Backups API doc corroborates this with a comparison table listing Auto Backup's storage impact as "Counts toward Google One quota." Rollout: new backup users from July 7, 2026; existing accounts "in the coming months." Two Google docs currently contradict each other; the newer two win. Note this cuts AGAINST the researcher's framing — it makes photo tiles worse, not better, since they now eat the user's paid storage.
B. "Charging" is NOT a backup condition. The doc lists exactly four: backup enabled on device, >=24h since last backup, device idle, device on Wi-Fi (unless opted into mobile data). No charging/plugged-in requirement. Minor, but they asserted it as fact.
C. "Silently stops backing up" is OVERSTATED on permanence. The doc: "If the amount of data is over 25 MB, the system calls onQuotaExceeded() and doesn't back up data to the cloud. The system periodically checks whether the amount of data later falls under the 25 MB threshold and continues Auto Backup when it does." So it is self-healing once the user deletes photos — not a permanent kill. It IS silent to the USER (no notification), and onQuotaExceeded() only fires for apps implementing a custom BackupAgent, so a plain Auto Backup app gets no signal at all. The "silent" adjective is fair; "stops" implying permanent is not.
D. Their arithmetic is directionally fine but note 100 photos x 200KB = 20MB is UNDER the 25MB cap on its own — it only trips the quota once the DB and prefs are added. Not the clean "20MB kills it" they imply.

BOTTOM LINE FOR THE PRODUCT DECISION: the data-architecture conclusion (do not let user photos ride Auto Backup; keep the phrase DB small and backed up, exclude images via getNoBackupFilesDir() or a custom backup rules XML, offer explicit user-initiated export) is SOUND and now MORE urgent given the July 2026 quota change. The claim should not be cited with the "free / doesn't count against quota" line or the "charging" condition.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "data-architecture". A product decision depends on it, so it must be right.

CLAIM: Android Auto Backup is ON by default, capped at 25MB per app, and silently stops backing up once exceeded — a data-loss trap for photo tiles
THEIR DETAIL: Apps targeting API 23+ automatically participate; android:allowBackup defaults to true. Quota is 25MB per app per user, stored in a private Google Drive folder, free, not counting against user quota, only most recent backup retained. Critical failure mode: 'once its backed-up data reaches 25MB, the app no longer sends data to the cloud.' Included by default: shared prefs, internal storage getFilesDir(), databases via getDatabasePath(), getExternalFilesDir(). Excluded by default: getCacheDir(), getNoBackupFilesDir(). 100 user photos at ~200KB = 20MB, so a modest photo board silently kills backup for the DB too. Backups run when idle + charging + Wi-Fi + >=24h since last.
THEIR CLAIMED SOURCES: https://developer.android.com/identity/data/autobackup
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
