# legal-regulatory--google-play-now-forces-the-medical-device-qu

> Phase: **verify** · Agent `a6fa43a323a03aee9` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** Claim stands as written. Two refinements: (1) the researcher's own caveat is too conservative — EU MDR 2017/745 / IVDR 2017/746 disclosure requirements ARE on Google's primary page answer/14738291, so the EU regulatory hook is verified, though the "MDCG guidance pulled into the policy" phrasing and the January 2026 timing are not primary-confirmed; (2) source answer/13996367 does not support the medical-device declaration specifics and should be dropped from the citation list — the load-bearing sources are answer/16679511 (policy text, device label, disclaimer) and answer/14738291 (all-developers/testing-tracks scope, Aug 31 2024 deadline, EU MDR/IVDR disclosures).

**Evidence:** Attempted refutation; all specifics hold verbatim against Google's primary policy pages.

CONFIRMED VERBATIM on support.google.com/googleplay/android-developer/answer/16679511 (Health Content and Services):
- "All developers must complete the Health apps declaration form on the App content page (Monitor & Improve > Policy > App content) in Play Console."
- "Apps that are regulated because they are a medical device must be declared as such and information required by this article must be completed."
- "These apps will be identified as a 'Medical Device' on Google Play."
- "Apps that are regulated as a medical device must provide proof of approval, clearance or certification by the relevant authority upon request."
- "Other health and medical apps must include a clear disclaimer in their app description indicating that the app is 'not a medical device and does not diagnose, treat, cure, or prevent any medical condition.'" plus a requirement to "remind users to consult a healthcare professional for medical advice, diagnosis, or treatment."

CONFIRMED VERBATIM on answer/14738291 (Health apps declaration):
- "All developers that have an app published on Google Play must complete the Health apps declaration, including apps on closed testing, open testing, or production tracks." System services and private apps exempt.
- "After August 31, 2024, all apps will be required to have completed an accurate Health apps declaration that discloses the health features their app supports."

CORRECTION IN THE CLAIM'S FAVOR: the researcher's caveat that no MDCG/MDR/CE text appears on Google's own pages is itself wrong. answer/14738291 explicitly invokes EU Medical Devices Regulation 2017/745 (MDR) and In Vitro Diagnostic Regulation 2017/746 (IVDR), requiring apps distributed in the EEA/Northern Ireland to publicly disclose device name, manufacturer Single Registration Number, intended purpose, warnings/precautions, eIFU link, UDI-DI, and (where applicable) authorized representative, notified body number, certificate number. So the EU regulatory hook IS primary-sourced; the researcher checked the policy page rather than the declaration page.

REMAINING UNVERIFIED (minor, does not affect the claim): the "Jan-2026 update" dating. Neither page shows a last-updated date, and no primary source confirms the EU label/MDR text was added in January 2026 rather than being longstanding. The declaration requirement demonstrably predates it (Aug 2024 deadline, announced April 2024). Treat the requirement as real and the "new in Jan 2026" framing as secondary-source only.

The third cited source, answer/13996367 (Health app categories and additional information), is real and consistent but is the weakest support: it contains no medical-device declaration protocol and no EU references; its only "proof upon request" language concerns review board approval for human-subjects research apps, not device clearance. Do not cite it for the device claims.

PRODUCT-DECISION NUANCE: "cannot stay silent" is accurate as to the form being mandatory for any published app including test tracks, but the obligation is to complete the declaration, not to self-identify as health/medical. An offline tap-to-speak AAC app making no diagnosis/treatment claims answers the declaration and at most falls under the "other health and medical apps" disclaimer rule, or outside health features entirely. MDR/IVDR exposure attaches only if a medical purpose is claimed.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "legal-regulatory". A product decision depends on it, so it must be right.

CLAIM: Google Play now forces the medical-device question into the submission flow — you cannot stay silent about it
THEIR DETAIL: Play's Health Content and Services policy requires ALL developers with a published app (including closed/open testing) to complete the Health apps declaration form (Policy > App content). Apps regulated as a medical device 'must be declared as such' and will be 'identified as a "Medical Device" on Google Play', and 'must provide proof of approval, clearance or certification by the relevant authority upon request.' Non-device health apps must include 'a clear disclaimer in their app description indicating that the app is not a medical device and does not diagnose, treat, cure, or prevent any medical condition' and must remind users to consult a healthcare professional. Reporting caveat: multiple secondary sources say the Jan-2026 update adds an EU 'Medical Device' label and pulls MDCG guidance into the policy, but I could not confirm any MDCG/MDR/CE text on Google's own policy page — treat the EU-label specifics as unverified.
THEIR CLAIMED SOURCES: https://support.google.com/googleplay/android-developer/answer/16679511?hl=en, https://support.google.com/googleplay/android-developer/answer/14738291?hl=en, https://support.google.com/googleplay/android-developer/answer/13996367?hl=en
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
