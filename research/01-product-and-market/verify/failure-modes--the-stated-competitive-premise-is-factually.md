# failure-modes--the-stated-competitive-premise-is-factually

> Phase: **verify** · Agent `aafdaa39e3909ea37` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Corrected version: "Speech Assistant AAC (ASoft/asoft.nl) already occupies most of this MVP's ground and materially weakens — but does not eliminate — the stated competitive premise. Verified: iOS $24.99 one-time (no subscription, no account, App Store confirms 'does not require an internet connection', developer 'does not collect any data'); Android basic tier free with one-time upgrade for unlimited categories, backup/restore, history, profiles and tabs; explicitly targets adults with aphasia, MND/ALS, autism, stroke and cerebral palsy; text-based buttons rather than child symbol sets. It is NOT, however, a single free cross-platform app: iOS is paid, the free Android tier caps categories (an MVP feature), and iOS/Android are separate products with diverging versions; Watch/Mac/Vision support is Apple-only. Spoken - Tap to Talk AAC is NOT a supporting example — it is subscription-priced ($12.99/mo, $99.99/yr, $249.99 lifetime), auto-enrolls a Premium trial, and requires internet for full features, so it reinforces rather than refutes the premium-pricing framing. The 'adults or teens without learning disabilities' and 'affordable alternative to Proloquo4Text' quotes do not appear on the cited spokenaac.com page, which mentions neither Speech Assistant AAC nor Proloquo4Text, and should be treated as unsourced. Remaining genuine openings: incumbent iOS build is ~12 months stale (v5.8.65, 2025-07-04), device voices are a common reviewer complaint with higher-quality ElevenLabs voices apparently requiring connectivity, and no incumbent is designed around one-handed mid-shutdown use or calm adult visual design. The founder's '$299 / iOS-only' framing accurately describes Proloquo2Go/TouchChat/Avaz in the symbol-based child market, and Spoken's $249.99 tier, but not the adult text-AAC niche — that specific framing should be dropped."

**Evidence:** I tried to break this claim and mostly could not. The load-bearing core survives primary-source verification, but three specifics fail.

WHAT CONFIRMS (primary sources):
1. Speech Assistant AAC (ASoft, asoft.nl) is real and is very close to the described MVP. US App Store listing (id1139762358): $24.99 one-time, "no subscription," version 5.8.65, last updated 2025-07-04, runs on iPhone/iPad/iPod touch/Mac (M1+)/Apple Vision/Apple Watch. Description: "does not require an internet connection"; "create categories and save phrases on buttons for quick access"; "type messages using the iOS keyboard." Privacy section states "The developer does not collect any data from this app." No account required.
2. Target audience confirmed adult/acquired-condition, not child-symbol: "Aphasia, MND/ALS, Autism, Stroke, Cerebral Palsy or other speech problems" — verbatim on both asoft.nl and the App Store listing.
3. Android basic version IS free with a one-time in-app upgrade, no subscription. Offline confirmed ("the app does not require an internet connection").
4. The "text-not-symbols, literate adult user" positioning is independently corroborated: Speech Assistant AAC "is aimed at literate AAC users and uses buttons with text instead of icons with pictures."

WHAT FAILS:
A. SOURCE MISATTRIBUTION / LIKELY FABRICATED QUOTES. I fetched the cited https://spokenaac.com/best-aac-for-android/. It does NOT mention Speech Assistant AAC anywhere, and does NOT mention Proloquo4Text anywhere. Neither quoted phrase — "aimed at adults or teens without learning disabilities, no images" nor "a fantastic, affordable alternative to Proloquo4Text" — appears on the cited page. The researcher attributed quotes to a source that cannot contain them. The nearest real corroboration is a 2022 blog (justkeepstimming.com), not the cited URL.

B. SPOKEN IS MATERIALLY MISCHARACTERIZED, AND IT CUTS THE OTHER WAY. The claim offers Spoken as a second example of free/no-account/offline adult AAC. Spoken's own site lists premium at $12.99/month, $99.99/year, or $249.99 lifetime; it auto-enrolls users in a Premium trial on download; and it "requires an internet connection to use all of its features," degrading to limited functionality offline. Spoken is a subscription, partly-online, account-bearing AI app — the opposite of the claim's thesis. Its $249.99 lifetime tier actually SUPPORTS the founder's ~$299 premium-pricing framing rather than refuting it.

C. "FREE + CROSS-PLATFORM" IS A CONJUNCTION NO SINGLE APP SATISFIES. iOS Speech Assistant is $24.99, not free. Android is free only at a basic tier that caps the number of categories — editable categories is a stated MVP feature, and unlimited categories sits behind the paid upgrade (along with backup/restore, history, profiles, tabs). iOS and Android are separate apps with different versions (iOS 5.8.65 vs Android ~6.5.x) and different feature sets, not one cross-platform product. Watch/Mac/Vision support is Apple-only.

D. MINOR: price stated as €23.99; US App Store shows $24.99 (plausible EUR tier, but unverified as stated). The Apple Watch claim that it "already solves the crisis-discoverability problem" is an interpretive leap, not a fact, and applies only to Apple users.

E. STALENESS/QUALITY GAPS the claim omits: iOS build last updated 2025-07-04, ~12 months stale as of today. Reviewers complain the device-derived voices sound unnatural — the founder's own stated TTS risk is a live weakness in the incumbent, and the App Store listing now references ElevenLabs voices, implying the incumbent's better voices are NOT offline.

BOTTOM LINE FOR THE PRODUCT DECISION: the researcher is directionally right and the founder's competitive premise genuinely is overstated — a cheap/free, offline, no-account, adult-text-AAC incumbent with categories, phrase buttons and type-to-speak does exist and has for years. But "every stated differentiator is already on the shelf" overreaches: the incumbent is Apple-favoring, free only in a category-capped Android tier, a year stale, and weakest exactly where the founder flagged risk (voice quality, one-handed crisis UX, calm adult visual design). The researcher's "high" confidence is not warranted given one cited source demonstrably does not support the quotes drawn from it and the second example contradicts the thesis.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "failure-modes". A product decision depends on it, so it must be right.

CLAIM: The stated competitive premise is factually wrong: a free, offline, no-account, adult-targeted, cross-platform AAC app with phrase tiles, categories and type-to-speak already exists and is the described MVP
THEIR DETAIL: Speech Assistant AAC (asoft.nl): basic Android version FREE with one-time in-app upgrade, iOS €23.99 one-time, explicitly no subscription and no account. Works fully offline. Create categories and subcategories, save phrases on buttons for quick access, plus type-to-speak. Explicitly targets adults with aphasia, autism, stroke, MND/ALS, cerebral palsy. Reviewers describe it as 'aimed at adults or teens without learning disabilities, no images' and 'a fantastic, affordable alternative to Proloquo4Text.' Runs on iPhone, iPad, Mac (Apple silicon) AND Apple Watch (watchOS 9+) — meaning it already solves the crisis-discoverability problem the founder has not yet addressed. Also Spoken - Tap to Talk AAC: free tier, explicitly for 'adults and teenagers', word suggestions. The $299/iOS-only framing describes Proloquo2Go/TouchChat/Avaz — the symbol-based child market — not the adult text-to-speech niche this MVP actually enters. Every stated differentiator (adult design, offline, no account, cross-platform, cheap) is already on the shelf.
THEIR CLAIMED SOURCES: https://asoft.nl/, https://play.google.com/store/apps/details?id=nl.asoft.speechassistant, https://apps.apple.com/us/app/speech-assistant-aac/id1139762358, https://spokenaac.com/best-aac-for-android/, https://www.assistiveware.com/products/proloquo4text
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
