# data-architecture--realm-atlas-device-sdk-is-dead-eol-september

> Phase: **verify** · Agent `a29c2c4a424bc6140` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Atlas Device SYNC (the cloud service) shut down September 30, 2025; the Atlas Device SDKs were deprecated in September 2024 but MongoDB explicitly kept them as Apache 2.0 open source, and they are NOT unmaintained — realm-swift released v20.0.5 on 2026-06-14 by a longtime Realm engineer, realm-core was committed to 2026-06-14, and realm-js was pushed 2026-07-10. None of these repos are archived. The correct Flutter-specific concern is narrower: realm-dart alone is dormant (last commit 2025-10-23, ~9 months, 140 open issues), though the pub.dev `realm` package at 20.2.0 is not marked discontinued. Net effect on the product decision is unchanged — do not adopt Realm for this app — but the reasoning should be "the Dart binding is dormant and the sync layer we don't want was its reason to exist," not "MongoDB EOL'd it into an unmaintained state." Also note the lead source is a Couchbase competitor-marketing post; Hive CE is healthier than implied (v2.19.3, ~5 months old, verified publisher, 791k downloads); and Drift — the 2026 consensus default — is missing from the options considered.

**Evidence:** The practical conclusion (don't start a new Flutter app on Realm in 2026) survives, but two load-bearing specifics in the claim are wrong.

WHAT CHECKS OUT:
1. The Sept 30, 2025 date is real — but it is the shutdown date for ATLAS DEVICE SYNC (the cloud service), not the date the SDK became unmaintained. Deprecation of Device Sync + Device SDKs was announced Sept 2024; Sync-as-a-service was switched off Sept 30 2025 (extensions of 3-6 months available via Support case). MongoDB's own wording is that they "continue offering MongoDB Atlas Device SDKs as a free and open source project under Apache License 2.0."
2. sqflite is healthy: v2.4.3 published 43 days ago, Flutter Favorite, verified publisher tekartik.com, 5.55k likes / 2.46M downloads.
3. Hive lineage claim is supported: `hive` 2.2.3 last published ~4 years ago under publisher isar.dev (same author, Simon Leier); `isar` stable is 3.1.0+1 from ~3 years ago with a stalled 4.0.0-dev.14 prerelease.

WHAT IS REFUTED — "no longer maintained by MongoDB as of Sept 30 2025 / persists as unmaintained open source":
This is false for the Realm ecosystem broadly. Verified via GitHub API today:
- realm-swift shipped v20.0.5 on 2026-06-14 (one month ago), authored by tgoyne — a longtime Realm/MongoDB engineer — adding Xcode 27 support and bumping realm-core 20.1.4 -> 20.1.5.
- realm-core last commit 2026-06-14. realm-js pushed 2026-07-10 (five days ago).
- None of realm-swift, realm-core, realm-js, or realm-dart are archived.
So Realm is not "dead" and not "unmaintained." Post-EOL maintenance is demonstrably ongoing.

WHAT IS REFUTED — the mechanism for Flutter:
The right reason to avoid Realm here is narrower and different from what was claimed. realm-dart specifically is DORMANT: last commit 2025-10-23 (Release 3.5.0 on main; community branch last touched 2025-09-24 at 20.2.0), ~9 months of silence, 140 open issues. The pub.dev `realm` package sits at 20.2.0 and is NOT marked discontinued. So the risk is "the Dart binding went quiet while Swift/JS/Core kept moving," not "MongoDB killed it on a date."

SOURCE-QUALITY FLAG: their lead source, couchbase.com/blog/realm-mongodb-eol-day-2025, is a direct competitor publishing a "migrate to Couchbase" pitch — a motivated source for the "dead" framing, and it should not be the primary basis for a stack decision.

OVERSTATEMENT ON HIVE CE: framing it as merely "a community continuation carrying higher risk" undersells it — hive_ce 2.19.3 published ~5 months ago, verified publisher iodesignteam.com, 555 likes, 791k downloads, with isolate support, WASM, and a DevTools inspector.

OMISSION AFFECTING THE DECISION: Drift is the 2026 consensus default for Flutter local storage (SQL-backed, type-safe, actively maintained, reactive, isolate threading) and was absent from the researcher's option set. For this app — a static-ish grid of user-editable phrase tiles and categories, no sync, no queries — the honest answer is that sqflite/Drift or even hive_ce all clear the bar, and Realm was never a serious candidate regardless of its EOL status.

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

CLAIM: Realm/Atlas Device SDK is dead — EOL September 30, 2025
THEIR DETAIL: MongoDB deprecated Atlas Device SDKs September 2024; end-of-life and no longer maintained by MongoDB as of Sept 30 2025. MongoDB officially ended mobile support that day. The client-side DB persists as unmaintained open source. Its main value was the sync layer, which this app explicitly does not want. Original Hive likewise abandoned by its author (who repositioned Isar as successor, which then also went quiet); Hive CE is a community continuation carrying higher risk. sqflite remains healthy as the raw-SQL baseline; ObjectBox is maintained but commercially backed with sync you don't need.
THEIR CLAIMED SOURCES: https://www.couchbase.com/blog/realm-mongodb-eol-day-2025/, https://loopcafe.substack.com/p/realm-is-deprecated-what-now, https://luci-studio.com/blog/the-flutter-local-database-landscape-in-2026-a-maintenance-first-guide-fe6d267c/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
