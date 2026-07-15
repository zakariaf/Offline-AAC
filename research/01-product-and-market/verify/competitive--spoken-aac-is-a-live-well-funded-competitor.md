# competitive--spoken-aac-is-a-live-well-funded-competitor

> Phase: **verify** · Agent `a2e90595c2a7f0c44` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Spoken AAC is a live, adult/teen-targeted AAC app on iOS/Android/Mac with a free tier and paid upgrade (~$12.99/mo; yearly listed inconsistently as $99 or $99.99; lifetime as $249 or $249.99) — but it is NOT well-funded: it is a ~4-person Ohio company with no disclosed VC round (a "$500K seed" in search results belongs to an unrelated Portland audiobook startup of the same name). Its "300,000+ users" is an unaudited cumulative marketing figure, not active users. Contrary to the claim, Spoken DOES document its offline behavior publicly, in a dedicated help article: high-quality voices require internet, and offline the app "will show a warning, but still work - just with limited functionality," falling back to the device's built-in TTS voice. It degrades, it does not fail — and its free tier already runs on offline device voices with word prediction. Spoken also shipped "improved offline voices" in v1.9.2 (Aug 2025), actively narrowing the gap. The genuine differentiator is therefore narrow and perishable: no account, instant launch, no offline warning banner, full privacy, and adult one-handed distress UX — not "they don't work offline."

**Evidence:** The claim's headline framing survives, but its two load-bearing decision inputs — "well-funded" and "offline is NOT specified anywhere on their site" — are both false. The strategic conclusion (cloud-dependent TTS) is actually CORRECT and better documented than the researcher guessed, but they reached it by speculation rather than reading the source, and the differentiator is narrower and more perishable than they claim.

WHAT CHECKS OUT (verified verbatim):
1. LIVE: Yes. iOS v1.9.5, last updated Nov 19 2025; blog posts running into 2026. Developer "Spoken Inc."
2. 300,000+: Verbatim on homepage — "We've helped over 300,000 users find their voice!" Confirmed as a SELF-REPORTED, unaudited, cumulative marketing figure — not active users. Wikipedia records only ~10,000 downloads by Mar 2021 and ~1,000/week by May 2022.
3. PLATFORMS: Verbatim — "fully compatible with your existing devices, including Android, iOS, and Mac."
4. ADULTS/TEENS: Verbatim — "Spoken is a top choice for adults and teenagers who use AAC" (/best-aac-for-android/) and App Store: "designed for teens and adults."
5. AI PREDICTION + TTS CUSTOMIZATION: Confirmed (pitch/speed, masculine/feminine/androgynous).
6. PRICING: The researcher's numbers ($12.99/mo, $99.99/yr, $249.99 lifetime) are quoted correctly from their cited page. But the SITE CONTRADICTS ITSELF: the help page says "$12.99/month", "$99/year", "$249"; App Store IAPs list $99.99, Lifetime $249.00, plus $124.99, $49.99, and a $6.49 monthly tier. Don't cite $249.99 as fact.

REFUTATION 1 — "WELL-FUNDED" IS UNSUPPORTED AND LIKELY INVENTED. No disclosed VC round exists. Their own team page lists FOUR people (Michael Bond, Founder/CEO; Tim Yoder, UX; Zach Cronin, dev; Evan Lauer, design) plus 2 advisors. Wikipedia shows only accelerator participation (Start-Up Chile 2015, AlphaLab Health 2022, Slalom AI for Good) — accelerator support, not a funding round. IMPORTANT TRAP: a search surfaced "$500K seed, Jan 20 2026" for "Spoken" — I fetched Tracxn and that record is a DIFFERENT COMPANY: an AI audiobook platform in Portland, founded 2024, 13 employees. Name collision. Do not attribute that funding to Spoken AAC. This is a ~4-person Marietta, Ohio shop, not a funded competitor.

REFUTATION 2 — "OFFLINE CAPABILITY IS NOT SPECIFIED ANYWHERE ON THEIR SITE" IS FLATLY FALSE. Spoken has a dedicated help article titled exactly "Do I need to be connected to the internet to use Spoken?", a second titled "What is a fallback voice?", and a v1.9.1 blog post about offline voices. The researcher didn't check the help center and reported an information gap that isn't there.

CORRECTION 3 — SPOKEN DEGRADES, IT DOES NOT FAIL. Verbatim: "Without an internet connection, the app will show a warning, but still work - just with limited functionality." And: "Spoken requires an internet connection to use its selection of high-quality voices. When you lose connection or deliberately disconnect, your chosen voice will switch to a fallback — a lower quality voice built into your phone by default." So the real gap is VOICE QUALITY + an intrusive warning banner mid-shutdown — NOT "can't speak." That warning banner is still a legitimate UX attack surface for a distressed user, but it is a much smaller wedge than "fails without signal."

CORRECTION 4 — ONLY TTS IS CLOUD-BOUND; THE AI-PREDICTION HALF IS UNSUPPORTED. No source says prediction requires internet. The FREE tier explicitly includes a "Powerful next-word prediction engine."

RISK THE RESEARCHER MISSED — THEY ARE ACTIVELY CLOSING THIS GAP. App Store v1.9.2 (Aug 27 2025): "Improved offline voices: Offline voices are now higher-quality on most devices and more closely match their online counterparts." The offline gap is narrowing, not static.

RISK 2 — SPOKEN'S FREE TIER IS ALREADY EFFECTIVELY THE OFFLINE TIER. Free includes unlimited speaking, "Use any text-to-speech voice built into your device," and next-word prediction. So "free + device voices + prediction, works offline" already ships from the most adult-positioned competitor. The offline-as-accommodation wedge must rest on no-account/instant-launch/one-handed distress UX and grid-of-phrases design — NOT on "they can't work offline," which is false and would not survive contact with an informed user.

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

CLAIM: Spoken AAC is a live, well-funded competitor explicitly targeting adults and teens on iOS+Android with a free tier — but it is AI/cloud-dependent
THEIR DETAIL: spokenaac.com claims 300,000+ users. iOS, Android, Mac. Free download + premium ($12.99/mo, $99.99/yr, $249.99 lifetime). Markets to 'adults and teenagers who use AAC' and to nonverbal autism, aphasia, stroke, CP, ALS, Parkinson's, stuttering; testimonials from autistic teens and post-surgery patients. Uses 'AI-powered word predictions that learn from user behavior' and next-gen TTS with pitch/voice customization spanning feminine to masculine. CRITICAL WEAKNESS FOR THEM / OPENING FOR YOU: offline capability is NOT specified anywhere on their site, and AI prediction + next-gen TTS strongly imply cloud dependency. If Spoken degrades or fails without signal, the offline-as-accommodation positioning is a genuine differentiator against the most adult-positioned competitor in the space.
THEIR CLAIMED SOURCES: https://spokenaac.com/, https://spokenaac.com/best-aac-for-android/
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
