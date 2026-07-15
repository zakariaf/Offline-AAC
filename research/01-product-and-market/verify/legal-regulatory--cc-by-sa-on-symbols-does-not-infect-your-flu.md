# legal-regulatory--cc-by-sa-on-symbols-does-not-infect-your-flu

> Phase: **verify** · Agent `a3598ef9df3fd186d` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** CC BY-SA's ShareAlike does not infect your Flutter app code — that part is correct and verifiable in the legal code (CC BY-SA 2.0 UK §§1.3/2.3; CC BY-SA 4.0 §3(b); CC FAQ on collections). Unmodified symbols bundled with proprietary code form a collection/mere aggregation; SA reaches only adaptations of the symbols. Restyling a symbol for the dark theme does create Adapted Material that must be licensed BY-SA when shipped.

However: (a) Mulberry's license VERSION is genuinely contested — the repo's LICENSE.txt says CC BY-SA 4.0 while mulberrysymbols.org's attribution string and OpenSymbols say CC BY-SA 2.0 UK, and GitHub's classifier returns NOASSERTION/"Other". Do not state "2.0 UK" as fact; resolve it with the maintainer (Steve Lee) before relying on it. (b) Mulberry adds a non-CC restriction ("you must not charge for the symbols themselves"), so this is not stock BY-SA. (c) The real legal-regulatory risk is not code infection but the anti-TPM/DRM clause versus Apple's FairPlay — it applies to distributing the symbols at all, not just adaptations, and so is NOT avoided by staying in mere-aggregation territory. CC 4.0 largely defuses this; 2.0 UK does not, which is precisely why the version question must be settled. (d) There is no obligation to publish a standalone restyled symbol set or ship source SVGs; licensing the adapted symbols BY-SA as distributed in the app suffices.

Practical recommendation: ARASAAC (CC BY-NC-SA — NC kills commercial use) and Mulberry both carry SA. If the app ships to the iOS App Store, either (1) get written confirmation Mulberry is 4.0, or (2) ship symbols unmodified and implement dark-theme adaptation at RUNTIME (CSS/shader/tint applied in-app rather than to the shipped asset files), which avoids creating Adapted Material at all, or (3) ask the maintainer for an explicit App Store/TPM waiver. Option 2 also happens to be the cleanest engineering path for a themable Flutter grid.

**Evidence:** CORE PROPOSITION: CONFIRMED. The "CC BY-SA infects your code" fear is genuinely unfounded, and this checks out against primary legal text, not just vibes.

- CC BY-SA 2.0 UK legalcode defines "Collective Work" as "The Work in its entirety in unmodified form along with a number of other separate and independent works, assembled into a collective whole," and "Derivative Work" as "Any work created by the editing, modification, adaptation or translation of the Work." Section 2.3's ShareAlike obligation attaches to Derivative Works; Collective Works are exempt.
- CC BY-SA 4.0 legalcode: Section 3(b) ShareAlike applies only "if You Share Adapted Material You produce"; Adapted Material requires the material be "translated, altered, arranged, transformed, or otherwise modified in a manner requiring permission."
- CC's own FAQ confirms it: for a collection including CC-licensed work, "you may choose your own license for the collection itself," and ShareAlike does not reach the collection.
So: unmodified symbols + proprietary Flutter code = collection. App stays proprietary. Recolor/restyle a symbol = adaptation, SA bites. That part of the reasoning is sound.

BUT FOUR SPECIFICS ARE WRONG OR MISSING:

1. THE LICENSE VERSION IS CONTRADICTORY IN PRIMARY SOURCES — the claim asserts "CC BY-SA 2.0 UK" as settled fact. It isn't:
   - The repo's own LICENSE.txt (mulberrysymbols/mulberry-symbols, master) states Attribution-Share Alike **4.0**.
   - mulberrysymbols.org's suggested attribution string says "Creative Commons Attribution-ShareAlike **2.0 UK: England & Wales**" (copyright 2018–2026 Steve Lee).
   - OpenSymbols lists 2.0 UK.
   - GitHub's own license classifier returns spdx_id **NOASSERTION**, name **"Other"** — it cannot map this to a standard license at all.
   The claim cites both mulberrysymbols.org and the GitHub repo as sources, but those two sources disagree with each other, and the claim reports only one side without noting the conflict. This matters: 2.0 UK and 4.0 have materially different TPM clauses and different compatibility sets (4.0 is one-way GPLv3-compatible; 2.0 UK is not).

2. MULBERRY IS NOT VANILLA CC BY-SA. The site adds: "While you may charge for your product or added value, you must not charge for the symbols themselves" and "They are to remain free of cost and freely available to all." CC BY-SA explicitly permits commercial use and charging — this is an extra restriction bolted on by the licensor, which is almost certainly why GitHub returns NOASSERTION. The claim reasons as if this were stock BY-SA. For a paid app it's probably fine (you'd be charging for the app, not the symbols), but it is an unresolved non-standard term, not boilerplate.

3. THE OMITTED RISK — ANTI-DRM/TPM vs. THE APP STORE. This is the actually load-bearing legal-regulatory issue for a Flutter app shipping to iOS, and the claim never mentions it. CC BY-SA 2.0 UK §2.1 forbids imposing "digital rights management technology on the Work...that alters or restricts the terms of this Licence." CC's FAQ: "The use of any effective technical protection measures (such as digital rights management or 'DRM') by licensees to prevent others from exercising the licensed rights is prohibited." Apple applies FairPlay DRM to App Store binaries. Critically, this clause attaches to distributing the Work at all — NOT only to adaptations — so it bites on exactly the "mere aggregation is safe" path the claim declares risk-free. Precedent: VLC was pulled from the App Store in Jan 2011 after copyright holder Rémi Denis-Courmont filed an infringement notice over GPL/App-Store-DRM incompatibility. CC 4.0 deliberately defused this (§2(a)(5)(B) adds the qualifier "if doing so restricts exercise of the Licensed Rights," and §2(a)(4) has the licensor waive any right to forbid circumvention of Effective Technological Measures). So the version ambiguity in (1) directly determines whether this risk is live: if Mulberry is 4.0, largely defused; if 2.0 UK, arguable and unresolved.

4. THE OBLIGATION IS OVERSTATED. ShareAlike triggers on *Sharing* the adaptation. Shipping restyled symbols inside the app already constitutes sharing them under BY-SA — there is no separate duty to "publish the restyled symbol set" as a standalone deliverable, and unlike the GPL, CC has no source-provision requirement (no obligation to ship editable SVGs). The claim's practical burden is wrong, though it errs toward over-compliance, which is harmless.

NET: directionally right, cited version unreliable, and it clears the wrong risk. "Does SA infect my code?" — no. "Can I ship CC BY-SA symbols in an iOS binary?" — that's the real question, and the claim doesn't touch it.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "legal-regulatory". A product decision depends on it, so it must be right.

CLAIM: CC BY-SA on symbols does NOT infect your Flutter app code — ShareAlike reaches adaptations of the symbols, not the app bundling them
THEIR DETAIL: This is the standard fear that pushes teams to pay for proprietary sets unnecessarily. Under CC BY-SA, shipping unmodified symbols alongside proprietary code is a 'collection'/mere aggregation: the app remains proprietary, the symbols stay CC BY-SA. ShareAlike bites only if you MODIFY a symbol (recolor, restyle for the dark theme, redraw) — those adapted symbols must themselves be released under CC BY-SA 2.0 UK or a compatible license. Practical consequence: if you restyle Mulberry symbols to fit the calm dark aesthetic, you must publish the restyled symbol set. That is cheap, and is arguably good community marketing for this audience.
THEIR CLAIMED SOURCES: https://mulberrysymbols.org/, https://github.com/mulberrysymbols/mulberry-symbols
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
