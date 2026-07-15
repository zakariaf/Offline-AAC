# aac-clinical--the-correct-design-rule-is-hide-don-t-move-e

> Phase: **verify** · Agent `a0c0597fd76e887f3` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** "Hide, don't move" is a genuine AAC principle and a sound engineering constraint for this app, but the researcher's specifics need three fixes:

1. DELETE THE "8 BUTTONS" QUOTE or re-source it. It is not in any cited URL. If the point is needed, cite AAC Voices instead: "you cause them to need to learn a new motor plan everytime you increase the grid size, limiting progress," or AssistiveWare: "Each time we change the grid size, we all need to re-learn where the words are."

2. DROP CITATIONS 1 AND 3 as support for the hide-don't-delete rule. Only openaac.org/considerations.html actually supports it. aaccommunity.net supports only "consistent placement"; achievehealthwellness.wordpress.com supports neither.

3. REPLACE "pick a grid density once, never resize" with the actual clinical rule: default to the largest grid the user can comfortably see and touch, and keep grid size CHANGEABLE — openAAC and AssistiveWare both treat multiple grid sizes as an accessibility requirement (visual acuity, motor skill), and AssistiveWare says "Feel confident to try a larger grid size any time." Locking density permanently would be an accessibility regression, not a clinical win.

KEEP AS-IS (well supported): deleting tile #4 leaves an empty slot rather than shifting 5-12 up; adds fill empty slots rather than re-sorting; reorder and grid-size change both exist but only as deliberate, explicit, warned user actions — never automatic.

CONFIDENCE: downgrade high -> medium. The rule is imported from research on emergent symbol-based communicators learning core vocabulary; this product serves literate adults using phrase tiles and typing, and no source found addresses motor planning for that population — AssistiveWare's part-time-AAC page, the closest match, never mentions it. Adopt the constraint because it is cheap and the downside of reflow is real, not because clinical consensus mandates it here.

**Evidence:** CORE PRINCIPLE — CONFIRMED. "Hide, don't move" is a real, well-documented AAC clinical technique, corroborated by multiple independent sources beyond the ones cited:
- aaccommunity.net/ccc/motor-planning: "Once the location of a word on a communication board or device, it needs to stay in the same place to be predictable" / "Use consistent icon placement."
- openaac.org/considerations.html: changing layouts "can disrupt a person's motor plan for saying something they've said before"; and explicitly on masking: "When a user is new to AAC, or focused on a specific context, they may want to hide buttons to improve focus or prevent being overwhelmed."
- AAC Voices ("How Many Buttons?"): "We might hide/mask words, use 'progressive language' features or similar during learning activities... so that we can have a smaller number of words during the activity, but then return the system to full access."
- Independent corroboration of the grid-size point: AAC Voices — "you cause them to need to learn a new motor plan everytime you increase the grid size, limiting progress"; AssistiveWare — "Each time we change the grid size, we all need to re-learn where the words are." LAMP Words for Life and TD Snap ship this as fixed-position architecture.

SO THE SUBSTANCE HOLDS. Four problems with the specifics:

1) THE "8 BUTTONS" QUOTE IS NOT IN ANY CITED SOURCE. "if you give them 8 buttons to start, you will need to keep expanding the page, which changes the motor plan around" appears verbatim in NONE of the three cited URLs, nor in AssistiveWare's grid-size page, nor in AAC Voices. It is presented in quotation marks as a citation. The underlying IDEA is independently corroborated (see AAC Voices/AssistiveWare above), but the quote itself is unsubstantiated — misattributed or reconstructed from memory.

2) CITATION 3 DOES NOT SUPPORT THE CLAIM. achievehealthwellness.wordpress.com says only "we need to provide a grid size and an organized language system that allow for vocabulary growth." It does not discuss hiding vs. deleting, masking, or reflow. Irrelevant citation.

3) CITATION 1 ONLY HALF-SUPPORTS IT. aaccommunity.net supports consistent placement but does NOT discuss hiding vs. deleting, reflow, or grid size. Only openAAC (1 of 3) actually supports the specific hide-don't-delete rule.

4) "PICK A GRID DENSITY ONCE" IS OVERSTATED AND CONTRADICTED. AssistiveWare explicitly says "Feel confident to try a larger grid size any time with a user" and ships one-tap grid resizing in Proloquo2Go. openAAC says supporting multiple grid sizes is valuable because "AAC users have different degrees of visual acuity and motor skills." The actual clinical rule is "start with the LARGEST grid the user can see and access" — a vision/motor fit decision — not "lock density forever." Hard-locking grid density would itself be an accessibility failure for low-vision or motor-impaired users.

5) POPULATION-FIT CAVEAT (the researcher's real overreach). The motor-planning literature is built almost entirely around symbol-based core vocabulary for EMERGENT communicators learning language (LAMP, Words for Life, TD Snap). Automaticity accrues over months/years of core-vocab practice. This product targets literate adults/teens with situational speech loss using phrase tiles + a type-to-speak box — a population with intact language. Tellingly, AssistiveWare's page on part-time AAC users (the single most on-point source for this exact population) does not mention motor planning at all. The ASHA study of speaking autistic AAC users found some prefer symbols during shutdown while others prefer typing. So "must be an engineering constraint, not a preference" is asserted, not evidenced, for THIS population.

NET: the engineering recommendation is still the right call — stable layout under distress is cheap to implement and the downside of reflow is real — but it rests on transferred reasoning plus one supporting citation, not on the three-source clinical consensus implied. "High" confidence is too high.

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

CLAIM: The correct design rule is 'hide, don't move' — editing must never reflow the grid
THEIR DETAIL: The established clinical technique for reducing visual load without destroying motor plans is masking/hiding buttons in place rather than deleting-and-reflowing. Implication for a user-editable phrase grid: deleting tile #4 must leave an empty slot, not shift tiles 5-12 up one position. Adding tiles appends to empty slots; it does not re-sort. Grid size changes are the most destructive operation of all ('if you give them 8 buttons to start, you will need to keep expanding the page, which changes the motor plan around') — so pick a grid density once and let users hide, not resize. Reorder must exist as a deliberate, explicit user action (they own their system), but must never be automatic, and is worth a one-time warning. This is directly at odds with 'customizable' as usually implemented and needs to be an engineering constraint, not a preference.
THEIR CLAIMED SOURCES: https://aaccommunity.net/ccc/motor-planning/, https://www.openaac.org/considerations.html, https://achievehealthwellness.wordpress.com/2022/09/07/aac-and-motor-planning/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
