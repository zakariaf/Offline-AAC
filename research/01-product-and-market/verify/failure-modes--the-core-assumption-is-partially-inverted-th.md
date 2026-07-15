# failure-modes--the-core-assumption-is-partially-inverted-th

> Phase: **verify** · Agent `aa1105d0323cbad3b` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Corrected version: "Martin & Nagalakshmi (arXiv:2404.17730, 'Aging Up AAC', arXiv preprint, NLP/ACL-oriented, NOT CHI, NOT 'Zhang et al.') interviewed 12 autistic AAC users (convenience sample via Facebook/Twitter; all US; 10 of 12 part-time users). In that sample, 8/12 use text display instead of OR ALONGSIDE TTS and 3/12 prefer showing text most or all of the time. Audio output is a real and frequent failure point: 7/12 found available TTS voices often hard to understand or hard to hear, and 4/12 reported voices masked by background noise because devices cannot get loud enough; 10/12 expressed concerns with TTS overall. Social risk is well evidenced: 4/12 avoid social situations rather than face strangers' reactions, 11/12 use AAC only where the environment feels safe, and one reports 'people hear it and laugh because they think I'm making a joke.' HOWEVER, the 'no stigma against writing' point is NOT a study finding — it is the authors' hedged speculation ('Perhaps it is because of the lack of stigma against writing (vs an application)...') about a SINGLE handwriting-using participant, and should not be relied upon. The same paper documents that showing text also fails: screens too small, glare outdoors, impossible with groups (2/12), and handing your device to a stranger raises security concerns. The 2025 focus group (Frisch, Peters & Vertanen, arXiv:2507.00202, n=5) supports preference for ASYNCHRONOUS/remote text communication — a different construct from synchronous display-vs-speak — and independently confirms adoption hesitancy ('I have a communication book that I carry with me, but I've not been brave enough to use it'). CONCLUSION: the evidence supports building display ('show, don't speak') as a co-equal MVP mode rather than a v2 feature, and not defaulting to TTS-first. It does NOT support the stronger claim that the majority of autistic adult AAC users prefer display over speech, nor that writing is free of stigma. Confidence: MODERATE, from one small qualitative study plus one n=5 focus group."

**Evidence:** VERIFIED AS STATED: 8/12 use text display instead of or alongside TTS; 3/12 prefer showing text most/all of the time; 7/12 felt TTS voices "often hard to understand or hard to hear in general"; 4/12 "will often avoid social situations rather than deal with strangers' reactions to AAC"; 11/12 reported AAC use "depended on whether the environment is safe"; the quote "people hear it and laugh because they think I'm making a joke" is verbatim. Drawbacks of showing text are also confirmed (screen too small (1), distance (1), groups (2), handing device over (2), glare outside (1)). From arXiv 2507.00202: the quote "I have a communication book that I carry with me, but I've not been brave enough to use it" is verbatim.

ERROR 1 — FABRICATED ATTRIBUTION. There is no "Zhang et al." arXiv 2404.17730 is authored by Lara J. Martin and Malathy Nagalakshmi (UMBC / UPenn). The paper was retitled: v1 = "Bridging the Social & Technical Divide in AAC Applications for Autistic Adults"; current = "Aging Up AAC: An Introspection on AAC Applications for Autistic Adults". "CHI-track" is unsupported — arXiv shows no journal-ref, and the paper offers "guidelines for the NLP community," indicating an ACL-family rather than CHI venue.

ERROR 2 — THE STIGMA FINDING IS MISCHARACTERIZED (most consequential). The claim says "The stigma finding is direct." The actual text is the AUTHORS' hedged speculation about ONE participant who uses handwriting: "Perhaps it is because of the lack of stigma against writing (vs an application) they are able to do this." That is n=1, prefixed "Perhaps," authorial conjecture — not a quantified or systematic finding. The claim's second half ("stigma against AAC apps but NOT against writing") is therefore unsupported by the cited source.

ERROR 3 — STAT MISREAD. "6/12 said devices could not produce adequate volume" is wrong. The 6 is a compound count (text display driven by partners unable to understand the synthesized voice OR insufficient volume). The volume-specific figure is 4/12 ("masked by background noise because they simply can't become loud enough"). Also, 10/12 is "concerns with text-to-speech overall," not "TTS intelligibility concerns" specifically.

ERROR 4 — CATEGORY ERROR ON SECOND SOURCE. arXiv 2507.00202 (Frisch, Peters, Vertanen; arXiv preprint, submitted 2025-06-30, rev. 2025-09-17) is an asynchronous online text focus group of only FIVE autistic adults. Its async-preference support is essentially one quote ("I find expressive and receptive communication far easier in async settings"). Asynchronous/remote/time-shifted preference is a distinct construct from display-vs-speak in synchronous face-to-face use (shop, ER). It cannot be used to support display-first AAC.

ERROR 5 — OVERGENERALIZATION. "The majority of autistic adult AAC users" cannot be drawn from n=12 recruited via one Facebook group ("Ask Me, I'm an AAC user!") and Twitter; all US-based, all native English speakers, aged 18-44, and only 2 of 12 full-time AAC users (10 part-time). Additionally, 8/12 is "instead of OR ALONGSIDE" TTS — "alongside" means those users still use speech output. This evidences multimodality, not inversion of the TTS assumption.

NET: The actionable recommendation (display is a co-equal MVP mode; TTS-first is the wrong default) survives and is directionally supported by the confirmed 7/12 and 4/12 audio-failure data. But confidence should be MODERATE, not high (single n=12 qualitative interview study, non-representative sample), the stigma leg should be dropped from the reasoning entirely, and the second source should not be cited for this purpose.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "failure-modes". A product decision depends on it, so it must be right.

CLAIM: The core assumption is partially inverted: the majority of autistic adult AAC users show text rather than (or as well as) speaking it, and there is stigma against AAC apps but NOT against writing
THEIR DETAIL: Zhang et al. (arXiv 2404.17730, CHI-track study of 12 autistic adults who use AAC): 8/12 use text display features instead of or alongside TTS; 3/12 prefer showing text for most or all communication. Drivers: 10/12 had TTS intelligibility concerns, 7/12 said voices were 'hard to understand or hard to hear', 6/12 said devices could not produce adequate volume — i.e. the loud-robot-voice-in-a-shop scenario measurably fails for its advocates. The stigma finding is direct: 'there is a lack of stigma against writing (vs an application)', 4/12 avoid social situations entirely to dodge reactions to their device, one reports 'people hear it and laugh because they think I'm making a joke', and 11/12 only use AAC in environments they perceive as safe ('when there are people who have dramatic power over me... my trauma tells me it is actively not safe'). A second 2025 study (arXiv 2507.00202) found participants 'strongly preferred asynchronous text-based communication' and one carried a communication book but 'I've not been brave enough to use it.' BUT do not over-rotate: the same paper documents that showing text fails too — screens too small, sun glare, impossible with groups (2/12), and handing your device to a stranger raises security concerns. The honest conclusion is not 'drop TTS'; it is that TTS-first is wrong. This is a display-first, speak-optional communicator, and 'show, don't speak' is a co-equal MVP mode, not a v2 nice-to-have.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v1, https://arxiv.org/html/2507.00202v2
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
