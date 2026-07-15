# business-model--competitor-price-anchoring-spans-24-99-to-29

> Phase: **verify** · Agent `a42ac78fe6987ba51` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Competitor pricing spans $0 to $299.99 (up to ~$400 for Proloquo2Go + Gateway), not $24.99 to $295. "Lifetime" pricing does cluster at $249–295 (Proloquo2Go $249.99, Spoken $249.99, CoughDrop $295) — that part is correct and verified. But the low end is anchored by free, offline, no-account apps that already deliver the proposed MVP's core job: LetMeTalk (free, iOS+Android, offline, 9,000+ ARASAAC symbols, no upgrade limits), Cboard (free, open source, UNICEF-backed), Spoken's free tier, and CoughDrop's free modeling accounts. The premium anchor is real but a $15-30 one-time price competes against $0, not against $249 — so the anchor argument does not by itself justify the price. Separately, the assertion that Speech Assistant "proves cheap does not generate volume" is unsupported by any cited volume data and should be dropped or evidenced.

**Evidence:** EVERY INDIVIDUAL PRICE VERIFIED CORRECT — the researcher's data collection is accurate:
- Proloquo2Go: $249.99, Gateway IAP $149.99. Confirmed on the App Store listing itself (v8.8.1, updated 2025-04-15). Note the product brief's own "~$299" figure is the wrong one; the researcher corrected it.
- Speech Assistant AAC: $24.99 one-time, no IAP, no subscription (v5.8.65).
- CoughDrop: $9/mo or $295 lifetime per communicator, $45 supporter/demonstration accounts, free modeling accounts, 2-month trial, open source. All confirmed.
- Spoken: $12.99/mo, $99.99/yr, $249.99 lifetime. Confirmed.
- "Lifetime clusters near $249–295" is CORRECT and well-supported (Proloquo2Go $249.99, Spoken $249.99, CoughDrop $295).

BUT THE STATED SPAN IS WRONG AT BOTH ENDS:

1. CEILING IS NOT $295. TouchChat HD w/ WordPower is $299.99 and LAMP Words for Life is $299.99 — both named in the product brief but absent from the price sweep. Proloquo2Go fully loaded (base + Gateway) is $399.98. The top is $299.99, or ~$400 loaded — not $295.

2. FLOOR IS NOT $24.99 — IT IS $0. This is the error that breaks the business-model inference:
   - Spoken has a FREE tier with basic features. This is stated on spokenaac.com/best-aac-for-android — the researcher's OWN cited source. They pulled the paid tiers off that page and omitted the free tier printed alongside them. That is a misread of a primary source, not a stale-data problem.
   - LetMeTalk: fully free, iOS + Android, works with no internet connection, 9,000+ ARASAAC symbols, donation-financed, and explicitly "no limitations to get you to upgrade." That is functionally the proposed MVP spec at $0.
   - Cboard: free, open source, UNICEF-supported, symbols + TTS.
   - CoughDrop modeling accounts: free forever.

3. UNSUPPORTED INFERENCE. "Speech Assistant proves that being cheap at $24.99 does not by itself generate volume in this niche" — no download, revenue, or ranking data for Speech Assistant was cited or exists in the sources given. The conclusion may be true but nothing presented supports it.

4. VERSIONING CAVEAT. CoughDrop's numbers are current but changed: a 2020 CoughDrop blog post lists $200 lifetime / $6 mo / $25 supporter, raised to $295 / $9 / $45 around July 2023. The lifetime tier also bundles 5 years of Cloud Extras, so $295 is not a pure perpetual-license comparable. CoughDrop's own Zendesk pricing article (a cited source) returns HTTP 403 and could not be read directly — the figures were corroborated via search snippets and secondary pages instead.

DECISION IMPACT: The $249–299 anchor is real, but the framing "makes a $15-30 one-time price look nearly free" assumes buyers price-compare against the anchor. They don't have to — free, offline, no-account, symbol+TTS apps already exist on both platforms. A $15-30 app competes against $0, not against $249. The defensible pricing case rests on adult-appropriate design and shutdown-usability being worth paying for over free alternatives, NOT on anchor-relative cheapness. Recommend re-running this dimension against the free tier (LetMeTalk, Cboard, Spoken free) as the true competitive floor.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "business-model". A product decision depends on it, so it must be right.

CLAIM: Competitor price anchoring spans $24.99 to $295, and 'lifetime' pricing clusters near $249-295
THEIR DETAIL: Proloquo2Go $249.99 one-time (+$149.99 Gateway IAP); CoughDrop $9/month or $295 one-time lifetime per communicator, open source, 2-month free trial, free supporter accounts, $45 supporter/demo accounts; Spoken $12.99/mo, $99.99/yr, or $249.99 lifetime; Speech Assistant AAC $24.99 one-time. The $249-299 anchor is real and makes a $15-30 one-time price look nearly free — but Speech Assistant proves that being cheap at $24.99 does not by itself generate volume in this niche.
THEIR CLAIMED SOURCES: https://apps.apple.com/us/app/proloquo2go-aac/id308368164, https://coughdrop.zendesk.com/hc/en-us/articles/201366609-How-much-does-CoughDrop-cost, https://www.coughdrop.com/, https://spokenaac.com/best-aac-for-android/, https://apps.apple.com/us/app/speech-assistant-aac/id1139762358
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
