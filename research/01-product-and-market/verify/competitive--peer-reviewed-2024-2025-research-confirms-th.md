# competitive--peer-reviewed-2024-2025-research-confirms-th

> Phase: **verify** · Agent `ae7f80e77a4f6dae2` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Qualitative PREPRINT research (not peer-reviewed) documents the infantilization complaint in autistic adults' own words. arXiv 2404.17730v3, "Aging Up AAC" (Martin & Nagalakshmi, UMBC/Penn; v1 Apr 2024, v3 Aug 2025), interviews with 12 autistic adults across Proloquo2Go, Proloquo4Text, Proloquo, CoughDrop, TD Snap and others. Verbatim: "Many AAC apps feel like they're made for kids or students, and it feels infantilizing." Five participants explicitly wanted apps tailored for autistic adults. Ten of 12 raised affordability as an access barrier, with iOS-exclusivity compounding cost via expensive Apple hardware. Ten flagged poor TTS quality; four specifically cited missing nonbinary/middle-pitch voices — a specific, unserved, high-signal need for this audience. CORRECTIONS: (a) the paper is an arXiv preprint with no journal-ref, empty comments field, and no ACM/conference publication — cite it as qualitative preprint evidence, not peer-reviewed research; (b) the word-frequency-tracking ask came from ONE participant and was a data-logging/privacy objection, not a generalized finding about child-focused SLP surveillance; (c) arXiv 2507.00202 is NOT a companion paper — it is by a separate team (Frisch, Peters & Vertanen, Michigan Tech/OHSU), is also an unpublished preprint, and is an n=5 asynchronous text focus group. Appropriate confidence: MEDIUM. The direction is well-supported and usable for positioning; the evidentiary weight is two small-n unrefereed preprints.

**Evidence:** VERIFIED AS STATED (checked against arxiv.org/html/2404.17730v3 full text):
- Quote is verbatim, §5.3.1: "Many AAC apps feel like they're made for kids or students, and it feels infantilizing."
- 5 participants wanting adult-tailored apps: exact. "Participants (5) were of the opinion that AAC needs to be tailored for autistic adults, especially since they are often targeted toward children."
- 10 of 12 on cost: exact. "Most participants (10) spoke explicitly about how affordability played an important role in choosing an AAC application." Also 5 avoided full price, 4 gravitated to free apps.
- App list (Proloquo2Go, Proloquo4Text, Proloquo, CoughDrop, TD Snap): confirmed in Table 1 (also My Voice, ClaroCom, Speech Assistant, Tell Me, Predictable, UbiDuo, BuzzCards).
- iOS-exclusivity / Apple hardware cost: confirmed §5.6.3, quote "I don't take my iPad with me [most] of the time. It was expensive, and I don't want to break it."
- TTS: 10 participants raised poor TTS quality; "there are not enough nonbinary or middle-pitch voice options (4)"; 3 could not adjust pitch.
- Both arXiv IDs are real; titles/authors/participant counts correct (2404.17730 = Martin & Nagalakshmi, n=12, interviews; 2507.00202 = Frisch, Peters & Vertanen, n=5, focus group).

REFUTED / CORRECTED:
1. NOT PEER-REVIEWED (the load-bearing error). 2404.17730v3 self-labels "Preprint; 2025; arXiv"; arXiv comments field is empty; no journal-ref; only DOI is arXiv's auto-assigned 10.48550/arXiv.2404.17730. No ACM DL / ASSETS 2025 / CHI / CSCW proceedings record found. One search snippet claimed "Proceedings of an ACM Conference" — contradicted by the paper's own header and unsupported by any DL record; treated as search-engine confabulation. 2507.00202 is likewise an unpublished preprint. Neither has cleared peer review.
2. WORD-FREQUENCY ASK IS n=1, NOT A FINDING, AND THE RATIONALE IS MISREAD. One participant of twelve raised it, and the stated reason was data-logging/privacy — "no recording of word frequency usage...especially since this can be seen as another way of logging data" — with SLP reporting named as the mechanism ("what words I need to practice or whatever"). The gloss "ELIMINATION of word-frequency tracking (reads as child-focused SLP surveillance)" upgrades one voice into a design requirement and reframes a privacy objection as an infantilization objection.
3. 2507.00202 IS NOT A COMPANION PAPER. Entirely different authors and institutions (Frisch/Peters/Vertanen, Michigan Tech + OHSU) vs Martin/Nagalakshmi (UMBC + Penn). It only cites the other work. Method is an asynchronous text-based focus group (Flarum, 5 weeks, 64 posts, ~20k words), n=5 — not interviews.

MATERIALITY: The competitive thesis survives — the infantilization complaint IS documented in autistic adults' own words, and the cost and TTS-voice findings are accurate and quotable. But the evidence base is two small-n unrefereed preprints (n=12, n=5), not peer-reviewed research. Stated confidence "high" exceeds the warrant. Note the shutdown-driven dynamic communication need (central to the product positioning) comes from the weaker n=5 preprint, making that pillar the thinnest.

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

CLAIM: Peer-reviewed 2024-2025 research CONFIRMS the infantilization complaint in autistic adults' own words — this part of the thesis is solid
THEIR DETAIL: arXiv 2404.17730v3, 'Aging Up AAC', qualitative interviews with 12 autistic adults across Proloquo2Go, Proloquo4Text, Proloquo, CoughDrop, TD Snap. Direct quote: 'Many AAC apps feel like they're made for kids or students, and it feels infantilizing.' Five participants explicitly wanted apps tailored for autistic adults. Asks: adult-level vocabulary; symbol→text transition as users mature; ELIMINATION of word-frequency tracking (reads as child-focused SLP surveillance). Ten of 12 raised cost as an access barrier; noted iOS-exclusivity compounds cost since Apple hardware is expensive. Also flagged: poor TTS voice quality/variety, especially missing nonbinary/middle-pitch voices (a specific, unserved, high-signal need for this exact audience). Companion paper arXiv 2507.00202 covers autistic adults' AAC experiences in community settings.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v3, https://arxiv.org/pdf/2507.00202
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
