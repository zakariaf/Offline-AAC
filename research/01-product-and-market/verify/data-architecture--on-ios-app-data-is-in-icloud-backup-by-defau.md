# data-architecture--on-ios-app-data-is-in-icloud-backup-by-defau

> Phase: **verify** · Agent `ac5d121a6b99cf23f` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Evidence:** All four load-bearing components independently verified against primary sources; no element was outdated, overstated, or invented.

1) KEY CUSTODY (verbatim match). Apple Platform Security guide, "Security of iCloud Backup": the iCloud Backup service key "is securely backed up to iCloud Hardware Security Modules in Apple data centers," classified as available-after-authentication data. Apple support 102651 uses the researcher's exact quoted phrasing: "When iCloud Backup is enabled, the keys to your backups are secured in Apple data centers," and states Apple "can decrypt your data on your behalf whenever you need it, such as when you sign in on a new device, restore from a backup, or recover your data after you've forgotten your password." Standard data protection is confirmed as the DEFAULT setting. The ADP contrast also holds: under Advanced Data Protection the iCloud Backup service key is rotated and end-to-end encrypted, and "your trusted devices retain sole access to the encryption keys." ADP is confirmed as an optional/opt-in setting.

2) DIRECTORY BACKUP BEHAVIOR (confirmed). Per Apple's data-storage guidelines and developer forums: Documents is "automatically backed up by iCloud"; Library/Application Support content "is persisted and included in the iCloud and iTunes backups"; Library/Caches and tmp are excluded from backups by the system.

3) PATH_PROVIDER MAPPINGS (confirmed against pub.dev primary docs). getApplicationDocumentsDirectory maps to "NSDocumentDirectory on iOS and macOS." getApplicationSupportDirectory maps to "NSApplicationSupportDirectory on iOS and macOS" and is documented "Use this for files you don't want exposed to the user." The docs independently corroborate the researcher's architectural recommendation, explicitly steering non-user-generated data to getApplicationSupportDirectory: use it "if the data is not user-generated."

4) isExcludedFromBackup CAVEAT (verbatim match). Apple: the resource value "exists only to provide guidance to the system about which files and directories it can exclude; it's not a mechanism to guarantee those items never appear in a backup or on a restored device." Apple further notes the property can be reset to false by common operations on user documents, so it should not be used on user documents.

MINOR NUANCE (does not refute, strengthens the recommendation): the "not user-visible" framing for Application Support is conditional rather than absolute — Documents is only user-visible when the app sets UIFileSharingEnabled / LSSupportsOpeningDocumentsInPlace. This makes Application Support the correct DB home for the reasons given.

PRODUCT IMPLICATION the researcher's own source supports but stopped short of stating: because Apple explicitly disclaims isExcludedFromBackup as a guarantee, the exclusion flag alone cannot underwrite this AAC app's "nothing leaves device" accommodation promise. On-device encryption of the phrase DB (e.g. SQLCipher, key in Keychain with ThisDeviceOnly accessibility so it is not itself carried in backup) is the defensible mechanism; isExcludedFromBackup is defense-in-depth on top. OWASP MASTG-TEST-0215 reaches the same conclusion: mark-as-excluded is not protection; encrypt sensitive data.

Verdict: claim is accurate, current as of 2026-07-15, and correctly sourced. Their stated "high" confidence is warranted.

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

CLAIM: On iOS, app data IS in iCloud backup by default — and under Standard Data Protection, Apple holds the keys
THEIR DETAIL: Files in Documents and Library/Application Support are included in iCloud backup by default; Library/Caches is not. Flutter's path_provider getApplicationDocumentsDirectory maps to NSDocumentDirectory (backed up); getApplicationSupportDirectory maps to NSApplicationSupportDirectory (also backed up, and not user-visible — the right home for a DB). Crucially: with Standard Data Protection, 'the keys to your backups are secured in Apple data centers' — Apple holds them. Only with Advanced Data Protection (opt-in) is iCloud Backup end-to-end encrypted with keys Apple does not have. Opt-out uses isExcludedFromBackup, which Apple warns 'exists only to provide guidance to the system... it's not a mechanism to guarantee those items never appear in a backup'.
THEIR CLAIMED SOURCES: https://support.apple.com/en-us/102651, https://support.apple.com/guide/security/security-of-icloud-backup-sec2c21e7f49/web, https://developer.apple.com/documentation/foundation/urlresourcevalues/isexcludedfrombackup, https://pub.dev/documentation/path_provider/latest/path_provider/getApplicationDocumentsDirectory.html
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
