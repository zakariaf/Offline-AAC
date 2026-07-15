# legal-regulatory--the-mdr-hook-is-compensation-for-a-disabilit

> Phase: **verify** · Agent `a62b925d461c1b4bf` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** MDR Art 2(1) does list "compensation for, an injury or disability" as a medical purpose, and an AAC app marketed to people with speech disability will almost certainly qualify as a medical device — MHRA lists "communication aids" as an example, and Smartbox's Grid Pad is a Class 1 medical device. But two corrections: (1) The trigger is NOT the product's inherent function. MDR Art 2(12) defines intended purpose by "the data supplied by the manufacturer on the label, in the instructions for use or in promotional or sales materials"; MHRA says compensation-for-disability equipment "may or may not be a medical device... depend[ing] entirely on the claims made by the manufacturer." Claims are exactly the lever — the claim asserts the opposite. (2) Being in scope is far cheaper than implied. Under MDCG 2019-11 Rev.1 Rule 11, an AAC app is neither diagnostic/therapeutic decision support nor physiological monitoring, so "all other software is classified as class I" applies: self-certification, NO notified body, no clinical investigation. Obligations reduce to technical documentation, a QMS, declaration of conformity, PMS, and EUDAMED registration (mandatory since 28 May 2026). So this is not "the single largest strategic tension" and not a choice between MDR and discoverability — the standard industry path is to declare the AAC purpose honestly, self-certify Class I, and market to the real audience. Note also Rev.1 narrows the "simple search" carve-out ("would not be considered... 'Simple search' if it contributes to achieving a medical purpose"), so gaming the technical exemption is the route that does not work — while the strategic burden is much lower than claimed. Caveat: this is EU/UK scope only; the researcher's US FDA position (where FDA has long exercised enforcement discretion over AAC/SGD software) was not assessed here and should be checked separately.

**Evidence:** VERIFIED CORRECT: I extracted the cited PDF directly (pypdf) and confirmed the Art 2(1) quote verbatim: "diagnosis, monitoring, treatment, alleviation of, or compensation for, an injury or disability", under a chapeau requiring "one or more of the following specific medical purposes". Their URL is also CURRENT — it now serves MDCG 2019-11 Rev.1 (June 2025), not the 2019 original, so there is no staleness defect.

The qualification instinct is corroborated independently: MHRA's "Assistive technology: definition and safe use" (updated 23 May 2025) lists "communication aids" among example medical devices; Smartbox markets Grid Pad as a Class 1 Medical Device, and Grid/Grid Pad are listed on MedicalExpo as medical devices. Rev.1 also NARROWS the technical escape hatch, supporting them: "software would not be considered as conducting 'Simple search' if it contributes to achieving a medical purpose."

REFUTED ELEMENT 1 — the mechanism is backwards. MDR Art 2(12) (quoted in the same MDCG doc) defines: "'Intended purpose' means the use for which a device is intended according to the data supplied by the manufacturer on the label, in the instructions for use or in promotional or sales materials or statements and as specified by the manufacturer in the clinical evaluation." The trigger is the manufacturer's DECLARED claims, not the product's inherent function. MHRA is explicit that equipment for "alleviation of, or compensation for, a disability MAY OR MAY NOT be a medical device... This will depend entirely on the claims made by the manufacturer for each product." So "you cannot dodge it by avoiding medical claims, because helping someone speak IS the compensation" states the law inversely. The claim is also self-contradictory: it concedes the note-taking framing "would technically move it out of scope", which admits claims are precisely the trigger.

REFUTED ELEMENT 2 — decisive omission of classification. MDCG Rev.1 Rule 11 ends: "All other software is classified as class I." An AAC app provides no information used to take decisions with diagnosis or therapeutic purposes (sub-rule 11a) and does not monitor physiological processes (11b), so it falls to 11c → Class I. Rule 13 likewise: "if no other rule applies, all other active devices are class I." Class I = self-certification, no notified body, no clinical investigation. This collapses the claimed dilemma. The real obligations are technical documentation, QMS, declaration of conformity, PMS, and EUDAMED registration (the four modules became mandatory 28 May 2026 per Commission Decision (EU) 2025/2371) — real but routine, not existential.

NET: the binary framing ("destroy discoverability or face MDR") is a false dilemma, and "the single largest strategic tension in the product" is overstated. There is a well-trodden third path the incumbent AAC industry already uses: declare the AAC intended purpose, self-certify as Class I, market openly to the actual audience. Confidence "high" was not warranted for the strategic conclusion.

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

CLAIM: The MDR hook is 'compensation for a disability' — you cannot dodge it by avoiding medical claims, because helping someone speak IS the compensation
THEIR DETAIL: MDR Art. 2(1) defines a medical device as intended for '...diagnosis, monitoring, treatment, alleviation of, or compensation for, an injury or disability.' An AAC app's entire purpose is compensating for a speech disability. Unlike a wellness app, there is no framing that removes the medical purpose while keeping the product's value — the intended purpose IS the trigger. Marketing it as a 'note-taking app that reads text aloud' would technically move it out of scope but destroys discoverability for the actual audience. This is the single largest strategic tension in the product.
THEIR CLAIMED SOURCES: https://health.ec.europa.eu/document/download/b45335c5-1679-4c71-a91c-fc7a4d37f12b_en?filename=md_mdcg_2019_11_guidance_qualification_classification_software_en.pdf
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
