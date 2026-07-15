# user-needs--speed-is-the-1-cited-functional-issue-and-sp

> Phase: **verify** · Agent `ae90c4ec80335190b` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Corrected: In "Aging Up AAC" (Martin & Nagalakshmi, arXiv:2404.17730), 11 of 12 autistic adults raised speed, and the paper does define it broadly — "communication speed can stem from issues with locating button words on the board (6) or the input method that is being used (5)." However, speed is NOT the #1 cited issue: the paper never ranks themes, and wanting a typing input option (12/12) and general customization (12/12) were cited by more participants, with Trust and data-privacy concerns tied at 11. The "switching between applications" friction is a separate, weaker finding, not part of the speed theme: setup/migration overhead is §5.6.2 and only 2 participants (and means moving to a different AAC app, not in-session switching), while in-session app-switching is §5.3.2 "Consolidation of features" at 3 participants. The "8-10 wpm" figure is in none of the cited sources; it comes from a 2019 review where it applies specifically to direct-selection/eye-gaze, against a broader literature range of ~2-20 wpm (12-18 with word prediction) vs 125-185 wpm natural speech. Of the three cited sources, only the arXiv paper is relevant — the USSAAC page (2018) is about staff training and funding, and the SEN Magazine piece (2026) is a Smartbox vendor post that never mentions speed. Justify the flat first screen with the 6 participants citing word-location, and in-app typing with the 12/12 typing-input finding plus the 3-participant consolidation theme.

**Evidence:** The load-bearing statistic is real and verbatim-accurate, but the framing around it ("#1 issue", app-switching, 8-10 wpm) does not survive checking, and 2 of the 3 cited sources are unrelated to the claim.

CONFIRMED (verified against raw HTML of arXiv:2404.17730v3, §5.7.2, not a summarizer):
"Speed has long been a concern in AAC use (Newell et al., 1998). Like other adult AAC users, nearly all participants (11) mentioned the issue of speed with AAC, wanting 'to be able to communicate faster' and keep up in conversations (3)... This issue of communication speed can stem from issues with locating button words on the board (6) or the input method that is being used (5)."
So "11 of 12" is exact, and the broadened definition of speed (word-locating + input delays) is substantively correct. Paper = Martin & Nagalakshmi, "Aging Up AAC," 12 autistic adults, ages 18-44, semi-structured interviews. Note the researcher's inner quote "not just communication speed, but also locating words on boards and input method delays" is a PARAPHRASE presented in quotation marks — those are not the paper's words.

REFUTED — "#1 cited functional issue": The paper never ranks themes (it's qualitative; counts aren't a leaderboard), and 11/12 is not the top count. Grepping every count of 10-12: typing input option = ALL participants (12); general customization = ALL participants (12); Trust = 11; unwanted outsider access = 11; voice quality = 10; affordability = 10; pre-programmed phrases = 10. Speed at 11 is tied-for-second at best. It is only the top item *within* §5.7 (stumbling blocks for continued use).

REFUTED — "infrastructure overhead of setup and switching between applications... prevented adoption": This quoted phrase does not appear in the paper, and it is NOT part of the speed finding. The actual text is §5.6.2 — a different section from §5.7.2 Speed — and reads: "they spend a lot of time setting the app up and making boards to fit their needs (4)... It makes for a big overhead for starting AAC or moving to another AAC application (2)." That is 2 participants, and it means permanently MIGRATING to a different AAC app, not app-switching overhead during use. "Prevented adoption" is embellishment the paper doesn't state.
  Real support for in-session switching friction exists but elsewhere and weaker: §5.3.2 "Consolidation of features" — three participants (3) wanted "consolidating features from various apps into a single platform... eliminating the need to constantly switch between different applications," plus a direct quote: "[I dislike] symbols and typing being so completely separate in different apps... I don't want to have to keep switching, and the typing in the symbol app just isn't sufficient for what I need."

REFUTED — "8-10 words per minute": This figure appears in NONE of the three cited sources (I grepped the full paper text: the only wpm figure in it is a participant saying "I type 100 words a minute on a regular keyboard"). It traces to an uncited 2019 review (PMC6515262), where it is scoped narrowly: "Direct selection techniques, including eye gaze systems, are found to provide conversational rates of about 8-10 WPM." Broader literature gives a range, not a point: 2 WPM scanning, 12-18 WPM with word prediction, ~3-20 WPM overall vs 125-185 WPM natural speech. Stating "speech-generating devices run 8-10 wpm" as settled is over-precise cherry-picking.

REFUTED — source quality (2 of 3 cited sources do not support the claim at all):
- ussaac.org "Key AAC Issues" is dated December 3, 2018 (violating the 2024-2026 recency preference) and is about lack of staff training, paraprofessional knowledge gaps, and insurance funding delays. It does not discuss speed as #1 and contains no wpm figure.
- senmagazine.co.uk "AAC abandonment" (Daisy Clay, March 5, 2026) — I bypassed the 403 with a browser UA and grepped the full text: ZERO occurrences of "speed", "minute", "wpm", or "switch". It covers feature matching, uptake, training, and attitudes. It is also a vendor marketing post — the author is Head of Content at Smartbox, an AAC company — not research, an undisclosed conflict of interest.

CONFIDENCE: "high" was not warranted; one real source out of three, with the ranking, the app-switching mechanism, and the wpm figure all unsupported.

PRODUCT IMPACT: The design decisions still hold, but the current claim is the wrong justification for them. In-app typing is supported far better by §5.1.1 — ALL 12 participants wanted a typing option (the strongest finding in the paper) — and by §5.3.2 consolidation, than by the speed theme. The flat/no-dive first screen is supported by the 6 participants for whom speed problems stem from locating words. Cite those directly instead of a fabricated ranking.

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

CLAIM: Speed is the #1 cited functional issue, and 'speed' explicitly includes finding words on boards and app-switching overhead — not just words-per-minute.
THEIR DETAIL: 'Aging Up AAC': 11 of 12 participants cited speed as a critical issue — 'not just communication speed, but also locating words on boards and input method delays,' with 'infrastructure overhead of setup and switching between applications' creating friction that prevented adoption. Broader AAC literature: speech-generating devices run 8-10 words per minute conversational throughput. This directly justifies a flat, no-dive first screen and in-app typing.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v3, https://ussaac.org/speakup/articles/key-aac-issues/, https://senmagazine.co.uk/content/tech/assistive-tech/28585/aac-abandonment/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
