# data-architecture--android-offers-a-precise-privacy-lever-back

> Phase: **verify** · Agent `a0184cc263df62b3a` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Android 9+ does back up app data E2E-encrypted with a client-side secret derived from the user's screen lock, and dataExtractionRules (API 31+) does split <cloud-backup> from <device-transfer> with independent rules. But the encryption gate in that format is disableIfNoEncryptionCapabilities="true", an attribute on the <cloud-backup> element that gates the WHOLE cloud channel — not requireFlags="clientSideEncryption" on an <include>, which belongs to the legacy <full-backup-content> format and is ignored once the app points at android:dataExtractionRules on Android 12+. So the lever is real but coarse (all-or-nothing per channel), not "precise" per-include. FLAG_CLIENT_SIDE_ENCRYPTION_ENABLED via BackupAgent.transportFlags remains the correct way to get per-item precision — that is the actual precise lever, and it requires a custom BackupAgent. Separately, there is no documented evidence that device-transfer is "uncapped"; the 25 MB quota is documented only for cloud backup and Google is silent on D2D limits. Google's documented path for oversized backups is the Large Backups API Program (allowlist), not D2D. Also add: the schema now includes <cross-platform-transfer platform="ios"> (Android 16 QPR2+), and there is no device_external domain.

Product note for this AAC app: the simplest privacy-correct posture is android:allowBackup="false", or a dataExtractionRules file with an empty/omitted <cloud-backup> and a permissive <device-transfer>. That gives "phrase tiles survive a new phone, nothing ever reaches Google Drive" with no dependence on the contested specifics above — and it matches the "nothing leaves device" promise better than conditioning cloud upload on E2EE, since E2EE backups still leave the device and still depend on the user having a screen lock (users in the target population may not).

**Evidence:** CONFIRMED sub-claims (all verified against developer.android.com/identity/data/autobackup):
- "The backup is end-to-end encrypted on devices running Android 9 or higher using the device's PIN, pattern, or password" — E2EE requires backup enabled + a screen lock set. Correct.
- dataExtractionRules is API 31+ and does split <cloud-backup> from <device-transfer>, with per-channel rules. Correct. (Doc now also shows a third element the claim omits: <cross-platform-transfer platform="ios"> plus FLAG_CROSS_PLATFORM_TRANSFER_IOS, added in Android 16 QPR2.)
- FLAG_CLIENT_SIDE_ENCRYPTION_ENABLED is real and checkable via data.transportFlags in BackupAgent.onBackup(), alongside FLAG_DEVICE_TO_DEVICE_TRANSFER. Correct.
- 25 MB per-app cloud quota, stored in a private Google Drive folder, not counting against user Drive quota; onQuotaExceeded() on overflow. Correct.
- Pre-API-31 uses android:fullBackupContent → res/xml/backup_rules.xml with <full-backup-content>. Correct.
- Domains root/file/database/sharedpref/external + device_root/device_file/device_database/device_sharedpref. Correct — but note there is NO device_external.

DEFECT 1 (load-bearing — the mechanism named does not exist in the format they'd use). The claim says: 'requireFlags="clientSideEncryption" on an <include> makes that data go to the cloud only if E2EE is on' and presents this as part of the dataExtractionRules lever. It conflates two mutually exclusive XML formats. requireFlags is an attribute of the OLD <full-backup-content> format (Android 9–11 / apps targeting API ≤30). The API 31+ <data-extraction-rules> schema does NOT accept requireFlags on <include>/<exclude>; the documented schema is include/exclude with only domain and path. The API 31+ equivalent is disableIfNoEncryptionCapabilities="true|false", an attribute on the <cloud-backup> ELEMENT — i.e. an all-or-nothing gate on the entire cloud channel, not a per-<include> filter. Per developer.android.com/about/versions/12/backup-restore: "Your app can set the disableIfNoEncryptionCapabilities flag in the <cloud-backup> section to make sure the backup happens only if it can be encrypted, such as when the user has a lock screen." This matters concretely: once the app points at android:dataExtractionRules, android:fullBackupContent is IGNORED on Android 12+, so a requireFlags attribute written into the new file is silently inert. Shipping in 2026 means targeting API 35/36, so requireFlags is the wrong lever. The claim's headline word "precise" is also wrong — the real API-31+ lever is coarser (whole-channel), not per-include.

DEFECT 2 (unsupported). "Uncapped device-transfer channel" and D2D being "the recommended channel for large files exceeding the 25MB cloud quota" is not stated anywhere in Google's documentation. The 25 MB figure is documented ONLY for cloud backup; the docs are simply silent on a D2D cap. Silence is not an exemption — this is the researcher's inference presented as fact. Google's actual documented answer for large data is a separate thing the claim never mentions: the Android Large Backups API Program (developer.android.com/identity/data/large-backups), an allowlist program. Independent developer write-ups (e.g. Jacob Ras, "Hidden pitfalls in Android Backup", 2023) explicitly flag this as unresolved: "I don't know if the limit in that scenario is also 25 MB... I couldn't find any source stating the opposite."

DEFECT 3 (minor). The claimed source URL only supports part of this. The requireFlags→disableIfNoEncryptionCapabilities migration lives on the Android 12 backup-restore page, not the autobackup page cited. Confidence "high" on a single-source claim that contradicts a second primary page is overstated.

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

CLAIM: Android offers a precise privacy lever: back up app data ONLY when client-side E2E encryption is active, plus an uncapped device-transfer channel
THEIR DETAIL: Android 9+ supports E2E-encrypted backup using a client-side secret, requiring the user to have set a screen lock (PIN/pattern/password). dataExtractionRules (API 31+) splits <cloud-backup> from <device-transfer>, allowing different rules per channel. requireFlags="clientSideEncryption" on an <include> makes that data go to the cloud only if E2EE is on; BackupAgent can check FLAG_CLIENT_SIDE_ENCRYPTION_ENABLED. Device-transfer (D2D, e.g. Pixel new-phone setup) is a separate domain and is the recommended channel for large files exceeding the 25MB cloud quota. Pre-API-31 uses android:fullBackupContent with backup_rules.xml. Domains: root, file, database, sharedpref, external, plus device_* variants.
THEIR CLAIMED SOURCES: https://developer.android.com/identity/data/autobackup
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
