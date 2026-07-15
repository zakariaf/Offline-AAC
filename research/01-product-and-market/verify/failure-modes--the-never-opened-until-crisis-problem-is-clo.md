# failure-modes--the-never-opened-until-crisis-problem-is-clo

> Phase: **verify** · Agent `a7b51bbe3634aeaf3` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Designing for everyday low-demand use (tiredness, "I don't want to talk right now", partial-speech days) is a genuinely good recommendation and should be adopted — but as an opportunity, not a rescue from a near-fatal flaw. "Close to fatal" is overstated and contradicted by its own primary source: in Aging Up AAC (arXiv 2404.17730), only 2 of 12 participants used AAC full-time — 10 of 12 were persisting PART-TIME users, making situational use the dominant pattern in this exact population rather than a doomed one. Those same participants converged on this product's design unprompted: 10 of 12 valued pre-saved phrases, one explaining "I can pre-program phrases before I enter a situation" — the paper frames pre-programmed phrases as the remedy for intermittent use, not its casualty. The claim's "only escape" framing is false: the paper documents part-time users succeeding via search and predictive text, i.e. retrieval-free access (already in the MVP as type-to-speak) is a second, cheaper escape. The symbol-location findings (6/12) concern large clinician-authored symbol boards with navigation hierarchies and do not transfer cleanly to a dozen self-authored phrase tiles. The statistics should be dropped or restated: the ~30% figure is Phillips & Zhao's 29.3% for assistive technology GENERALLY (mobility aids worst), not AAC; "most within the first three months" contradicts that same source, which says abandonment peaks in the first year and after five years; theaacacademy.org cites no statistics whatsoever; and the ~39% figure is Johnson et al. (2006), a survey of SLPs about clinician-prescribed devices — a prescription model whose abandonment drivers (team/training/funding failure, no user buy-in) are precisely what a free, self-selected, no-account app avoids, so its base rate does not transfer. Finally, the literature identifies a different primary barrier worth designing against: social fear and masking ("I've not been brave enough to use it"), not motor retrieval — and the 2025 companion paper (arXiv 2507.00202) explicitly recommends building "AAC options that support communication when autistic adults are in shutdown," endorsing crisis-time AAC as a design target. Recommended confidence: medium on the prescription, low on the severity.

**Evidence:** The design recommendation is sound and the arXiv numbers are exact. The central severity assertion ("close to fatal") is contradicted by the very paper cited as its direct evidence, and the abandonment statistics are misattributed, self-contradictory, and drawn from a population/model that is the inverse of this product's.

WHAT CHECKS OUT (verified directly against arxiv.org/html/2404.17730v1, "Aging Up AAC," 12 autistic adults, US, 18-44):
- "11 of 12 raised concerns about communication speed" — EXACT.
- "6 of 12 reported troubles locating button words on the board" — EXACT.
- "would need to use it regularly enough to memorize the symbol locations" — a real quote. Note the researcher UNDERSTATED it: 3 of 12 said this, not "one."
- "3 of 12 struggled to remember where everything is and what it can do" — EXACT.
So the researcher read this paper honestly. The problem is what they did with it.

REFUTATION 1 — THE CITED PAPER ARGUES THE OPPOSITE. Only 2 of 12 participants used AAC full-time; the other 10 were PART-TIME users, self-identifying from "mostly non-speaking" to "semi-speaking." Situational, intermittent AAC use is the DOMINANT pattern in precisely this population — the normal case, not a fatal edge case. A paper documenting 10 persisting part-time users cannot support "part-time use is close to fatal."

REFUTATION 2 — PARTICIPANTS INDEPENDENTLY DESIGNED THE MVP. Ten of 12 valued saving common messages in advance. One: "I can pre-program phrases before I enter a situation, so if I'm gonna order, I don't have to type it as I go." That is the product. The paper notes this strategy "particularly helps part-time users manage unpredictable situations" — pre-programmed phrases are documented as the SOLUTION to intermittent use, not a victim of it.

REFUTATION 3 — "THE ONLY ESCAPE" IS FALSE. The claim states the only escape is abandoning break-glass positioning. The paper records part-time users successfully navigating the memorization problem via SEARCH and PREDICTIVE TEXT. Retrieval-free access is a documented escape hatch, and type-to-speak is already in the MVP.

REFUTATION 4 — CATEGORY ERROR ON THE SYMBOL FINDINGS. The 6/12 finding is "locating button words on the board" — large clinician-authored symbol grids with navigation hierarchies (Proloquo/TouchChat-class). The MVP is a small self-authored phrase-tile grid plus a text box. Transplanting retrieval failure from a 100+ cell imposed symbol hierarchy onto a dozen user-written tiles is not supported; self-authored content is materially more memorable than imposed symbol sets.

REFUTATION 5 — THE STATISTICS PACKAGE FAILS ON EVERY COUNT.
(a) "~30% of AAC users abandon their systems" — MISATTRIBUTED. Phillips & Zhao (1993, PMID 10171664) found 29.3% of devices abandoned across ASSISTIVE TECHNOLOGY GENERALLY, explicitly noting "mobility aids were more frequently abandoned than other categories." It is not an AAC statistic. It has been relabeled.
(b) "most within the first three months" — CONTRADICTS THE CITED SOURCE. Phillips & Zhao states abandonment "rates were highest during the first year and after 5 years of use." The "first three months" figure traces to a 2007 RESNA student conference proceeding (Rincon), not to the primary source cited alongside it. The claim cites a source that refutes its own timeline.
(c) theaacacademy.org/course/what-leads-to-aac-abandonment — CITES NO STATISTICS AT ALL. It is a course marketing page stating the session will "explore the rate of AAC abandonment." It supports none of the three numbers attributed to it. Instructors are described as "currently engaged in research" — i.e., unpublished.
(d) "only ~39% still use AAC a year after introduction" — appears in NONE of the three cited sources. It is Johnson et al. (2006), which surveyed SPEECH-LANGUAGE PATHOLOGISTS about their caseloads: clinician-PRESCRIBED devices, predominantly for people with significant disabilities, in a prescription-and-training model. That is the inverse of a free, self-selected, zero-login download chosen by an autistic adult for themselves. Prescribed-device abandonment is overwhelmingly driven by team/training/funding failure and lack of user buy-in — the exact failure modes a self-chosen no-account app sidesteps. Importing this base rate onto voluntary self-selected software is invalid.

REFUTATION 6 — THE LITERATURE ENDORSES CRISIS-TIME AAC AS A DESIGN TARGET. The 2025 companion paper (arXiv 2507.00202) explicitly recommends designing "AAC options that support communication when autistic adults are in shutdown," and documents shutdown creating "dynamic communication needs." AssistiveWare's part-time AAC guidance presents situational use as legitimate and standard — "switching back and forth is just fine" — and highlights AAC's value specifically during overwhelm and meltdown, including preventing restraint in psychiatric settings. Nobody in this literature treats crisis-time AAC as doomed.

REFUTATION 7 — THE REAL BARRIER IS MIS-IDENTIFIED. The 2025 paper found the dominant obstacle is not motor retrieval but SOCIAL FEAR and masking: "I have a communication book...but I've not been brave enough to use it" (P5); "compulsive masking and social anxiety...hinder me from adapting to my own needs" (P2). Notably it found "rather than documenting actual abandonment, researchers identified psychological barriers preventing adoption." Optimizing for muscle memory while ignoring the courage-to-use-it-in-public barrier would target the wrong failure mode.

CORRECT TAKEAWAY: The prescription ("design for everyday low-demand use; situational speech loss is a spectrum, not a binary") is well-supported and worth adopting — 10/12 part-time users and the AssistiveWare framing both back it. But it should be adopted as an OPPORTUNITY (this is how the majority of the target population already lives), not as an escape from a near-fatal flaw. Confidence "high" is not warranted on the severity claim; the evidence base for it is one honestly-read qualitative paper that argues the other way, plus four statistics that are variously misattributed, mutually contradictory, unsourced, or drawn from clinician-prescribed devices.

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

CLAIM: The 'never opened until crisis' problem is close to fatal to the product as positioned, and muscle memory is not a myth — it is real, which is exactly why crisis-only positioning fails
THEIR DETAIL: Muscle memory works, but requires regular use, and an app used only in crisis by definition never gets regular use. This is a closed vicious circle. Direct evidence: 11/12 frustrated with communication slowness, 6/12 struggle locating symbols, one states plainly 'would need to use it regularly enough to memorize the symbol locations', and 3/12 struggle to remember where features are. Compounding it, shutdown involves executive-function collapse, and retrieval requires a chain of: remember the app exists → unlock phone → find icon → navigate → find phrase. Each link is a failure point at the moment capacity is lowest. The only escape is to stop positioning it as a break-glass tool and design for everyday low-demand use (tiredness, 'I don't want to talk right now', partial speech days) so the motor pattern is rehearsed — which also matches 'situational speech loss' being a spectrum rather than a binary. Assistive-tech abandonment data underlines the stakes: ~30% of AAC users abandon their systems, only ~39% still use AAC a year after introduction, and >35% of assistive devices go unused — most within the first three months.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v1, https://pubmed.ncbi.nlm.nih.gov/10171664/, https://www.theaacacademy.org/course/what-leads-to-aac-abandonment
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
