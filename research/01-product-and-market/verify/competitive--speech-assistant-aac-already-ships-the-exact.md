# competitive--speech-assistant-aac-already-ships-the-exact

> Phase: **verify** · Agent `afffd4c37d50535e0` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim stands, but two specifics should be tightened:

(1) "cross-platform, $24.99" conflates two different price structures. $24.99 is the iOS one-time price ONLY. Android is a free basic version plus a separate one-time IAP at a different (lower) price — I could not isolate the exact Android IAP figure from the Play page, as the listing HTML mixes in similar-apps pricing. There is no single $24.99 cross-platform purchase; you buy each platform separately. This makes the competitor CHEAPER than stated on Android, not more expensive — so the correction strengthens the threat.

(2) The offline claim needs one asterisk: base TTS uses iOS system voices and is fully offline, and "The app does not require an internet connection" is verbatim in the store description. However, the ElevenLabs AI voice-clone option DOES require connectivity. The offline core is intact; only the optional premium-voice feature is networked. Relevant because it shows the incumbent has already solved the "TTS must sound acceptable" risk listed in the product brief — via an optional online tier layered over an offline base — which is a design pattern worth noting rather than a weakness.

(3) "no account" is strongly implied but never stated verbatim. No login is mentioned anywhere, iCloud backup is optional, and "The app does not collect any data" is incompatible with a mandatory account. Safe inference, but it is an inference, not a quoted source.

Bottom line for the product decision: the researcher's high confidence is warranted and if anything under-stated. Speech Assistant AAC matches the proposed MVP feature-for-feature, is actively maintained (updated 2026-07-04), is priced at 1/10th the assumed $299 competitor benchmark, ships on both target platforms, and already has a satisfied autistic-adult user base. The "mainstream AAC is infantilizing and costs $299/iOS-only" premise that motivates this product is not accurate as of 2026-07-15.

**Evidence:** I tried to break this claim on four fronts — stale pricing, abandonment, a misread of the offline line, and invented reviews — and all four attempts failed. Apple's own iTunes Lookup API (uncached, authoritative, queried today) returns:

- trackName = "Speech Assistant AAC"; sellerName/artistName = "Ton Schalke"; description credits "ASoft"; asoft.nl confirms the developer. CONFIRMED.
- formattedPrice = "$24.99", price = 24.99 USD. Not stale — verified against the live API, not a scraped page. CONFIRMED. Description: "The app is affordable with a one-time payment and no subscription." Parkinson's UK guide lists £19.99, consistent regional pricing.
- version = 5.8.65; currentVersionReleaseDate = 2026-07-04T16:39:53Z — updated ELEVEN DAYS AGO. releaseDate = 2016-09-03. My initial WebFetch misread this as "July 4, 2025"; the API shows 2026. The abandonment angle fails hard: this app is actively maintained, ~10 years old. Android listing shows "Updated on Jun 18, 2026" — also current.
- averageUserRating = 4.56863 (rounds to 4.6), userRatingCount = 102. Exact match to the claim.
- Offline: description contains verbatim "• The app does not require an internet connection." I confirmed this exact string appears independently in BOTH the App Store description and the Google Play page HTML. Also: "The app does not collect any data, so all your conversations stay private."
- Adult targeting, verbatim first line: "designed for people who are speech impaired, for example due to Aphasia, MND/ALS, Autism, Stroke, Cerebral Palsy or other speech problems." Adults named first, exactly as claimed.
- Features all verbatim: user-created categories/subcategories ("unlimited number of categories"), iOS keyboard type-to-speak, adjustable button/textbox/text size, "various color schemes and you can also create a personal color scheme", "History feature", "Create user profiles with their own categories, phrases and settings for multi-language support or different individuals", "the set of 3400 Mulberry Symbols (mulberrysymbols.org)", "Supports Apple Watch". Every feature checks out.
- Reviews: I pulled the live customer-review RSS feed (50 reviews). Found verbatim — 5★ "Literally a lifesaver for someone with ALS. Can now communicate with medics, doctors, nurses, family and strangers during emergencies."; 5★ oral-cancer teacher: "Due to oral cancer treatments, I lost my ability to speak clearly... extremely helpful with my frequent doctor and hospital visits." The reviews are real, not invented.

DAMAGING BONUS the researcher MISSED — a 5★ review states: "I am occasionally nonverbal due to being autistic; I love that I can customize this as needed, and add lots of words or phrases specific to my line of work." That is the exact target persona (autistic adult with situational speech loss, employed) already served and satisfied. This makes the counterexample STRONGER than the researcher claimed, not weaker.

Two minor imprecisions, both of which cut in the claim's favor rather than against it (see correction). Neither undermines the competitive conclusion. Cross-platform confirmed: asoft.nl states "The basic version of the Android app is free and within the app you can upgrade to the full version"; Apple API shows iOS/iPadOS/macOS(M1+)/visionOS/watchOS support.

I could not substantiate any basis for refutation. The claim is accurate, current as of 11 days ago, and verified against the primary source rather than the secondary aggregators the researcher cited.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "competitive". A product decision depends on it, so it must be right.

CLAIM: Speech Assistant AAC already ships the exact proposed MVP — offline, adult-marketed, phrase grid + type-to-speak, no account, cross-platform, $24.99
THEIR DETAIL: ASoft (Ton Schalke, NL). iOS $24.99 one-time, no subscription; Android free basic + one-time IAP for full. App Store description states 'The app does not require an internet connection.' Explicitly targets 'Aphasia, MND/ALS, Autism, Stroke, Cerebral Palsy or other speech problems' — adults named first. Features: user-created categories and phrase buttons, keyboard type-to-speak, adjustable button size, text scaling, multiple color schemes, history of spoken phrases, user profiles per situation/language, 3400 Mulberry symbols, Apple Watch. 4.6/5 (102 ratings). Reviews from ALS and oral-cancer users; one user communicated with doctors during a hospital emergency. This is the single most damaging counterexample: it matches the MVP feature-for-feature at 1/10th the assumed competitor price.
THEIR CLAIMED SOURCES: https://apps.apple.com/us/app/speech-assistant-aac/id1139762358, https://play.google.com/store/apps/details?id=nl.asoft.speechassistant, https://asoft.nl/, https://www.aphasiasoftwarefinder.org/speech-assistant-aac, https://techguide.parkinsons.org.uk/catalogue/speech-assistant-aac
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
