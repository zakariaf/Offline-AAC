# user-needs--the-bystander-problem-is-real-but-is-primari

> Phase: **verify** · Agent `a5da7170e5422dd8b` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Corrected claim: The bystander problem is BOTH a safety problem AND an awkwardness/fear problem — the two are entangled in the sources, not rivals. Safety is strongly evidenced: 11 of 12 participants in "Aging Up AAC" (arXiv 2404.17730v3) said AAC use depended on whether the environment is safe, and using AAC can "out them" as autistic; using AAC around people with power ("dramatic power over me who can drastically control my life") is experienced as actively unsafe. But fear, masking, social anxiety, and infantilization operate alongside safety — 2507.00202's own stated design implication is "addressing the fear of using AAC," and its P2 explicitly reports feeling "awkward."

Three specific corrections: (a) the "communication book... not brave enough" (P5) quote is from 2507.00202 (Frisch et al., N=5), not from "Aging Up AAC"; (b) the strangers-are-easier point is 2 of 5 individual participant remarks, not a paper-level finding; (c) the bystander-card implication is NOT supported and is arguably counter-indicated — a static, authoritative-looking card handed to an authority figure performs exactly the disability disclosure P1 fears, in a more permanent and legible form. The evidence supports concealability/deniability (the ability to communicate WITHOUT visibly disclosing, e.g. looking like you're just texting) and an OPT-IN ambient status signal for trusted settings (participants asked for a color-coded mental-state indicator for housemates, "something that would be seen that would say hey you need some extra support") — not an authoritative bystander card aimed at authority figures. Both sources are unrefereed arXiv preprints, combined N=17, self-selected.

**Evidence:** VERIFIED AGAINST PRIMARY SOURCES.

WHAT HOLDS (strong):
1. P1 quote in arXiv 2507.00202 is VERBATIM and correctly attributed: "It is not safe for me to communicate in a 'more disabled' looking manner to people who have the power to do things that could cost me too dramatically much."
2. The "power" quote is VERBATIM in Aging Up AAC (2404.17730v3, sec 5.4.1 "Trust"). Full text: "I don't use AAC [...] when there are people who have dramatic power over me who can drastically control my life, because my trauma tells me it is actively not safe to in those situations." The researcher's ellipsis is fair.
3. This is NOT anecdotal: 2404.17730 states "nearly all of our participants (11) spoke about how using AAC depended on whether the environment is safe" (11 of 12), and that using AAC can "out them" as autistic. The safety/power/authority core of the claim is genuinely well-evidenced.

WHAT BREAKS (four defects):
1. ATTRIBUTION SLIP: The "I have a communication book that I carry with me, but I've not been brave enough to use it" (P5) quote is NOT in Aging Up AAC, where the sentence structure places it. It is in 2507.00202 (Frisch et al., N=5, participants P1-P5). Aging Up AAC has 12 participants. Real quote, wrong paper. Related P5 quote in same paper: "Not just carry a little book in my pocket that I'm terrified to use because I don't think anyone will understand."

2. THE DICHOTOMY IS FALSE ("primarily SAFETY, not awkwardness"): Both papers treat these as entangled, not rival. 2507.00202's own abstract lists its design implication as "addressing the fear of using AAC" — fear, not safety-from-authority. Its participants: "I still struggle with a lot of compulsive masking and social anxiety that hinder me"; "fear of being misunderstood and of identifying as disabled"; "usually in social settings my masking will override my needs". P2 uses the exact word: "after that is when I start to feel awkward and hyper-analyze my conversations." Aging Up AAC adds infantilization ("made for kids", "infantilizing") and a participant who stopped using AAC after a friend said "it felt a little incongruous to hear a child's voice." Safety does not displace awkwardness.

3. STRANGERS CLAIM OVERSTATED AS A FINDING: "2507.00202 found participants were MORE comfortable disclosing to strangers" is 2 of 5 individual remarks in an asynchronous text focus group; the paper makes no group-level claim. P1: "the 'I'll never see this person again' is itself very freeing." P2: "I'm less masked and more comfortable talking to them for the first time." P2's remark is also about general conversation/masking, not specifically disability disclosure.

4. THE DESIGN IMPLICATION INVERTS ITS OWN EVIDENCE (most serious, since the product decision rests here): The claim concludes a bystander card should "do the explaining on the user's behalf (a static, authoritative-looking statement) rather than requiring the user to perform disability live." But P1's stated fear is being seen "in a 'more disabled' looking manner" BY PEOPLE WITH POWER. A static authoritative card handed to an authority figure IS that disclosure — more permanent, more legible, harder to retract than a tap. 2404.17730's "outs them as autistic" applies to the card too. The safety evidence argues for CONCEALABILITY and DENIABILITY (the option not to disclose), not a better disclosure artifact. What participants actually requested points the other way: an ambient status signal for KNOWN/SAFE people — a color-coded system "to communicate my mental state" to housemates; "something that would be seen that would say hey you need some extra support"; "a way to indicate their communication ability to communication partners."

SOURCE QUALITY CAVEATS: Both are arXiv preprints with no acceptance/venue noted (2404.17730 v1 Apr 2024, v2 Sep 2024, v3 Aug 2025; 2507.00202 v1 Jun 2025, v2 Sep 2025, retitled between versions from "Examining the Social Communication and Community Engagement of Autistic Adults through an Asynchronous Focus Group" to "The Role of AAC in Social Communication and Community Engagement"). Combined N=17, self-selected.

CONFIDENCE ADJUSTMENT: researcher stated "high" — justified for the safety/power core, NOT for the dichotomy, the strangers "finding", or the bystander-card implication.

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

CLAIM: The bystander problem is real but is primarily a SAFETY problem, not an awkwardness problem — and using AAC around authority figures can feel dangerous rather than helpful.
THEIR DETAIL: This complicates the brief's assumption. From arXiv 2507.00202: 'It is not safe for me to communicate in a "more disabled" looking manner to people who have the power to do things that could cost me too dramatically much' (P1). From 'Aging Up AAC': 'I don't use AAC [...] when there are people who have dramatic power over me who can drastically control my life.' Fear also blocks use even when the tool is present: 'I have a communication book that I carry with me, but I've not been brave enough to use it' (P5). Counterintuitively, 2507.00202 found participants were MORE comfortable disclosing to strangers they'd never see again. Implication: a bystander card must do the explaining *on the user's behalf* (a static, authoritative-looking statement) rather than requiring the user to perform disability live.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2507.00202v1, https://arxiv.org/html/2404.17730v3
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
