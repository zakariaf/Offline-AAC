# user-needs--autistic-shutdown-is-a-spectrum-and-in-its-d

> Phase: **verify** · Agent `a0e69f5e4bb6f264a` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Autistic shutdown impairs more than speech production: movement/motor control and decision-making are both well documented as affected (Paris et al. 2025, Autism in Adulthood, DOI 10.1089/aut.2024.0193 — "physical and/or vocal immobilization", "being frozen" metaphor; Reframing Autism — shutdowns "impede communication capabilities, be it verbal expression, decision-making, or even sending a simple text"). Receptive AUDITORY language can also fail ("other people's speech around you can stop making sense" — autismunderstood.co.uk). However: (a) no source supports degraded READING comprehension during shutdown — that element appears to be an unsupported extrapolation from receptive-speech failure, and should be dropped or flagged as an untested hypothesis; (b) no source frames shutdown as a depth spectrum — the paper reports six qualitatively distinct metaphors, not a severity gradient, and "both are true at different depths" is the researcher's own reconciliation, not a finding; (c) the claimed contradiction between sources does not exist — "All your words are still there in your head" and "other people's speech can stop making sense" are both from autismunderstood.co.uk, which presents them as compatible; (d) the five verbatim participant quotes could not be verified as the full text is paywalled, so confidence should be moderate, not high.

**Evidence:** SOURCE IS REAL AND CORRECTLY CITED. Paris K, Lodestone A "Zeph", Houser M, Lewis LF. "Shutdowns Are Like You're Stuck on the Blue Screen of Death": A Metaphor Analysis of Autistic Shutdowns. Autism in Adulthood, DOI 10.1089/aut.2024.0193, published online 12 Feb 2025 (Vol 8 Issue 4, Aug 2026). Secondary qualitative analysis, n=86 autistic adults. Six metaphors confirmed verbatim: being frozen, a computer crash, going inside myself, when I can't keep up, survival mode, playing a role. Abstract confirms "physical and/or vocal immobilization" and framing as threat response.

CONFIRMED ELEMENTS:
(1) MOVEMENT — well supported. Paper abstract: "physical and/or vocal immobilization"; "being frozen" is a named metaphor category. autismunderstood.co.uk: "find it difficult to move". sensoryoverload.info: "feeling frozen, heavy, or unable to move", "reduced movement or physical stillness". Reframing Autism: "reduced motor coordination, or a deceleration in movements".
(2) DECISION-MAKING — supported. Reframing Autism (autistic-led) is explicit: "Shutdowns can greatly impede communication capabilities, be it verbal expression, decision-making, or even sending a simple text" and "the ability to think coherently and logically can be severely compromised". sensoryoverload.info lists "difficulty deciding" (though only under early warning signs, not shutdown proper — a weaker placement than the claim implies).
(3) "Not just speech production" — directionally correct; impairment demonstrably extends beyond expressive speech to motor and cognitive domains.

REFUTED / UNSUPPORTED ELEMENTS:
(1) READING COMPREHENSION — no support in any cited source or in additional sources checked. All four of the researcher's URLs, plus Reframing Autism, were fetched. None mentions reading or reading comprehension degrading during shutdown. What the sources actually describe is AUDITORY receptive failure: "other people's speech around you can stop making sense" (autismunderstood.co.uk) and "difficulty processing what others are saying" / "difficulty thinking clearly or processing language" (sensoryoverload.info). The researcher substituted reading comprehension for receptive speech — a different sensory channel. Independent search for autistic-shutdown-plus-reading-failure returned only the separate, unrelated literature on reading comprehension as a BASELINE trait in autistic children (the ~65% figure), which concerns stable trait-level decoding-vs-comprehension dissociation, not transient shutdown states. Conflating the two would be a category error. The WebFetch of the paper page explicitly noted it addresses "language/figurative expression — not reading comprehension specifically".
(2) "SHUTDOWN IS A SPECTRUM" / "both are true at different depths" — this is the researcher's own interpretive reconciliation presented as a sourced finding. No source frames shutdown as a mild-to-deep severity gradient. Reframing Autism explicitly does NOT: it frames variability BETWEEN individuals ("each Autistic individual is distinct"), not depths WITHIN an episode. The paper's six metaphors are qualitatively distinct descriptive categories, not rungs on a severity ladder. Targeted search for "partial shutdown" / "degrees of shutdown" / "spectrum of shutdown" surfaced no shutdown-specific severity-gradient research.
(3) THE CLAIMED SOURCE CONTRADICTION IS MANUFACTURED. The researcher presents "All your words are still there in your head, you know what you want to say – you just can't get your mouth to do it" as the milder CONTRADICTING framing, while attributing "other people's speech around you can stop making sense" to separate unnamed "community sources". Both sentences appear on the SAME page — autismunderstood.co.uk — which states both without treating them as opposed. There is no source-vs-source disagreement requiring a depth-based reconciliation. (The weirdlysuccessful.org "traffic jam" quote IS accurately characterized: that page does state comprehension remains intact — "they can think clearly, understand what's being said to them".)
(4) VERBATIM QUOTES UNVERIFIABLE. The five participant quotes ("Impossible to move"; "I freeze like a statue and can't move by myself"; "I can't decide which thoughts to prioritize..."; "The ability to notice I'm shutting down, shuts down too"; "if I'm not mute, I'm a yes man") could not be independently matched. Full text is paywalled on SAGE (liebertpub redirects to journals.sagepub.com; PDF and /full both gated). Targeted exact-phrase searches returned zero matches. Cannot confirm or refute — but the researcher's stated "high" confidence is unwarranted given they most likely could not access the full text either. Quotes are plausible and consistent with the confirmed abstract, so fabrication is not alleged, only unverified.

DESIGN IMPACT: The practical design conclusion partly survives on other grounds — well-sourced motor impairment and decision paralysis independently justify large tiles, minimal choice depth, and one-handed operation. But the specific inference the claim was constructed to support — "text is unprocessable, do not rely on reading" — rests entirely on the one element with zero evidentiary support. If a design decision (e.g. dropping text labels in favor of symbols) is being justified by shutdown-induced reading failure, that justification is not currently substantiated and should be re-grounded or tested with users.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "user-needs". A product decision depends on it, so it must be right.

CLAIM: Autistic shutdown is a spectrum, and in its deeper form it degrades reading comprehension, decision-making, and voluntary movement — not just speech production.
THEIR DETAIL: The 2025 metaphor analysis of autistic shutdowns (Autism in Adulthood, 'Shutdowns Are Like You're Stuck on the Blue Screen of Death') collects verbatim participant reports: 'Impossible to move'; 'I freeze like a statue and can't move by myself'; 'I can't decide which thoughts to prioritize, and I freeze while my brain is trying to sort it out'; 'The ability to notice I'm shutting down, shuts down too'; 'if I'm not mute, I'm a yes man'. Community sources add that receptive language can fail too: 'other people's speech around you can stop making sense.' This CONTRADICTS the milder framing in other sources, which hold comprehension intact — 'a traffic jam between thoughts and verbal expression' and 'All your words are still there in your head, you know what you want to say – you just can't get your mouth to do it.' Both are true at different depths. Design must serve the deep case, where text is unprocessable and choosing is itself impossible.
THEIR CLAIMED SOURCES: https://journals.sagepub.com/doi/10.1089/aut.2024.0193, https://weirdlysuccessful.org/verbal-shutdown/, https://autismunderstood.co.uk/struggling-as-an-autistic-person/shutdowns/, https://sensoryoverload.info/autism/autistic-shutdowns/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
