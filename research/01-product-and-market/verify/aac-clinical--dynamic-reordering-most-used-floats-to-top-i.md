# aac-clinical--dynamic-reordering-most-used-floats-to-top-i

> Phase: **verify** · Agent `ae0aed0bad33e5469` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Ship a static-by-default grid — that call is correct — but for the right reason and with the right architecture.

Corrected claim: "Automatic frequency-based reordering of the phrase grid should be rejected because it makes tile positions unpredictable and removes user control. Consistent button location is a well-established AAC design principle supported by motor-planning theory, though its direct evidence base comes from emergent symbol communicators (children with autism) rather than literate adults, and independent researchers note the motor-planning impact still needs study. Frequency/recency data is NOT off-limits for this population — Proloquo4Text, the leading clinical app for literate teens and adults, uses frequency-based sentence prediction. The rule is architectural: never mutate positions in the user-arranged grid; surface frequency/recency in a SEPARATE, fixed adjacent zone (e.g. a persistent 'Recents' strip in a constant screen location), and make any grid reordering explicitly user-triggered in an edit mode, never automatic."

Concretely: (1) grid tiles never move on their own — ever; (2) add a fixed-position recents/frequent strip if you want frequency benefits, so the strip's LOCATION is itself static even as contents change; (3) reordering is manual, in edit mode, by the user; (4) drop "actively harmful" and "clinical consensus is explicit" from any external-facing rationale — the sourcing (PRC-founded Center for AAC & Autism, Avaz) is vendor-side and won't survive scrutiny from an SLP reviewer.

**Evidence:** VERBATIM QUOTES: ALL CHECK OUT. I confirmed every quoted string against the primary source.
- lampwflapp.com/about: confirmed "the motor plan to say a word on an AAC device is consistent across time and unique from other words" — quoted correctly.
- openaac.org/considerations.html: confirmed verbatim "if the layout for a vocabulary changes regularly (i.e. buttons move to different spaces) then it can disrupt a person's motor plan for saying something they've said before," plus "always hit the same sequence to say the same thing can improve speed and require less cognitive load."
- aaccommunity.net/ccc/motor-planning: confirmed "Once the location of a word is learned, it needs to stay in the same place. It needs to remain predictable."
- avazapp.com/blog/aac-symbol-consistency: page exists (pub. 2026-05-22), confirms "stable layouts support faster communication and lower cognitive load."
No fabrication. The researcher quoted accurately. But three load-bearing specifics fail.

FAILURE 1 — "Clinical consensus is explicit" is NOT consensus; it is vendor sourcing. The Center for AAC & Autism (aacandautism.com, source of the Research-Supporting-LAMP PDF) was FOUNDED BY the Prentke Romich Company — the company that sells LAMP Words for Life. PRC merged with Saltillo in 2019. Avaz is likewise a vendor blog. So two of the five cited "consensus" sources are marketing from firms selling static-grid products. Independent literature is markedly weaker: the AAC display-design research states motor-planning support is an area where "future research is needed to examine the impact." LAMP's own evidence base is thin (a key peer-reviewed study used n=8 children; EBSCO notes the protocol "has not been universally accepted" and that both advocates and critics cite limited long-term data). This is a vendor-promoted design principle with suggestive support — not explicit clinical consensus.

FAILURE 2 — Wrong population. The motor-planning evidence base is for EMERGENT SYMBOL COMMUNICATORS: children with autism acquiring language via symbol grids. The display-design paper is titled "...for Young Children." This product serves LITERATE adults/teens using phrase tiles + type-to-speak. Sources explicitly split these populations: emergent communicators get motor-planning consistency with symbols; "for literate or growing writers, keyboard access, word prediction, phrase storage" are the relevant considerations. Applying LAMP to literate adults is an extrapolation, not established clinical evidence.

FAILURE 3 — "Frequency-based reordering is anti-clinical here" is refuted by the flagship clinical app for this exact population. Proloquo4Text (AssistiveWare) targets literate teens/adults who "can't (always) speak" — precisely this product's users — and ships sentence prediction that explicitly "keeps use and frequency information to help make predictions," plus a History Quick Block. Frequency adaptation is not anti-clinical for literate adults; the leading clinical vendor ships it to them. What P4T does NOT do is mutate the stored Phrases grid — frequency lives in a separate adjacent zone. The clinical resolution is ARCHITECTURAL, not prohibitionist.

FAILURE 4 — The compounding "mid-shutdown" argument is unsourced inference and partly self-defeating. No source establishes that motor automaticity survives shutdown/sensory-overload better than visual search does. Worse, it cuts against itself: LAMP automaticity is built through massive daily repetition. A situational-speech-loss user who opens the app episodically during occasional shutdowns may never accumulate the repetitions needed to build a motor plan at all — so there is often no automaticity for reordering to destroy. The argument assumes the very asset that episodic use fails to create.

WHAT SURVIVES: static-grid-by-default is still the right build. But the defensible reason is predictability and user control, not "actively harmful per clinical consensus." Do not stake the decision on a claim an SLP could dismantle by noting the sources sell static grids.

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

CLAIM: Dynamic reordering ('most used floats to top') is actively harmful and would fail users at exactly the moment of greatest need
THEIR DETAIL: LAMP's premise: the motor plan to say a word is consistent across time and unique from other words; automaticity with static button locations lets users communicate 'as fast as they think' via muscle memory, because users remember the physical LOCATION rather than visually scanning the screen. Clinical consensus is explicit that changing layouts 'can disrupt a person's motor plan for saying something they've said before,' and that once a word is programmed to a location it must stay there. The compounding argument for THIS product: a user mid-shutdown/sensory-overload has the least available capacity for visual search — that is the definition of the state the app is for. An adaptive grid converts a 1-tap automatic retrieval into a visual search task precisely when visual search has failed. Frequency-based reordering is a conventional-UX instinct that is anti-clinical here.
THEIR CLAIMED SOURCES: https://lampwflapp.com/about, https://aacandautism.com/assets/uploads/Research-Supporting-LAMP4.pdf, https://aaccommunity.net/ccc/motor-planning/, https://www.openaac.org/considerations.html, https://www.avazapp.com/blog/aac-symbol-consistency/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
