# data-architecture--isar-is-effectively-unmaintained-and-has-fra

> Phase: **verify** · Agent `a12bf3f68197c1377` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Directionally right, materially wrong on specifics. Correct version: "The original Isar is effectively abandoned — last stable 3.1.0+1 (April 2023), v4 permanently stuck at a prerelease its own README warns is not production-ready, and a Jan 2025 issue declaring it abandoned still has no author response. Do not build on original `isar`. However, it has NOT fragmented into three competing forks: the ecosystem already consolidated on `isar_community` (81.3k weekly downloads, verified publisher, releases through March 2026), which out-downloads original isar ~16:1 and the nearest fork (`isar_plus`, by Ahmet Aydin — NOT Simon Choi) ~20:1; `isar_db` has 4 weekly downloads and is not a real contender. The disqualifier for a decade-long tool is not fork ambiguity but that isar_community is a volunteer-run, v3-bugfix-only maintenance fork with no v4 path. For this AAC app's trivial data needs (hundreds of phrase tiles), prefer sqflite or drift."

**Evidence:** CONFIRMED BY PRIMARY SOURCES: (1) Original `isar` last stable = 3.1.0+1, published April 2023 — 3+ years stale (pub.dev/packages/isar). (2) Official v4 never reached stable: github.com/isar/isar README carries "⚠️ ISAR V4 IS NOT READY FOR PRODUCTION USE ⚠️", stuck at prerelease 4.0.0-dev.14; repo is NOT archived but has had no stable release since 2023. (3) Author silence is corroborated independently of the cited blog: isar/isar issue #1689 "Isar is dead, long live Isar" (JakobLichterfeld, Jan 7 2025) states "Obviously, Isar is abandoned by @simc" — still open, no response from the author, no resolution. (4) Three forks do exist on pub.dev.

REFUTED SPECIFIC #1 — attribution error. "isar_plus (by Simon Choi)" is wrong. isar_plus is authored/maintained by Ahmet Aydin (github.com/ahmtydn/isar_plus, verified publisher ahmetaydin.dev; changelog PRs attributed to @ahmtydn). The researcher misread the isar_plus README line "an enhanced fork of the original Isar database created by Simon Choi" — Simon Choi (simc) created the ORIGINAL Isar. They attributed a fork to the very author they claim went silent. This is a direct misread of a source they cited.

REFUTED SPECIFIC #2 — "fragmentation / cannot arbitrate which fork wins" is overstated. Weekly downloads from pub.dev show no contest: isar_community 81.3k/wk, 156 likes, VERIFIED publisher isar-community.dev, latest 3.3.2 with releases through Mar 2026; isar_plus 4.05k/wk, 43 likes, verified, ~10 months of active releases (1.0.1 → 1.3.7, latest 36 days ago); isar_db 4/wk, 2 likes, UNVERIFIED uploader, last published ~8 months ago. isar_db at 4 weekly downloads is a personal republish, not a competing platform. Critically, isar_community (81.3k/wk) now out-downloads the original isar (5.03k/wk) roughly 16:1 — the ecosystem already consolidated on one successor. A solo dev has no arbitration problem: the winner is visibly isar_community by ~20x over the nearest fork.

SOURCING WEAKNESS: The researcher's quoted phrases ("long gaps between commits, no responses on the project's channels", "Treat Isar and original Hive as legacy you migrate off") are verbatim from the single luci-studio blog — an opinion post, not a primary source. Their two pub.dev citations do not support the fragmentation framing; they contradict it. Confidence "high" was not warranted on the specifics.

THE BETTER CAUTION (which the researcher missed): isar_community's own stated scope is "bug fixes and small updates for version 3" — a volunteer-run maintenance fork with no v4 roadmap. For a decade-long accessibility tool that is the real durability risk, not fork ambiguity. Also note that for this AAC MVP (a few hundred phrase tiles + categories), the data volume is trivial and the whole Isar debate is close to moot — sqflite or drift are boring, first-party-adjacent, and demonstrably maintained.

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

CLAIM: Isar is effectively unmaintained and has fragmented into three competing forks — disqualifying for a solo dev on a decade-long accessibility tool
THEIR DETAIL: Original author went silent: 'long gaps between commits, no responses on the project's channels'; official v4 never reached a stable trustworthy release. Survives via at least three forks: isar_community, isar_plus (by Simon Choi), and isar_db. Guidance is explicit: 'Treat Isar and original Hive as legacy you migrate off, not platforms you build on.' Fork fragmentation is the tell — a solo dev cannot arbitrate which fork wins.
THEIR CLAIMED SOURCES: https://luci-studio.com/blog/the-flutter-local-database-landscape-in-2026-a-maintenance-first-guide-fe6d267c/, https://pub.dev/packages/isar_plus, https://pub.dev/packages/isar_community
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
