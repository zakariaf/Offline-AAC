# data-architecture--drift-is-the-only-relational-flutter-db-that

> Phase: **verify** · Agent `a8c03c0b1d0f1e006` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Drift is the best-supported relational Flutter DB and a well-justified default choice for this app — but it is NOT the "only" unambiguously healthy one. sqflite (v2.4.3, published 43 days ago, 5.55k likes, 2.46M downloads, 160 pub points, verified publisher tekartik.com) is relational, actively maintained, and healthier than drift on every popularity metric the researcher cited. The researcher's own cited source calls sqflite "healthy and stable" and "the long-standing baseline the community falls back on," and positions drift as the DEFAULT relational choice, not the exclusive one. Accurate restatement: "Drift is the strongest relational Flutter DB in 2026 — actively developed, structurally funded (PowerSync employs maintainer Simon Binder; Stream co-sponsors), with built-in transactions, migrations, joins, and the widest platform support. sqflite remains a healthy relational alternative for raw-SQL use without an ORM; the abandonment concerns apply to Isar and Hive, which are NoSQL and were never relational competitors." Every version number, statistic, publisher, and platform claim in the researcher's detail is verified correct — the defect is confined to the exclusivity framing, which appears to be a misread of a recommendation as a uniqueness finding. The product decision (use drift) stands unchanged.

**Evidence:** PRIMARY SOURCE — pub.dev/packages/drift: CONFIRMS every stated figure exactly. v2.34.2, published ~23 hours prior, 2.43k likes, 160 pub points, 973k downloads, verified publisher simonbinder.eu, platforms Android/iOS/Linux/macOS/Web/Windows, MIT license.

PRIMARY SOURCE — github.com/simolus3/drift: CONFIRMS release drift-2.34.2 dated 2026-07-14 (matches the "~23 hours" timing), 71 total releases, 4,635 commits on develop, active CI/CD, 3.2k stars. README states verbatim: "Drift is proudly Sponsored by Stream and PowerSync." So the sponsorship is corroborated by a source INDEPENDENT of the luci-studio blog.

STRONGER THAN CLAIMED — powersync.com/blog/simon-binder-joins-powersync: PowerSync does not merely sponsor drift; it EMPLOYS Simon Binder, who works on drift and sqlite3 as part of his role. This is a structural, funded maintenance guarantee the researcher understated.

REFUTES "ONLY" — pub.dev/packages/sqflite: v2.4.3, published 43 days ago, 5.55k likes (2.3x drift), 2.46M downloads (2.5x drift), 160 pub points, verified publisher tekartik.com, native iOS/Android/macOS with companion packages for Linux/Windows/web. sqflite is relational SQLite and is unambiguously healthy by the researcher's own criteria.

SELF-CONTRADICTING SOURCE — the researcher's own cited luci-studio.com article does NOT claim exclusivity. It calls sqflite "healthy and stable" and "the long-standing baseline the community falls back on," calls ObjectBox "Healthy. Commercially backed, with frequent releases (5.3.2 stable, 6.0 in preview as of mid-2026)," and frames drift as the recommended default for relational data — not the sole healthy option. The article's decision framework explicitly lists multiple viable candidates.

SCOPE ERROR — the genuine abandonment findings in that article concern Isar ("The original author went quiet — long gaps between commits, no responses on the project's channels," surviving via the isar-community fork) and Hive ("abandoned by the original author," continuing as Hive CE). Both are NoSQL, so neither was ever a counter-example to a claim scoped to relational DBs. The exclusivity intuition appears to have leaked in from this NoSQL contrast, but it cannot support the word "only" in a relational-scoped claim.

NET IMPACT ON PRODUCT DECISION: none. Drift remains correct for the AAC app's editable phrase-tile/category schema (migrations matter as customization evolves, all offline, no network dependency). Only the reasoning's confidence level needs downgrading, not the choice.

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

CLAIM: Drift is the only relational Flutter DB that is unambiguously healthy in 2026
THEIR DETAIL: pub.dev/packages/drift: v2.34.2 published ~23 hours before this research, 2.43k likes, 160 pub points, 973k downloads, verified publisher simonbinder.eu, supports Android/iOS/Linux/macOS/Web/Windows. Built-in transactions, schema migrations, joins. Independently corroborated: 'Actively developed by Simon Binder with regular releases through 2026, and now sponsored by Stream and PowerSync' — recommended as default choice for relational data, migrations, and offline-first.
THEIR CLAIMED SOURCES: https://pub.dev/packages/drift, https://luci-studio.com/blog/the-flutter-local-database-landscape-in-2026-a-maintenance-first-guide-fe6d267c/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
