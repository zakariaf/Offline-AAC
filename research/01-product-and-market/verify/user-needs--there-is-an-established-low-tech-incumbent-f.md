# user-needs--there-is-an-established-low-tech-incumbent-f

> Phase: **verify** · Agent `af1ec48346495033e` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Printed autism/non-speaking alert cards demonstrably exist and are institutionally endorsed — the Pennsylvania State Police card program (unveiled June 24, 2024, after advocate meetings) is real and directs officers verbatim to "be patient, use a calm and direct voice, and keep their questions and commands simple" — and comparable cards are listed on Etsy and Amazon by multiple sellers. However: (1) sales volume is unverified, so "widely sold" overstates what the evidence shows, and the PSP card is free rather than sold, so it evidences institutional recognition of the need but not willingness to pay; (2) alert cards are not an incumbent or substitute for AAC — they are passive disclosure aimed at prompting a bystander, whereas AAC is generative two-way speech; the two are complements. The genuine low-tech incumbent the app must beat is PEN AND PAPER, which is precisely what the "Aging Up AAC" quote (verified verbatim, §5.7.6 "Unreliability", Martin & Nagalakshmi, arXiv 2404.17730v3, 12 autistic adults, 6 of whom reported AAC bugs) actually attests to. The reliability bar — never fails to boot, never dies, never needs unlocking — is a valid and well-supported design constraint, but it should be sourced to the pen-and-paper finding, not to the card market.

**Evidence:** Adversarial check of all three sources; every checkable specific survived.

1) PSP CARD — CONFIRMED VERBATIM. pa.gov page is live. Unveiled June 24, 2024 after Gov. Shapiro and Col. Christopher Paris met with advocates (primarily Alex Mann, a Chester County autistic advocate whose teacher-made personal card sparked the program; Mann has visited 500+ agencies since Dec 2019). Card alerts officers the individual may be nonverbal, bothered by loud noises, hyper-sensitive to touch, and unresponsive to commands. Officers directed to "be patient, use a calm and direct voice, and keep their questions and commands simple" — the researcher's wording is an exact quote. Independently corroborated by CBS Philadelphia, WITF, Police1, Police Magazine, Vista Autism Services. Note: card is FREE (print from PSP Safety Resources page or save to phone), not sold.

2) ARXIV QUOTE — CONFIRMED VERBATIM AND IN CORRECT CONTEXT. arXiv 2404.17730 = "Aging Up AAC: An Introspection on Augmentative and Alternative Communication Applications for Autistic Adults," Lara J. Martin & Malathy Nagalakshmi, submitted 2024-04-26, v3 dated 2025-08-04. Quote "always have and always will carry pen and paper just because it's the most reliable" appears in Section 5.7.6, titled "Unreliability" — read in context, not cherry-picked. Methodology: 12 in-depth interviews with autistic adults; 8 thematic categories; 6 of 12 participants reported hitting bugs in their AAC.

3) ETSY LISTING — EXISTS. Listing 1867756207 direct-fetch returns HTTP 403 (Etsy bot block), but resolves via search as "Autism and Non Speaking Medical Alert Card – Neurodivergent Communication Emergency ID," with "I have Autism and am Non Speaking" on front and how-to-help guidance on reverse. Category confirmed by a second independent listing (1450384015 "Non Verbal Notice Card | Non Speaking | Nonverbal | Autism") and an Amazon 5-pack (B0CTSB64T9). Price could not be verified due to the 403.

TWO FRAMING DEFECTS SURVIVE:

(a) "Widely sold" is unsupported as to VOLUME. Listing existence proves supply, not demand. No sales figures were obtained from Etsy or Amazon; Etsy listings are near-zero-cost to create and a category can persist on trivial volume. The only strong demand signal is the institutional one (PSP), which is a free print-at-home card, not a sale — so it does not evidence willingness to pay.

(b) "Incumbent" conflates two distinct jobs. An alert card is PASSIVE DISCLOSURE ("I am autistic, be patient") requiring a bystander to act. AAC is GENERATIVE TWO-WAY SPEECH (ordering coffee, answering ER triage). A card cannot perform the app's core job, so it is a complement, not a substitute or incumbent — many users would rationally carry both, and the app is not displacing card sales. The true low-tech incumbent for the app's actual job is pen and paper. The researcher stacked the card evidence and the pen-and-paper evidence as mutually supporting one point; only the latter bears on the app's competitive position.

The reliability-bar conclusion is SOUND but should rest on the pen-and-paper finding alone (§5.7.6 Unreliability; 6/12 bug reports), which independently supports it. Caveat: that is n=1 for the quote within a 12-person qualitative study — directionally real, not a generalizable statistic.

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

CLAIM: There is an established low-tech incumbent for the bystander problem — printed autism/non-speaking alert cards — confirming demand but setting a reliability bar the app must beat.
THEIR DETAIL: Cards stating 'I have Autism and am Non Speaking' with 'how to help' guidance on the reverse are widely sold (Etsy, Amazon) and institutionally endorsed: the Pennsylvania State Police unveiled an informational card program with advocates, directing officers to be patient, use a calm direct voice, and keep questions simple. Meanwhile a participant in 'Aging Up AAC' said they 'always have and always will carry pen and paper just because it's the most reliable.' The app is competing with paper, which never fails to boot, never dies, and never needs unlocking.
THEIR CLAIMED SOURCES: https://www.pa.gov/agencies/psp/newsroom/after-meeting-with-advocates--pennsylvania-state-police-unveils-, https://www.etsy.com/listing/1867756207/personalized-autism-medical-alert-card, https://arxiv.org/html/2404.17730v3
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
