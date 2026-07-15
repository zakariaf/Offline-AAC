# flutter-vs-rn--flutter-has-a-documented-unfixed-bug-where-e

> Phase: **verify** · Agent `a63ae68aecf47b664` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**REFUTED**  (refuted)

**Correction:** Flutter shipped basic iOS Full Keyboard Access support (engine PR #56842 + related framework work), and the main tracking issue flutter/flutter#76497 was closed as COMPLETED with an "r: fixed" label on 2025-03-31, reaching beta in January 2025. Of the four cited issues, three are closed (#76497 completed/fixed; #165303 closed as solved one day after filing; #148409 closed as a duplicate nine minutes after filing) and only #166683 remains open — labeled P2 and "e: device-specific". A Google engineer on that thread confirmed in Sept 2025 that the keyboard-breaking behavior "doesn't happen on iOS >= 18" and is only easily reproducible on iOS 17, noting 90%+ of iOS devices are on 18+; a Nov 2025 tester validated Apple's full external-keyboard control set on iOS 26 hardware with no problems. The "FKA on Flutter does not exist / WCAG conformance unachievable" line is not from the dev.to article but from a single reader comment on it, posted Oct 2024 — before the fix landed. Accurate statement: as of mid-2026, Flutter iOS supports Full Keyboard Access but that support is incomplete, with open bugs around scrolling to offscreen semantics nodes (#187055), scrolling with bottom navigation bars (#181007), non-focusable Sliders, inability to query iOS accessibility focus, and Cupertino widgets not being keyboard-operable. It is a "partial support with real gaps" risk, not an "unfixed bug that breaks external keyboards entirely" blocker, and it is largely orthogonal to a touch-first AAC app.

**Evidence:** The claim's three load-bearing specifics — "unfixed", "breaks entirely", "multiple open issues" — each fail against primary sources.

1) "UNFIXED" IS FALSE. flutter/flutter#76497, the main tracking issue the claim leans on, is CLOSED as state_reason=completed (closed 2025-03-31) and carries the label "r: fixed". Maintainer LongCatIsLooong, 2024-12-16: "With flutter/engine#56842 and flutter/flutter#159811 merged I think the basic FKA support should be there... Please file issues for FKA-related bugs and feature requests." jmagman confirmed 2025-01-24 the work was available in the beta channel. FKA support was implemented and shipped ~18 months before today's date.

2) "MULTIPLE OPEN ISSUES" IS FALSE — 3 of the 4 cited issues are closed:
- #76497: CLOSED, completed, r: fixed (2025-03-31). Thread auto-locked 2025-04-15.
- #165303: CLOSED as "r: solved" ONE DAY after filing (2025-03-18). Triager darshankawar closed it as a pointer to #76497, then immediately self-corrected: "it seems the feature is available in beta." It is not an independent standing 2025 report.
- #148409: CLOSED as "r: duplicate" NINE MINUTES after filing (2024-05-15). Zero evidentiary weight.
- #166683: the ONLY genuinely open one. It is P2 (not P1/critical) and explicitly labeled "e: device-specific".

3) "BREAKS ENTIRELY" IS DEVICE-SPECIFIC AND LARGELY OBSOLETE. On the sole open issue #166683, Flutter team member maheshj01 could NOT reproduce on iPhone 16 Plus / iOS 18 and labeled it device-specific. Reporter SaadSafan confirmed it worked fine on iOS 18.2 sim but reproduced on iOS 17.5. Decisively, tdevaux (Google, "customer: chalk") on 2025-09-18: "we also internally reproduced this (Chalk) but can confirm from my experiment that this doesn't happen on iOS >= 18. I can repro on iOS 17 easily. Given that 90%+ of iOS devices are on >= 18 (public data) and increasing, it's less and less critical for us." Further, okorohelijah on 2025-11-13 validated Apple's full external-keyboard control list with a Magic Keyboard on physical iPhone and iPad running iOS 26: "everything seems to work well!" As of 2026-07, iOS 17 is a residual population.

4) THE "PRACTITIONERS" QUOTE IS FABRICATED/INFLATED. The dev.to article (dated 2024-10-19) does NOT say "FKA on Flutter does not exist" nor anything about WCAG non-conformance. That assertion exists only as a single reader COMMENT by one Stefan Neidig ("it is currently not possible to make an app fully accessible in terms of WCAG guidelines using flutter. Reason for this is the full keyboard issue on iOS"). One anonymous blog commenter is not "accessibility practitioners state flatly," and the comment predates the FKA fix landing in beta (Jan 2025) by three months.

5) THE REACT NATIVE COMPARISON IS UNSOURCED. The researcher supplied zero sources for "React Native... gets FKA behavior largely for free." Directionally plausible since RN renders real UIKit views, but it is asserted, not evidenced.

WHAT IS ACTUALLY TRUE (the residue): Flutter's FKA support is INCOMPLETE, not absent or broken. Real open gaps: #187055 (2026-05-25, FKA does not scroll to offscreen Semantics nodes in SingleChildScrollView, no focus callbacks), #181007 (2026-01-14, FKA scrolling finicky with bottom nav bar), plus in-thread reports that Sliders aren't focusable/adjustable via FKA (ABausG, 2025-06-18), that there's no way to query which widget iOS has focused (cirogr, 2025-06-17), and closed dupes #175244/#175257 (Cupertino widgets/date picker not operable by external keyboard). #166683 lost its assignee to the triage bot in 2026-04 for inactivity, and a user asked 2026-05-18 about timelines due to legal accessibility requirements. So: partial support with known rough edges — materially different from "breaks external keyboard input entirely."

PRODUCT RELEVANCE: This claim should NOT be used as a reason to pick React Native over Flutter for this AAC app. The catastrophic-sounding failure is an iOS 17-era device-specific bug that Google's own testing says doesn't occur on iOS 18+. Note also that FKA is a hardware-keyboard accommodation mainly relevant to motor-impaired users; the stated target population (autistic adults mid-shutdown, selective mutism) is a touch-first, phone-in-hand use case where FKA is not on the critical path. If external-keyboard/switch access ever becomes a roadmap requirement, the honest framing is "Flutter iOS FKA is supported but has known gaps in scrolling and Cupertino widget operability," not "FKA does not exist."

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "flutter-vs-rn". A product decision depends on it, so it must be right.

CLAIM: Flutter has a documented, unfixed bug where enabling iOS Full Keyboard Access breaks external keyboard input entirely in Flutter apps
THEIR DETAIL: With an external keyboard attached, a Flutter iOS app responds normally. Turning on Settings > Accessibility > Keyboards > Full Keyboard Access causes the app to stop responding to key presses — no navigation, no button activation. Tracked across multiple open issues: flutter/flutter#76497 (feature request to support FKA navigation events), #148409 (duplicate/parallel request), #165303 and #166683 (both 2025 reports of FKA breaking external keyboards). Accessibility practitioners state flatly that 'FKA on Flutter does not exist' and that full WCAG conformance is therefore not currently achievable in Flutter on iOS. React Native, rendering real UIKit views, gets FKA behavior largely for free.
THEIR CLAIMED SOURCES: https://github.com/flutter/flutter/issues/76497, https://github.com/flutter/flutter/issues/165303, https://github.com/flutter/flutter/issues/166683, https://github.com/flutter/flutter/issues/148409, https://dev.to/adepto/improving-accessibility-in-flutter-apps-a-comprehensive-guide-1jod
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
