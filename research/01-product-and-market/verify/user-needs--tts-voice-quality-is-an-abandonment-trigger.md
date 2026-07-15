# user-needs--tts-voice-quality-is-an-abandonment-trigger

> Phase: **verify** · Agent `a9d19171bdab59498` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Directionally right on priority, wrong on the anecdote and backwards on the implication. Correct version: "TTS voice is a top-tier continued-use obstacle, not polish — 10 of 12 autistic adults in Martin & Nagalakshmi (2024/25, n=12) raised poor TTS quality (second only to speed, 11/12); 7 found voices hard to understand; 3 hit extra charges for voice options. But the 'child's voice' anecdote does NOT show app abandonment: the participant deliberately prefers pitched-down child/teen TTS because of age dysphoria, and after a friend called it 'incongruous' they used AAC with THAT FRIEND only twice — a social withdrawal, not churn, and the paper reports no voice-driven app abandonment. The paper uses this case to argue AGAINST imposing a voice on the user (including against cloning their own). The design requirement is therefore free, offline, user-selectable voices with pitch control and nonbinary/middle-pitch options — NOT an adult-sounding default, which would override this participant's stated need."

**Evidence:** SOURCE IS REAL AND QUOTES ARE VERBATIM-ACCURATE. arXiv 2404.17730 = "Aging Up AAC: An Introspection on Augmentative and Alternative Communication Applications for Autistic Adults," Lara J. Martin & Malathy Nagalakshmi. v1 Apr 2024, v3 Aug 2025. Method: 12 semi-structured interviews with autistic adults (78 signed up, 25 invited, 12 participated), recruited via the Facebook group "Ask Me, I'm an AAC user!" and X. Preprint; no confirmed venue found. Every quoted string appears in the paper exactly as the researcher rendered it. No fabrication.

WHAT HOLDS:
1. Voice quality as a first-tier problem, not polish: CONFIRMED. "Most participants (10) expressed their concerns with poor text-to-speech (TTS) quality." "Seven participants (7) felt that the available TTS voices were often hard to understand or hard to hear," and two considered voices too poor to use. In the "stumbling blocks for continued use" theme, voice quality (10) is second only to speed (11). So TTS quality is squarely a continued-use obstacle in this paper, not a cosmetic one.
2. Extra charges: CONFIRMED verbatim — "Applications will occasionally charge additionally for text-to-speech voice options (3)."
3. Voice-as-identity: CONFIRMED. "A person's identity is strongly tied to their voice"; complaints of "not enough nonbinary or middle-pitch voice options (4)," worsened "when the app prohibits even basic customizations such as adjusting the pitch (3)."

WHAT BREAKS — the specific anecdote is misread twice over:
(a) NO APP WAS ABANDONED. The participant did not abandon an application. They reduced AAC use WITH ONE FRIEND. "So I only used AAC with them twice" — "them" is the friend, not the app. The paper does not report any participant abandoning an application because of voice quality. This is a social-context withdrawal, not app churn, and in an n=12 qualitative study it is a single anecdote, not a rate.
(b) THE VOICE WAS THE USER'S OWN PREFERENCE, NOT AN APP DEFAULT — WHICH INVERTS THE PRODUCT CONCLUSION. Full context: "The only person who uses he/him pronouns out of our participants dislikes the men's voices and prefers to pitch down child/teen TTS. Even if we were to sample their speaking voice to create a TTS voice, it might not match what they actually want to sound like, making voices based on the user a less desirable option: 'My friend said it felt a little incongruous to hear a child's voice from [it]. So I only used AAC with them twice.'" The child-like voice was DELIBERATELY CHOSEN by this participant. The age-dysphoria quote is the same participant explaining why they LIKE it: "I am trans, but I deal with age dysphoria as well, which is part of why I like [this voice]. Having a voice that sounds right is, therefore really, really important." The friction came from a BYSTANDER'S reaction to a voice the user wanted — not from an app infantilizing an adult.

So the researcher's inference — "an age-inappropriate default voice re-creates the infantilization the product exists to escape" — is not supported by the datum cited; it points close to the opposite. This passage is the paper's argument AGAINST assuming what an adult should sound like (specifically, against voice-cloning-from-user as a default). Building "adult-sounding voice" into the product as the dignity fix would override exactly this participant's stated need. The paper's actual implication is pitch control and a range of voices including nonbinary/middle-pitch, with the user choosing.

NET FOR THE PRODUCT DECISION: keep the elevated priority (voice is a top-2 continued-use obstacle across 10/12 participants, and paid-voice gating is real for 3) — but reject the reasoning. The requirement is USER-SELECTABLE VOICE + PITCH CONTROL, FREE AND OFFLINE, not an adult-sounding default. Note also that free on-device TTS (flutter_tts over the OS engines) is the mechanism that dodges the paid-voice complaint, but it also constrains the voice inventory to whatever the OS ships — which is where the "not enough nonbinary/middle-pitch options" complaint will land on this product. That is the real risk, and it is not the one the researcher flagged.

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

CLAIM: TTS voice quality is an abandonment trigger, not a polish concern — one participant abandoned an app after TWO uses because the voice sounded like a child.
THEIR DETAIL: 'My friend said it felt a little incongruous to hear a child's voice from [it]. So I only used AAC with them twice.' Voice is also identity: 'I am trans, but I deal with age dysphoria as well, which is part of why I like [this voice]'; 'Having a voice that sounds right is, therefore really, really important.' The paper also notes three participants faced extra charges for text-to-speech voices. The 'risk' listed in the brief ('TTS must sound acceptable') is understated — an age-inappropriate default voice re-creates the infantilization the product exists to escape, in the one channel bystanders actually hear.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v3
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
