# failure-modes--yes-shipping-only-os-voices-is-a-dignity-fai

> Phase: **verify** · Agent `a7b40f445564d2209` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Confirmed: OS-voices-only IS a dignity failure continuous with infantilization, backed verbatim by Martin & Nagalakshmi 2024 (arXiv 2404.17730) — both quotes exact, 4/12 on nonbinary/middle-pitch confirmed by the paper's "(4)" notation. Corrections to the supporting detail: (a) Personal Voice does NOT mitigate this gap — it models the user's own voice, targets progressive speech loss (ALS), and offers zero androgynous options; for a trans user with voice dysphoria it reproduces the dysphoric voice. It is voice preservation, not voice identity. (b) The Android asymmetry is unsupported and probably inverted: Android's TextToSpeech(engineName)+getVoices() can use any system-wide installed engine (RHVoice, eSpeak NG, Acapela), while iOS AVSpeechSynthesizer is limited to Apple voices + Personal Voice and locks away its own gender-neutral Siri voice Quinn. iOS is the more fixed binary menu for a third-party AAC app. (c) Piper's licensing changed: rhasspy/piper (MIT) archived Oct 6 2025; active successor OHF-Voice/piper1-gpl is GPL-3.0 (v1.4.2, Apr 2026), effectively App-Store-incompatible for a proprietary app — a blocker the claim omits. Voice sizes ~20MB (low) to ~120MB (high), so "tens of MB" understates high quality. (d) Pitch/rate sliders likely cannot synthesize genuine androgynous voices (f0 alone does not set perceived gender; formants/resonance matter) — ship them, but don't credit them as satisfying the request. The right architecture is platform-symmetric bundled neural voices with license clearance, not iOS-Personal-Voice-plus-Android-apology.

**Evidence:** HEADLINE THESIS: CONFIRMED, verbatim. I tried to break the empirical core and could not. Martin & Nagalakshmi 2024 (arXiv 2404.17730), "Bridging the Social & Technical Divide in AAC Applications for Autistic Adults," 12 semi-structured interviews with autistic adults (18-44, US, high-tech AAC users, recruited via the "Ask Me, I'm an AAC user!" Facebook group and Twitter). Both quotes are exact, not paraphrased:
- "More customizable voices, for sure. It's very personal and having the voice that matches every other person who uses AAC is very disempowering."
- "I think the most important thing I look for is a compatible voice pack. As I mentioned before, I am trans, but I deal with age dysphoria as well, which is part of why I like [this voice]. Having a voice that sounds right is, therefore really, really important."
The paper states "one of the most common complaints we saw was that there aren't enough nonbinary or middle-pitch voice options (4)" — the "(4)" notation confirms 4 of 12. The researcher's 4/12 figure and the dignity framing are accurate and correctly sourced. Converging evidence exists (a later AAC voice-identity study found nonbinary respondents rated nearly every voice-satisfaction dimension ~1 point lower than men and women pooled).

Notably, the "fixed binary menu" premise is STRONGER than they argued on iOS: Apple's gender-neutral voice Quinn (iOS 15.4, 2022, recorded by an LGBTQ+ community member) is Siri-locked and NOT reachable from AVSpeechSynthesizer. The one androgynous voice Apple owns is unavailable to exactly this app.

WHERE IT BREAKS — three material errors in the mitigation architecture:

1. PERSONAL VOICE IS THE WRONG FIX (category error). Apple's own newsroom copy: Personal Voice is for "users at risk of losing their ability to speak — such as those with a recent diagnosis of ALS... or other conditions that can progressively impact speaking ability," created by "reading along with a randomized set of text prompts." It models the user's OWN voice and yields exactly one voice: theirs. It provides zero androgynous or middle-pitch options. For the cited trans participant with gender AND age dysphoria, cloning their current voice reproduces the dysphoric voice — the very complaint. Personal Voice solves voice PRESERVATION; the paper documents a voice IDENTITY gap. Calling it a "real mitigation" for this dignity gap is a misread. (Also outdated: iOS 26 cut setup from ~150 prompts/15 min to 10 phrases in under a minute, but requires an Apple-Intelligence-capable iPhone.)

2. THE ANDROID ASYMMETRY IS UNSUPPORTED AND LIKELY INVERTED. Since Personal Voice doesn't address the androgyny gap, its absence on Android creates no dignity deficit on this axis. On the axis that does matter — voice variety — Android is MORE open: TextToSpeech(Context, OnInitListener, engineName) plus getVoices() lets the app use ANY system-wide installed engine (RHVoice, free/open; eSpeak NG; Acapela), while iOS AVSpeechSynthesizer is confined to Apple system voices + Personal Voice, with Quinn walled off. "The Android build is structurally condemned to a worse dignity experience" is the opposite of what the platform APIs support. iOS is the more locked binary menu here.

3. THE PIPER MITIGATION HAS AN UNMENTIONED LICENSING LANDMINE. rhasspy/piper (MIT) was ARCHIVED read-only on Oct 6, 2025. Active development moved to OHF-Voice/piper1-gpl, which is GPL-3.0 (latest v1.4.2, Apr 2026). GPL-3.0 is effectively incompatible with App Store distribution of a proprietary app. "Bundle Piper-class voices" is not a casual cost-of-MB tradeoff — it forces a choice: ship the archived unmaintained MIT fork, pick a different engine, or open-source the app. The size figure "~tens of MB per voice" holds for low (~20MB) and medium (~60MB) quality but understates high quality (~110-120MB).

CAUTION (flagged, not verified — ACM DL returned 403): the "cheap partial mitigation" of pitch/rate sliders is likely overstated on its own terms. Pitch shifting alters f0 but not formants/resonance, and perceived voice gender is known to depend on more than f0. The existence of a dedicated research line — "Creating Inclusive Voices for the 21st Century: A Non-Binary Text-to-Speech" (CHI 2023) — is itself evidence that a pitch slider does not produce a credible androgynous voice; if it did, that work would be unnecessary. Treat pitch controls as worth shipping (cheap, user-requested) but do NOT count them as delivering the middle-pitch voices the 4/12 asked for.

NET FOR THE PRODUCT DECISION: Ship the thesis — OS-voices-only is a real dignity failure, well-evidenced. Discard the remediation plan. The correct move is platform-symmetric (bundle non-Apple neural voices with genuine androgynous options, license-cleared), not "Personal Voice on iOS, apologize on Android." The Android pessimism should be dropped; if anything, iOS is the constrained platform.

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

CLAIM: Yes — shipping only OS voices IS a dignity failure, and it is the infantilization problem wearing a different mask
THEIR DETAIL: The founder's hypothesis is correct and the evidence is blunt. One participant: 'It's very personal and having the voice that matches every other person who uses AAC is very disempowering.' 4/12 specifically flagged that nonbinary and middle-pitch voice options are severely lacking. A trans participant experiencing both gender and age dysphoria: 'Having a voice that sounds right is, therefore really, really important.' OS voice sets are a small, fixed, binary-gendered menu — so an OS-voices-only app hands every user the same handful of identities and tells adults which voices they are allowed to have. That is the same paternalism as cartoon avatars. Cheap partial mitigation: expose pitch/rate/volume controls to synthesize the middle-pitch androgynous voices users explicitly ask for and the OS does not provide. Real mitigations: Personal Voice on iOS (native channel), or bundle on-device neural voices (Piper-class) with androgynous options — at the cost of ~tens of MB per voice, added latency and battery. Android has no Personal Voice equivalent, so the Android build is structurally condemned to a worse dignity experience; that asymmetry should be stated openly rather than papered over.
THEIR CLAIMED SOURCES: https://arxiv.org/html/2404.17730v1, https://www.apple.com/newsroom/2023/05/apple-previews-live-speech-personal-voice-and-more-new-accessibility-features/, https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/personalvoiceauthorizationstatus
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
