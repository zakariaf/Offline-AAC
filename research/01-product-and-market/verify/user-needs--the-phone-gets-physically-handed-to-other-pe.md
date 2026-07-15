# user-needs--the-phone-gets-physically-handed-to-other-pe

> Phase: **verify** · Agent `a66bcf53a0d194b12` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Displaying text on screen for a partner to read, rather than speaking it aloud, is a majority interaction mode among autistic adult AAC users — 8 of 12 participants in Aging Up AAC (arXiv 2404.17730) use their app's text display instead of or alongside TTS. The drivers are ambient noise and TTS intelligibility/volume, NOT primarily privacy. Separately and much more weakly, 2 of 12 participants noted that handing over an unlocked phone exposes the rest of the device (other apps, snooping) — an OS-level problem the app can mitigate only by prompting iOS Guided Access / Android screen pinning, not by hardening its own UI. The dominant privacy concern in the paper is corporate data collection (11 of 12), which the offline/no-account architecture already addresses. Product implication: build the large-text display mode as a core MVP feature (well-evidenced, cheap); do not scope a privacy-hardened "handover mode" as core on the strength of 2 participants, and do not promise leak-prevention the app cannot architecturally deliver.

**Evidence:** QUOTE VERIFIED VERBATIM. Fetched arXiv 2404.17730v3, "Aging Up AAC: An Introspection on Augmentative and Alternative Communication Applications for Autistic Adults" (12 autistic adults, ages 18-44, using high-tech AAC at least occasionally). Section 5.8.2 "Unwanted outsider access" contains the full untruncated quote: "Sometimes my AAC use involves handing my phone to another person for them to read and I always have to trust that they're not going to then use my unlocked phone and go snooping."

HALF A: "show, don't speak" mode — CONFIRMED AND UNDERSTATED. This is NOT supported by the handover quote the researcher cited; it is supported by a different and much stronger passage. Section 5.2.1: "Many participants (8) use the text display feature of their AAC app instead of, or in conjunction with, the TTS." That is 8/12 — a majority. Stated drivers: conversation partners cannot understand the synthesized voice; TTS volume insufficient; some prefer showing text most or all of the time; others switch between modes. Section 5.4.3: participants use text display when environmental noise prohibits TTS audibility. Display-instead-of-speech is a first-class interaction mode. The researcher's "medium" confidence should be raised to high for this half.

HALF B: "must not leak private content when handed over" — OVERSTATED ON THREE COUNTS.
(1) PREVALENCE INFLATED: only 2 of 12 participants raised the snooping/unlocked-phone concern. By contrast 11 of 12 raised concerns about corporate/unwanted data collection, which is the paper's dominant privacy theme and maps to the offline/no-account premise rather than to a handover mode.
(2) MECHANISM MISATTRIBUTED (load-bearing): the participant fears someone snooping THE UNLOCKED PHONE — other apps, messages, photos. It is not a fear that the AAC app leaks its own content. The researcher's inference that "a handed-over phone should not expose notifications, message history, or other apps" is extrapolation; the paper contains no discussion of notifications or app visibility. It also points at something an AAC app cannot architecturally solve — the remedy is OS-level (iOS Guided Access, Android screen pinning). The app can only surface those features.
(3) SITUATIONAL FRAMING PARTLY UNSOURCED: "loud shops" is supported (noise -> text display, Sec 5.4.3). "ERs" and "where speaking aloud would draw attention" do not appear as cited scenarios in this paper — plausible but unsourced additions by the researcher.

CORROBORATION CHECK: fetched arXiv 2507.00202v2 ("The Role of AAC in Social Communication and Community Engagement", 5 autistic adults) looking for independent support of the display-mode finding. It does NOT contain discussion of display-vs-TTS, loud environments, or device handover. So the display-mode evidence rests on the single cited paper (n=12), not on multiple independent sources.

NET: the claim's conclusion (build a display mode) is correct and well-evidenced, but the researcher reached it via the wrong quote, and bolted on a privacy requirement that rests on 2/12 participants and misdescribes the threat model.

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

CLAIM: The phone gets physically handed to other people — the app must have a 'show, don't speak' mode and must not leak private content when handed over.
THEIR DETAIL: From 'Aging Up AAC': 'Sometimes my AAC use involves handing my phone to another person for them to read and I always have to trust...' [quote truncated in source]. This is a distinct interaction mode from speaking aloud, and it matters in loud shops, in ERs, and where speaking aloud would draw attention. It also means a handed-over phone should not expose notifications, message history, or other apps.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v3
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
