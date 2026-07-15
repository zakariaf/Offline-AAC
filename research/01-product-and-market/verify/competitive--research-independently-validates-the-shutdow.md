# competitive--research-independently-validates-the-shutdow

> Phase: **verify** · Agent `a46be97a6374bba2a` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Research offers preliminary, single-study support — not independent convergence — for the shutdown/low-effort design requirement. The correct citation is Frisch, Peters & Vertanen (2025), "The Role of AAC in Social Communication and Community Engagement," arXiv:2507.00202 (v1 2025-06-30, v2 2025-09-17), an asynchronous text focus group with FIVE autistic adults, not peer-reviewed. It is the source of both the "preplan content on the days they have more energy" recommendation and the shutdown findings the researcher misattributed to the Aging Up study. Aging Up (Martin & Nagalakshmi, arXiv:2404.17730v3) never uses the word "shutdown"; it independently supports only the weaker adjacent point that 9/12 participants lose speech to stressors and 2 modulate AAC use by energy/effort. The menu-navigation quote comes solely from neurolaunch.com, an unbylined SEO content page, not research. "Rachel Walker (2025)" is fabricated — the name appears in no source; the resource-depletion framing comes from an anonymous neurodiversion.org article. No cited source supports the assertion that incumbents fail to design for this; Frisch presents preplanning as an open research direction. Note also that Frisch's recommendation is preplanned conversation scripts with anticipated replies, which is a distinct feature from a phrase-tile grid.

**Evidence:** The directional insight (low-effort, no-navigation, pre-planned content for shutdown states) has genuine support, but the claim's sourcing fails on nearly every specific, and one attribution is fabricated.

1) WRONG PAPER. The quote "AAC systems can be designed to allow users to preplan content on the days they have more energy to use during times of shutdown" is verbatim real — but in arXiv:2507.00202 (Frisch, Peters & Vertanen, 2025), which they did NOT cite. I extracted full text of their cited paper (arXiv:2404.17730v3 "Aging Up AAC", Martin & Nagalakshmi): "preplan" = 0 hits, "more energy" = 0 hits, "shutdown" = 0 hits, "menu" = 0 hits.

2) FALSE STATEMENT ABOUT AGING UP. They wrote "Participants in the Aging Up study described changed communication ability during shutdown and the effort required to communicate then." That sentence describes the Frisch paper (n=5), not Aging Up (n=12). "Shutdown" never appears in Aging Up. The actual Frisch text: "When participants shared their experiences with shutdown, participants described being able to feel themselves going into shutdown and how their communication abilities changed or even disappeared... They also wrote about the effort that is required to communicate."

3) FABRICATED SOURCE. "Rachel Walker (2025)" does not exist. Raw HTML of neurodiversion.org/going-nonverbal-when-overwhelmed: "Walker" = 0 hits, "Rachel" = 0 hits. The page is unsigned (site organized by Chris Guillebeau), last updated May 2026, explicitly non-medical-advice. It DOES contain the resource-depletion framing ("Speech draws from the same pool that sensory processing, social inference, and emotional regulation draw from"; "masking debt"), so the IDEA is on the page — but it is not attributable to any named researcher.

4) WEAK SOURCE FOR SECOND QUOTE. "A complex app that requires navigation through multiple menus may be too demanding to use during a high-anxiety mute episode. Simple, fast, low-effort options often work better under those conditions." — verbatim on neurolaunch.com/situational-mutism-autism (published 2024-08-11, edited 2026-04-27), authored by "NeuroLaunch editorial team," an SEO content page with no primary research behind that specific design assertion.

5) "CONVERGE" IS OVERSTATED. Each quote traces to exactly one source: one non-peer-reviewed preprint (n=5 asynchronous text focus group) and one content-farm page. That is not independent convergence.

6) UNSUPPORTED STRATEGIC LEAP. "It is the thing incumbents genuinely do not design for" has no evidence in any cited source. Frisch frames preplanning as a future RESEARCH DIRECTION and makes no claim about incumbent products.

WHAT HOLDS: Aging Up supports the adjacent point — 9/12 participants "mentioned losing the ability to use mouth-words because of various internal or external stressors," and "Some participants (2) use AAC depending on their energy and the effort required." Frisch states directly: "There is a need to design AAC options that support communication when autistic adults are in shutdown." Aging Up also notes typing is "more taxing," creating "more mental effort" or being "less calm."

PRODUCT CAVEAT: Frisch's actual recommendation is preplanned CONVERSATION SCRIPTS including "replies to anticipated questions" — a different feature from the MVP's phrase-tile grid. The requirement should be kept but treated as a single-study hypothesis (n=5, not peer-reviewed) requiring primary community validation, not as research-validated convergence.

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

CLAIM: Research independently validates the shutdown/distress design requirement — low-effort, no-navigation, pre-planned content
THEIR DETAIL: Findings converge on: 'A complex app requiring navigation through multiple menus may be too demanding during high-anxiety mute episodes; simple, fast, low-effort options work better'; and AAC should 'allow users to preplan content on days they have more energy.' Rachel Walker (2025) frames autistic adult speech loss as resource depletion/burnout rather than behavior. Participants in the Aging Up study described changed communication ability during shutdown and the effort required to communicate then. This validates the one-handed-in-distress design risk as a REAL and under-addressed requirement — and it is the thing incumbents (built around permanent loss, where the user is calm and configuring at leisure) genuinely do not design for.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v3, https://www.neurodiversion.org/going-nonverbal-when-overwhelmed, https://neurolaunch.com/situational-mutism-autism/
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
