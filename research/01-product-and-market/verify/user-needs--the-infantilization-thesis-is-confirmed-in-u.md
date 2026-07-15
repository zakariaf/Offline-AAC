# user-needs--the-infantilization-thesis-is-confirmed-in-u

> Phase: **verify** · Agent `a26f17d1bdfcfc559` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** The claim is factually sound and should be relied on — but tighten one word. Replace "the exact MVP" with "the core differentiator." The paper names symbols + typing + adult vocabulary in one app (and 7/12 wanted symbol/typing mixing, 12/12 wanted typing available — cite these stronger numbers instead of "a participant"). It does NOT name offline operation, zero-login, or mid-shutdown one-handed use; "offline" literally never appears. Those pillars need separate evidence and must not be attributed to this paper. Also scope the citation to autistic adults with part-time/unreliable speech (10/12 part-time, ages 18-44, n=12, all white, online-recruited) — it says nothing about aphasia or post-seizure users, and n=12 is a qualitative snapshot, not a market sizing.

**Evidence:** I bypassed the fetch-summarizer (which risked confirming quotes I had fed it) and regex-matched the raw HTML of arXiv:2404.17730v3 directly. All three quotes are VERBATIM EXACT — zero drift.

1) INFANTILIZATION — CONFIRMED verbatim. §5.3.1 "Aging up AAC" opens with the pull quote: "Many AAC apps feel like they're made for kids or students, and it feels infantilizing." Immediately followed by: "Participants (5) were of the opinion that AAC needs to be tailored for autistic adults, especially since they are often targeted toward children. Four participants (4) had suggestions for how AAC could be modified for adults: providing the user access to more adult vocabulary (2 ...); switching from symbol-based to text-based AAC as someone grows up, or combining the two modalities (1) ..." The "5 participants" figure is exact, not rounded or inferred.

2) FRAGMENTATION — CONFIRMED verbatim, §5.1.2 "Symbol- vs text-based AAC": "Having applications focus solely on symbol-based or text-based input creates unnecessary friction: '[I dislike] symbols and typing being so completely separate in different apps. Having multiple apps is good and choice is good but [...] I don't want to have to keep switching, and the typing in the symbol app just isn't sufficient for what I need.'"

3) THE PRODUCT SPEC — CONFIRMED verbatim, and the researcher UNDERSTATED it. Raw text: "Some participants (7) suggested supplementing or mixing symbol usage with typing ... or completely mixing the two types of AAC ('Future AAC that has both symbols and typing and a vocabulary designed for autistic adults would be very empowering.')." It is a genuine participant quote (in quotation marks, illustrating the theme), not author paraphrase. 7 of 12 wanted symbol+typing mixing — the claim only credited one participant.

BONUS SUPPORT the researcher missed: "all participants (12) wanted some type of typing input option to use at least occasionally." That is 12/12 for the type-to-speak box.

SAMPLE FIT IS EXCELLENT (checked adversarially, expecting a mismatch — found none). Participants are ages 18-44, US, native English. Only 2 of 12 use AAC full-time; the other 10 are PART-TIME users. Table 1 self-assigned labels include "Selectively mute/situationally mute," "Unreliable speech," "Semi-speaking," "Sometimes-user." This is precisely the situational-speech-loss population, not a full-time-AAC or child population. The screener explicitly asked "do you ... lose speech occasionally?"

THE ONE OVERREACH — "the exact MVP" does not survive scrutiny. The word "offline" appears ZERO times in the paper; "Wi-Fi"/"wifi" zero; "login"/"sign-up" zero; "shutdown"/"meltdown" zero. The paper supports symbols + typing + adult vocabulary in one app. It does NOT source the offline-first, no-account, or in-distress-usability pillars. Adjacent support exists but is weaker and must not be cited as the same finding: §5.8 documents real privacy concern over data logging and outsider access, and one participant wanted "no recording of word frequency usage, especially since this can be seen as another way of logging data"; §5.6.3 covers cost, with participants trying to "find free applications." The offline pillar remains the product team's own inference, currently unsourced.

LIMITATIONS the paper self-declares and the researcher should carry: n=12 only, all white, all recruited online (via Facebook "Ask Me, I'm an AAC user!" and X), skewing younger — authors note this "only provides a snapshot." No participant IDs are attached to quotes, so the fragmentation quote and the "empowering" quote cannot be proven to come from the same person. Also note the paper does not cover aphasia or post-seizure speech loss — it is autistic adults only, so two of the four target communities are not evidenced here.

Provenance: v1 26 Apr 2024, v2 27 Sep 2024, v3 4 Aug 2025 — recent and current. Authors Lara J. Martin & Malathy Nagalakshmi (UMBC). CC BY 4.0, so quoting is permitted with attribution.

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

CLAIM: The infantilization thesis is confirmed in users' own words, and the exact MVP (symbols + typing + adult vocabulary in ONE app) is named by a participant as the missing product.
THEIR DETAIL: From 'Aging Up AAC' (arXiv 2404.17730v3, n=12 autistic adult AAC users): 'Many AAC apps feel like they're made for kids or students, and it feels infantilizing' (5 participants reported child-oriented design failing adult needs). On the fragmentation that this product would fix: '[I dislike] symbols and typing being so completely separate in different apps,' and 'Future AAC that has both symbols and typing and a vocabulary designed for autistic adults would be very empowering.' This is close to a product spec written by a target user.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v3
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
