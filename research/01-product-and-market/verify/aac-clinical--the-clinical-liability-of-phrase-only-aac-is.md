# aac-clinical--the-clinical-liability-of-phrase-only-aac-is

> Phase: **verify** · Agent `a3931c49ecc28e19d` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The core finding stands and the product decision is sound: type-to-speak must be co-equal and first-class, not a secondary tab. This is directly supported by Martin & Nagalakshmi's "Aging Up AAC" (arXiv 2404.17730), where all 12 autistic adult participants wanted typing options at least occasionally, 7 explicitly wanted to mix symbols with typing, and participants named the symbol-app/typing-app split as a pain point ("I don't want to have to keep switching"). Both cited statistics are exact.

Three corrections:
(1) Drop the second source. PMC8992808 (Zisk & Dalton, Autism in Adulthood, 2019) does not support the claim — it never discusses core vocabulary or the pre-stored-message limitation, and treats typing as one option among many rather than essential.
(2) Stop citing core vocabulary as the authority for the text box. Core-vocab doctrine's remedy for phrase-only systems is generative CORE WORDS (~200 words ≈ 80% of speech, enabling Spontaneous Novel Utterance Generation), not text entry. Unlimited-vocabulary-by-spelling is the separate alphabet-based AAC tradition for literate users. The right framing: for a literate adult, spelling delivers unrestricted expressive range — that argument stands alone and doesn't need core-vocab's backing.
(3) Replace "clinically indefensible" with the literature's actual, softer position: pre-stored phrases "can play an important role on a communication system, but should not only be what is available to the communicator."

Confidence should be medium-high, not high: the load-bearing source is a non-peer-reviewed preprint with n=12. But it is unusually well-matched to this product — only 2 of 12 participants were full-time AAC users; the rest were part-time/semi-speaking/unreliable-speech users, which is precisely the situational-speech-loss target population.

Actionable design implication the claim understates: since core-vocab doctrine is NOT what licenses the text box, the product cannot assume phrases + typing covers the full range. Typing is slow and high-effort exactly when the app is needed most (mid-shutdown). Consider whether a word-level recombination layer, or fast phrase-editing before speaking, belongs on the roadmap between the two modes.

**Evidence:** I attempted to refute this on four fronts. The decision-relevant core survived; two supporting specifics did not.

WHAT HELD UP (verified directly against the primary source):
Fetched https://arxiv.org/html/2404.17730v3 — "Aging Up AAC: An Introspection on AAC Applications for Autistic Adults," Lara J. Martin & Malathy Nagalakshmi. Every cited statistic is exact, not approximated:
- 12 autistic adult participants, ages 18-44, US-based native English speakers. CORRECT.
- ALL 12 wanted some typing input option at least occasionally. CORRECT as stated.
- 7 participants explicitly suggested "supplementing or mixing symbol usage with typing." CORRECT, verbatim phrase match.
- The typing/symbol divide is real and participant-voiced: "[I dislike] symbols and typing being so completely separate in different apps...I don't want to have to keep switching."
- Infantilization is explicitly discussed: "Many AAC apps feel like they're made for kids or students, and it feels infantilizing."
- Participant quote directly endorses the MVP's shape: "Future AAC that has both symbols and typing and a vocabulary designed for autistic adults would be very empowering."
The general AAC literature also independently corroborates the phrase-only critique: the field's stated rationale is Spontaneous Novel Utterance Generation (SNUG) — "if you only have pre-set phrases, you can never say anything new" — and the standard illustration is the pre-set "I want pizza" button that fails the moment the user doesn't want pizza. So the substantive critique is genuine and correctly characterized.

DEFECT 1 — THE SECOND SOURCE DOES NOT SUPPORT THE CLAIM. PMC8992808 is Zisk & Dalton, "AAC for Speaking Autistic Adults: Overview and Recommendations," Autism in Adulthood, 2019. Fetched it directly: it does NOT discuss core vocabulary vs. fringe/pre-stored vocabulary, and does NOT address the "only say what was predicted" limitation. It treats typing as one option among many ("for some people, and in some situations, simply writing or typing is sufficient"), explicitly NOT as an essential or co-equal requirement. This citation is padding; it was likely included for topical adjacency (autistic adults + AAC) rather than because it says what the claim needs. Drop it. Its one genuinely useful contribution is orthogonal: multi-modality increases flexibility across environments.

DEFECT 2 — CORE VOCABULARY IS MISATTRIBUTED AS THE AUTHORITY. The claim says the phrase-only critique "is the reason core vocabulary exists as a doctrine at all," then uses that to conclude the type-to-speak box is what makes the design defensible. This is a conflation of two distinct AAC lineages. Core vocabulary doctrine's answer to the phrase-only problem is CORE WORDS — a generative single-word grid (~200 words = ~80% of what we say), recombined into novel utterances. Its answer is NOT a text box. Unlimited-vocabulary-via-spelling is the separate alphabet-based AAC tradition (Proloquo4Text, WordPower's spelling layer), aimed at literate users. So core vocabulary doctrine cannot be cited as the authority for a text box; if anything, a strict core-vocab clinician would say a phrase grid + text box is still missing the middle layer — word-level generative combination — and note that spelling is slow under duress, which is exactly when this product is used. The conclusion happens to survive for THIS product's population (for a literate adult, spelling genuinely does deliver unlimited expressive range), but it survives on its own merits, not on core-vocab's authority.

DEFECT 3 — "CLINICALLY INDEFENSIBLE" IS RHETORIC, NOT A STANDARD. No clinical body was found holding that a phrase grid without text entry is indefensible. The literature's actual position is softer and I quote it as found: phrases "can play an important role on a communication system, but should not only be what is available to the communicator." That supports the product decision without the overreach.

CONFIDENCE CALIBRATION — "high" is somewhat overstated on evidence weight, though not on direction. The load-bearing source is a non-peer-reviewed arXiv preprint (v1 Apr 2024, v3 Aug 2025, no venue in the comments field; no ASSETS/CHI acceptance found), n=12, qualitative. Nothing indicates it is outdated. One genuinely favorable nuance the researcher missed and should claim: only 2 of the 12 were full-time AAC users — the rest were part-time, "semi-speaking" or "unreliable speech" users. That population maps unusually well onto this product's stated target of situational speech loss, which makes the source MORE apt here than the researcher argued, not less.

NET: the product decision (ship type-to-speak as co-equal and first-class, not a secondary tab) is well-supported and should proceed. Fix the citation, drop the core-vocab authority argument, soften "indefensible."

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "aac-clinical". A product decision depends on it, so it must be right.

CLAIM: The clinical liability of phrase-only AAC is that the user can only say what someone predicted they would want to say — the type-to-speak box is what makes the design defensible, not an add-on
THEIR DETAIL: This is the classic and correct AAC critique of pre-stored-message systems, and it is the reason core vocabulary exists as a doctrine at all. A grid of phrases without a text escape hatch would be clinically indefensible for a literate adult: it caps expressive range at the author's imagination and reproduces the infantilization the product exists to fix. The MVP already includes 'type to speak' — the finding is that this must be framed as CO-EQUAL and first-class, not a secondary tab. Corroborated by the 'Aging Up AAC' study (arXiv 2404.17730): all 12 autistic adult participants wanted typing options alongside symbols, and 7 explicitly wanted 'mixing symbol usage with typing' rather than being forced to choose between separate apps. Participants identified a 'problematic divide': typing apps lack symbol support, symbol apps feel slow and infantilizing. The hybrid MVP is precisely the identified gap.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v3, https://pmc.ncbi.nlm.nih.gov/articles/PMC8992808/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
