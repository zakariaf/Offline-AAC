# flutter-tts--flutter-tts-is-at-4-2-5-and-is-a-viable-mvp

> Phase: **verify** · Agent `ad7ed5e953423fc5c` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** flutter_tts is at 4.2.5 (published ~Jan 2026) and is a viable MVP base, carrying a genuine bus-factor risk (effectively one maintainer, dlutton/Daniel Lutton, whose pub.dev publisher account holds only this package) and a chronically slow release cadence — but NOT the ownership churn suggested. Corrections to the supporting detail: (1) The com.tundralabs.fluttertts -> com.eyedeadevelopment.fluttertts rename is dlutton renaming his own domain, not maintainer/ownership churn — all "updating domain" commits are authored and committed by dlutton himself (identical author timestamp 2026-01-05 08:37:21), the changelog says only "Android: Fixing namespace path", the LICENSE still reads "Copyright (c) 2018 Daniel Lutton", and the contributor PR only moved the source file to match a namespace dlutton had already declared. (2) "212 open issues" is the GitHub open_issues_count field, which includes PRs; the real split is 196 open issues + 16 open PRs (field now 213). (3) The gap runs 2025-06-02 (dlutton's last commit) to 2026-01-05, ~7 months — but it is the norm, not decay: a 217-day gap (2024-12-25 -> 2025-06-02) immediately precedes it. (4) Pub points are 150/160, not a perfect score; the 10-point loss is Platform Support (no Linux, web incompatible due to dart:io, no wasm, no Swift Package Manager, legacy Kotlin config) — none of which block a Flutter iOS+Android build. Verified-correct in the original: 748 stars, MIT, last push 2026-01-05, not archived, 1,590 likes, 285k weekly downloads, and all five cited issues (#538, #619, #408, #271, #323) are real and open.

**Evidence:** Headline claim CONFIRMED against primary sources; two specifics corrected and one interpretation REFUTED.

VERIFIED TRUE:
- Version: pub.dev shows flutter_tts 4.2.5 as latest, published ~6 months ago (consistent with the 2026-01-05 "bumping version and updating changelog" commit).
- GitHub API (api.github.com/repos/dlutton/flutter_tts): stargazers_count=748, license.spdx_id=MIT, pushed_at=2026-01-05T17:56:05Z, archived=false, disabled=false, fork=false, forks_count=334, subscribers_count=15, created_at=2018-04-10.
- pub.dev: 1.59k likes, 285k downloads explicitly labeled "weekly downloads" on the /score page. Publisher eyedeadevelopment.com (verified).
- Single-maintainer / bus-factor=1: CONFIRMED. dlutton (Daniel Lutton) authors every merge commit; LICENSE = "Copyright (c) 2018 Daniel Lutton"; publisher eyedeadevelopment.com has exactly 1 package (flutter_tts); subscribers_count=15.
- Cited issues are real and correctly characterized. Spot-checked via API: #619 "Sudden non-deterministic TTS timeouts without app/plugin updates: anyone else?" open, created 2025-12-22T08:01:57Z. #408 "Very slow english reading on some real device. Big delay before reading and breaking all reading" open, created 2023-07-20.
- Namespace path exists: android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt (30,674 bytes). pubspec.yaml declares android package com.eyedeadevelopment.fluttertts.

REFUTED — "signal of maintainer/ownership churn":
This is a misread. The tundralabs -> eyedeadevelopment rename is dlutton renaming his OWN domain, not an ownership handoff. Evidence: all five "updating domain" commits are authored AND committed by dlutton himself, sharing an identical author date (2026-01-05 08:37:21) as they were cherry-picked across merge branches. The 4.2.5 changelog entry reads only "Android: Fixing namespace path". The contributor PR (alexdempster44, "fix: move android main file to match `pubspec.yaml`") merely moved the source file to match a namespace dlutton had already declared. Copyright holder unchanged (Daniel Lutton); homepage still github.com/dlutton/flutter_tts; pub.dev publisher is a single-package publisher. This is a self-rebrand and arguably evidences continued ownership — the opposite of the churn signal claimed.

CORRECTION 1 — "212 open issues" mislabels an issues+PRs count:
212 is the GitHub open_issues_count API field, which INCLUDES pull requests. Actual split via search API: type:issue state:open total_count=196; type:pr state:open total_count=16 (196+16=212; field now reads 213). True issue backlog is 196, smaller than stated.

CORRECTION 2 — the "~7-month dead gap" is real but mis-anchored and NOT anomalous:
The gap starts 2025-06-02 (dlutton's last commit: "updating changelog and pubspec versiono"), not 2025-06-15 (which is a contributor's AUTHOR date on a commit merged later — author dates in the commit list predate their merge). More importantly it is not new decay: an immediately preceding 217-day gap runs 2024-12-25 -> 2025-06-02. dlutton's own commit dates: 2024-12-24, 2024-12-25, 2025-01-23, 2025-01-29, 2025-06-02, 2026-01-05. This is a long-standing ~6-month burst cadence, so the risk reframes as "chronically slow but persistent" rather than "recently going dark."

ADDITIONAL FINDING (not in claim, decision-relevant):
Pub points are 150/160, not a perfect score. The 10-point loss is Platform Support (10/20): missing Linux, web marked not-compatible due to a dart:io import, not wasm-compatible, no Swift Package Manager support on iOS/macOS, and "Legacy Kotlin configuration detected" on Android. None of these block a Flutter iOS+Android AAC app, but 150 is not a clean sweep.

NET ASSESSMENT: "4.2.5, viable MVP base, real bus-factor and maintenance risk" is substantiated. The bus factor is genuinely 1. But the churn narrative should be dropped, the issue backlog is 196 not 212, and the maintenance cadence is a stable long-running pattern rather than a decline. Because the package is MIT-licensed with a self-contained plugin, forkability substantially defuses the bus-factor risk for an offline AAC app.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "flutter-tts". A product decision depends on it, so it must be right.

CLAIM: flutter_tts is at 4.2.5 and is a viable MVP base, but carries real bus-factor and maintenance risk
THEIR DETAIL: Latest 4.2.5, published ~Jan 2026. GitHub dlutton/flutter_tts: 748 stars, 212 open issues, MIT, last push 2026-01-05, not archived. pub.dev: 1,590 likes, 150 pub points, 285k weekly downloads. Effectively single-maintainer (dlutton). Commit history shows a ~7-month dead gap between 2025-06-15 and 2026-01-05, then a burst of merges. Android package was renamed com.tundralabs.fluttertts -> com.eyedeadevelopment.fluttertts in Jan 2026 (source now at android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt) — a signal of maintainer/ownership churn worth watching. Notable open issues: #538 'Any way to buffer the next text?', #619 'Sudden non-deterministic TTS timeouts' (2025-12-22), #408 'Very slow english reading... big delay before reading' (2023, still open), #271 'synthesizeToFile runs really slow on iOS', #323 'After setVoice it takes a while until speaking starts'.
THEIR CLAIMED SOURCES: https://pub.dev/packages/flutter_tts, https://api.github.com/repos/dlutton/flutter_tts, https://github.com/dlutton/flutter_tts
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
