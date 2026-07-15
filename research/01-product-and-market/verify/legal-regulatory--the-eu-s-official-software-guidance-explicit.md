# legal-regulatory--the-eu-s-official-software-guidance-explicit

> Phase: **verify** · Agent `a24d01b2b26e08f81` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction needed to the factual claim. Optional framing refinement: the guidance names a category of AAC app rather than "this exact app," and MDCG documents are authoritative-but-non-binding guidance. Class I per Rule 11c is the residual lowest risk class, requiring self-certification rather than notified-body review - but still full MDR obligations (CE mark, technical file, DoC, QMS, EUDAMED/UDI registration, PMS). Note also that the classification presupposes qualification as MDSW, and the guidance's own quotation of MDR Art. 2(1) ("compensation for ... a disability") means marketing the app as a non-medical "accommodation" does not avoid qualification - which strengthens rather than weakens the researcher's conclusion.

**Evidence:** Attempted refutation; every specific held against the primary source. Downloaded MDCG 2019-11 Rev.1 PDF directly from health.ec.europa.eu (489,666 bytes, matching the 478 KB announced) and extracted text with pypdf.

VERIFIED VERBATIM (printed page 35 = PDF page 36 of 36, under section "11. Annex IV - Classification examples"): "MDSW app intended to assist persons with a communication disorder (e.g. cerebral palsy, autism (ASD), selective mutism, MS, MND, Down's syndrome, aphasia, etc.) talk by converting a set of selected symbols into spoken language. Depending on the patient's medical status, the selection can be done through various means such as a touch screen, head tracking or eye gaze. This MDSW app should be classified as class I per Rule 11c." Exact character-for-character match to the quoted detail.

DOCUMENT IDENTITY: Title page reads "MDCG 2019-11 rev. 1 ... October 2019 / June 2025 rev.1". EC announcement page confirms publication 17 June 2025. CONFIRMED.

"ADDED IN REV.1" CLAIM - INDEPENDENTLY STRESS-TESTED: Downloaded the 2019 original (health.ec.europa.eu/system/files/2020-09/md_mdcg_2019_11_guidance_en_0.pdf, 29 pages vs Rev.1's 36). Zero hits for aphasia, autism, mutism, symbol, cerebral palsy, eye gaze, communication disorder. Critically, I guarded against a false-negative from image-based PDF/extraction failure: the 2019 original yielded 75,807 chars of real text, contained 4 hits for "11c", AND already contained Annex IV plus the fertility/conception example that sits directly above the AAC example in Rev.1. So Annex IV existed and extraction worked - the AAC example was genuinely appended to that list in Rev.1. Researcher's finding is real, not an artifact.

CURRENCY CHECK (today is 2026-07-15): No Rev.2 exists. Rev.1 remains current.

CAVEATS that temper framing without refuting: (1) "this exact app" is rhetorical - the guidance names a category, not the product, though the match is genuinely close. (2) MDCG guidance is not legally binding; it is guidance applied in practice by notified bodies and competent authorities. (3) The brief's "accommodation, not a networked service" framing is NOT an escape hatch and cuts against the product: the guidance quotes MDR Art. 2(1) (lines 261-262, 664-665) defining medical purpose to include "alleviation of, or compensation for, an injury or disability" - exactly the MVP's job. By labeling the example "MDSW app," MDCG asserts qualification, not merely classification. (4) Class I per Rule 11c is the residual lowest class - no notified body for Class I non-sterile/non-measuring, but still CE marking, technical documentation, self-certification, Declaration of Conformity, QMS, EUDAMED/UDI registration, post-market surveillance. (5) EU only; says nothing about FDA or UK MDR 2002.

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

CLAIM: The EU's official software guidance explicitly names this exact app as a Class I medical device — the example is almost a description of the MVP
THEIR DETAIL: MDCG 2019-11 Rev.1 (published 17 June 2025), page 35, Annex example list: 'MDSW app intended to assist persons with a communication disorder (e.g. cerebral palsy, autism (ASD), selective mutism, MS, MND, Down's syndrome, aphasia, etc.) talk by converting a set of selected symbols into spoken language. Depending on the patient's medical status, the selection can be done through various means such as a touch screen, head tracking or eye gaze. This MDSW app should be classified as class I per Rule 11c.' Verified by extracting the PDF text directly, not via a summarizer. The example names autism, selective mutism and aphasia — three of the four target populations in the product brief. This example was ADDED in Rev.1; it is not in the 2019 original (I checked the original PDF: zero hits for 'aphasia', 'autism', 'mutism', 'symbol').
THEIR CLAIMED SOURCES: https://health.ec.europa.eu/document/download/b45335c5-1679-4c71-a91c-fc7a4d37f12b_en?filename=md_mdcg_2019_11_guidance_qualification_classification_software_en.pdf, https://health.ec.europa.eu/latest-updates/update-mdcg-2019-11-rev1-qualification-and-classification-software-regulation-eu-2017745-and-2025-06-17_en
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
