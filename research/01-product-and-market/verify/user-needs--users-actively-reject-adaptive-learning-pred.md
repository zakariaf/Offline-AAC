# user-needs--users-actively-reject-adaptive-learning-pred

> Phase: **verify** · Agent `ac80b42aaf76d6d9a` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** The Martin & Nagalakshmi (2025) statistics are accurate — 11/12 concerned about unauthorized data collection, 6/12 said automatic personalization should never activate, and all quotes are verbatim. But three things are wrong. (1) The motor-plan evidence is a misread: the "swap motor plans back and forth" quote is one participant explaining why they prefer a keyboard embedded in the AAC app over the OS-native on-screen keyboard — it is not about tiles reordering by frequency/recency, which the paper never discusses. (2) "Users actively reject prediction" is overstated: 4 of 12 participants wanted auto-complete/word suggestion, and the paper's actual recommendation is opt-in-by-default control (§6.3), not prohibition. (3) This paper does not validate offline; it is about privacy/data collection, not connectivity. Corrected claim: autistic adult AAC users demand CONTROL over adaptation, not its absence — personalization and prediction must ship disabled, be explicitly opt-in, never self-activate, and never transmit data off-device; a subset actively want word prediction available under their control. Stable tile layouts remain a sound design choice on general motor-planning grounds, but this paper is not the citation for it; what this paper does support is implementing an in-app keyboard rather than invoking the OS keyboard.

**Evidence:** SOURCE IS REAL AND THE NUMBERS CHECK OUT. Paper: "Aging Up AAC: An Introspection on Augmentative and Alternative Communication Applications for Autistic Adults," Lara J. Martin & Malathy Nagalakshmi (UMBC), arXiv:2404.17730v3, updated 16 Apr 2025. 12 autistic adults, semi-structured interviews. Verified against the primary source:

CONFIRMED:
- 11 of 12 participants expressed concerns about unwanted outsider data collection without consent. Sub-breakdown: conversation logs reaching people with control over the user (3), unnecessary tracking such as location (2), unauthorized phone access by conversation partners (2).
- 6 participants stated automatic personalization should never activate.
- All three "smart features" quotes appear verbatim, though the first is truncated in the claim. Actual text: "I don't like it when the way I use something automatically changes the way an app or website, or whatever, functions." The ClaroCom quote is a single continuous passage: "I turned off every single prediction that ClaroCom [has], including its built-in support for learning automatically. I don't even like that it has those knobs. I'd rather it just plain didn't do any of that."

REFUTED — MISREAD #1 (the motor-plan claim, which is the most decision-relevant error). The claim says a participant cited "needing to swap motor plans back and forth a lot" as evidence that "tiles that reorder by frequency/recency actively break the muscle memory this population relies on." The quote has nothing to do with tile reordering. Verbatim context: "Within those who prefer on-screen keyboards there was some variation in preferences of how that keyboard is implemented. Some (3) prefer a keyboard embedded within the application itself. One participant (1) said this is preferred because an OS-native on-screen keyboard would mean 'needing to swap motor plans back and forth a lot' (1)." This is ONE participant, in the typing-input section, saying they prefer a keyboard embedded in the AAC app over the OS-native keyboard — because switching between two different keyboard layouts costs motor planning. Reordering tiles is never mentioned. The researcher extrapolated a finding about keyboard implementation into a finding about adaptive tile layouts. The design implication is real but different: build the keyboard INTO the app rather than invoking the OS keyboard.

REFUTED — OVERSTATEMENT #2. "Users actively reject adaptive/learning/prediction features" and "a prohibition on 'smart' personalization" misrepresent the paper. The picture is mixed: 4 of 12 participants explicitly WANTED auto-complete/word suggestion, and 2 wanted search to help find buttons. All 12 wanted some typing input option. The paper's own design recommendation (§6.3) is opt-in rather than opt-out for non-core features — user-controlled prediction, not absent prediction. A blanket prohibition would contradict the source and strand the ~third of participants who want suggestion features.

UNSUPPORTED — "offline is validated" by this source. The paper is about privacy and data collection, not connectivity. Offline is not a finding of this study; the only adjacent datapoint is one participant preferring a UbiDuo (a non-internet-connected device). Offline may well be validated elsewhere, but citing this paper for it is unsupported.

CORRECT PRODUCT DECISION: ship prediction/personalization OFF by default, fully user-toggleable, never self-activating, with nothing leaving the device — not "don't build it." And keep tile positions stable (defensible on general AAC motor-planning grounds), but do not cite this quote as the evidence, and do build an in-app keyboard rather than calling the OS keyboard.

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

CLAIM: Users actively reject adaptive/learning/prediction features — offline is validated, but so is a prohibition on 'smart' personalization.
THEIR DETAIL: From 'Aging Up AAC': 11 of 12 participants expressed concerns about unauthorized data collection; 6 stated automatic personalization should NEVER activate. Verbatim: 'I don't like it when the way I use something automatically changes the way an app or website functions'; 'I turned off every single prediction that ClaroCom [has], including its built-in support for learning automatically'; 'I don't even like that it has those knobs. I'd rather it just plain didn't do any of that.' Separately, a participant cited 'needing to swap motor plans back and forth a lot' as a burden — meaning tiles that reorder by frequency/recency actively break the muscle memory this population relies on.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v3
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
