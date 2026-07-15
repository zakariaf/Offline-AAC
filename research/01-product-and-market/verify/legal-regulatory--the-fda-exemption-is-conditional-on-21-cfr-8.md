# legal-regulatory--the-fda-exemption-is-conditional-on-21-cfr-8

> Phase: **verify** · Agent `a8c313b0977c0799f` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** The core claim stands; these are refinements, not refutations.

1) MATERIAL — the AI/LLM flag is filed under the wrong prong and is overstated. The researcher flags LLM phrase prediction as possibly "different fundamental scientific technology" under 890.9(b). This is weak: FDA's own (b) examples are physical modality swaps (laser vs. metal blade; DNA probe vs. culture), and word/phrase prediction has shipped in legally marketed SGDs (Dynavox, TouchChat, Proloquo) for decades — it is squarely within "existing or reasonably foreseeable characteristics." The real trigger for "any inference about the user's state" is prong (a), INTENDED USE: inferring a user's mental/emotional/clinical state is a "different medical purpose" and voids the exemption on that basis. Right instinct, wrong mechanism. If AI features are later scoped, the analysis to run is (a), not (b).

2) MINOR — 890.9(b) reads "The MODIFIED device operates using..."; the researcher's paraphrase drops "modified," which slightly changes what the clause textually keys on.

3) OMISSION — "the exemption holds comfortably" is true but narrower than it sounds. A 510(k) exemption is not a regulatory exemption. ILQ is Class II 510(k)-exempt but NOT GMP-exempt, so if the app meets the device definition it still carries establishment registration, device listing, labeling, and MDR obligations, plus the Quality Management System Regulation (21 CFR 820) — note the QSR-to-QMSR transition took effect Feb 2, 2026 and is now live.

4) SCOPE CAVEAT — the whole 890.9 analysis presupposes the app IS a device. 890.3710 requires the device be "intended for medical purposes" and used "by persons unable to use normal communication methods because of physical impairment." An app marketed as a general accessibility/communication tool without medical claims may fall outside the device definition entirely (consistent with the fact that most consumer AAC apps are not FDA-registered). Separately, "physical impairment" is an awkward textual fit for situational speech loss from autistic shutdown or selective mutism — worth noting if the team ever wants to claim the SGD classification affirmatively (e.g., for Medicare DME coverage, which requires it).

**Evidence:** Verified verbatim against the current eCFR (fetched raw via the eCFR renderer API, bypassing the summarizer).

21 CFR 890.9, current text, opening: "The exemption from the requirement of premarket notification (section 510(k) of the act) for a generic type of class I or II device is only to the extent that the device has existing or reasonably foreseeable characteristics of commercially distributed devices within that generic type..." — matches the researcher's quote exactly.

(a) "The device is intended for a use different from the intended use of a legally marketed device in that generic type of device; e.g., the device is intended for a different medical purpose, or the device is intended for lay use where the former intended use was by health care professionals only;"
(b) "The modified device operates using a different fundamental scientific technology than a legally marketed device in that generic type of device; e.g., a surgical instrument cuts tissue with a laser beam rather than with a sharpened metal blade, or an in vitro diagnostic device detects or identifies infectious agents by using deoxyribonucleic acid (DNA) probe or nucleic acid hybridization technology rather than culture or immunoassay technology; or"
(c) in vitro diagnostic carve-outs (1)-(9) — irrelevant to AAC.

Citation line: [65 FR 2321, Jan. 14, 2000]. NOT amended since 2000, so no staleness risk as of 2026-07-15.

The conditionality chain is confirmed at the source. 21 CFR 890.3710(b), current text: "Classification. Class II (special controls). The device is exempt from the premarket notification procedures in subpart E of part 807 of this chapter subject to § 890.9." [48 FR 53047, Nov. 23, 1983, as amended at 63 FR 59231, Nov. 3, 1998]. Product code ILQ ("System, communication, powered"), Physical Medicine panel, Class II, 510(k)-exempt — independently corroborated by payer policy documents (Cigna, Molina) that describe SGDs as regulated under 890.3710 / ILQ and exempt from 510(k).

Independently checked the fallback path and found none: I extracted the full text of all 45 pages of FDA's "Policy for Device Software Functions and Mobile Medical Applications" (issued Sept 27, 2019; minor 2022 update) and grepped it. It contains ZERO occurrences of "speech", "augmentative", "impairment", "disabilit", or "890.3710". There is no AAC-specific enforcement-discretion carve-out in Appendix A/B/C. This means 890.3710 + 890.9 is indeed the operative analysis, which strengthens rather than undermines the researcher's framing.

Both quoted phrases are exact, the citation is correct, the regulation is current, and it is correctly applied to the SGD generic type. The conclusion that a tap-a-tile / type-to-speak AAC app sits within existing SGD characteristics is well-supported: 890.3710's own examples ("a specialized typewriter, a reading machine, and a video picture and word screen") describe exactly this functionality. Confidence level "high" is warranted for the core claim.

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

CLAIM: The FDA exemption is conditional on 21 CFR 890.9 — a novel intended use or novel technology voids it
THEIR DETAIL: 890.9 limits the exemption to devices with 'existing or reasonably foreseeable characteristics of commercially distributed devices' in that category. A 510(k) becomes required if the device (1) has an intended use different from a legally marketed device, or (2) 'operates using a different fundamental scientific technology.' A tap-a-tile / type-to-speak AAC app is squarely within existing SGD characteristics, so the exemption holds comfortably. Flag for later: bolting on AI/LLM phrase prediction or any inference about the user's state could arguably be 'different fundamental scientific technology' and is the kind of feature that would need re-analysis before shipping.
THEIR CLAIMED SOURCES: https://www.law.cornell.edu/cfr/text/21/890.9
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
