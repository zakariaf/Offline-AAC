# legal-regulatory--apple-s-macos-sla-bans-recording-redistribut

> Phase: **verify** · Agent `a4106f5cbb5487832` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Apple's macOS SLA (§2.F "Voices; Live Captions", verbatim as quoted, present in both Sequoia and current Tahoe 26) does bar recording/redistributing System Voices in a commercial context — but this binds macOS end users and is irrelevant to a Flutter iOS + Android AAC app. The iOS/iPadOS 26 SLA contains NO system-voice restriction: its parallel §2(f) defines "System Characters" as Genmoji/Memoji, and restricts only Live Captions and Personal Voice. The Xcode and Apple SDKs Agreement mentions voice/speech/TTS zero times. So on the actual target platform there is no SLA prohibition on pre-rendering AVSpeechSynthesizer output — the "shipping is not defensible" conclusion is unsupported for iOS. (Independent risks remain: Personal Voice is genuinely off-limits commercially on iOS, and third-party voice-vendor licensing plus App Store review are separate questions to check. Restriction would apply only if a macOS build were shipped.)

**Evidence:** VERBATIM QUOTE: ACCURATE. I downloaded macOSSequoia.pdf and extracted §2.F myself. It matches the researcher's quote word-for-word, including "No other creation or use of the System Voices, Live Captions or Personal Voice is permitted by this License, including but not limited to the use, reproduction, display, performance, recording, publishing or redistribution of any of the System Voices, Live Captions or Personal Voice in a profit, non-profit, public sharing or commercial context." No fabrication.

NOT OUTDATED. Sequoia is macOS 15 (2024). Current is macOS Tahoe 26. I downloaded macOSTahoe.pdf (895pp) and the clause survives unchanged at "F. Voices; Live Captions" with identical text.

FATAL SCOPE ERROR. The product is a Flutter iOS + Android app. The macOS SLA does not govern it, and the iOS SLA contains NO equivalent restriction. I extracted the full iOS26_iPadOS26.pdf (930pp, 3.6M chars):
- "System Voice" -> 0 occurrences
- All 13 case-insensitive "voice" hits are only Personal Voice, plus incidental "cellular voice" and "voice assets"

The parallel iOS clause §2(f) exists but defines its restricted term as something else entirely: "(i) use the Genmoji and Memoji characters included in or created with the Apple Software ("System Characters") (1) while running the Apple Software and (2) to create your own original content and projects for your personal, non-commercial use... No other creation or use of the System Characters, Live Captions, or Personal Voice is permitted..."

"System Characters" = Genmoji/Memoji, NOT voices. Apple deliberately substituted a character restriction for the voice restriction on iOS. iOS restricts only Live Captions and Personal Voice. There is no system-TTS-voice restriction on iOS.

DEVELOPER-FACING AGREEMENT IS SILENT. The Xcode and Apple SDKs Agreement (xcode.pdf, 15pp) — the instrument actually governing building/shipping an app — contains 0 occurrences of "voice", "Voice", "speech", "Speech", "TTS". Structurally, the macOS SLA is an END-USER agreement binding the person running macOS on their own Mac; it is not a developer distribution agreement and does not reach an app's iPhone users.

SECONDARY POINT — THEIR macOS READING IS ITSELF SHAKIER THAN "high" CONFIDENCE ALLOWS. They read "(1) while running the Apple Software and (2) to create your own original content... for your personal, non-commercial use" as disjunctive alternatives, making live playback independently licensed. The conjunction is "and", so a strict conjunctive reading would arguably bar even live playback in a commercial macOS app. Their "live playback is fine" is supported by universal practice and by Apple shipping AVSpeechSynthesizer as a public unrestricted SDK API, but it is a reading, not settled text — which undercuts high confidence in both directions.

NET: The macOS-only statement is confirmed verbatim. The operative product conclusion ("shipping pre-rendered AVSpeechSynthesizer audio is prohibited") rests on the wrong platform's agreement and does not follow for the actual iOS/Android target. Note this does not make shipping pre-rendered audio automatically safe on iOS — third-party/vendor voice licensing and App Store review are separate questions — but the asserted SLA basis does not exist on iOS.

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

CLAIM: Apple's macOS SLA bans recording/redistributing system TTS voices commercially — live playback is fine, pre-rendered audio files are not
THEIR DETAIL: macOS Sequoia SLA §2.F 'Voices; Live Captions' (extracted verbatim from Apple's own PDF): 'you may: (i) use the system voices included in the Apple Software ("System Voices") (1) while running the Apple Software and (2) to create your own original content and projects for your personal, non-commercial use... No other creation or use of the System Voices, Live Captions or Personal Voice is permitted by this License, including but not limited to the use, reproduction, display, performance, recording, publishing or redistribution of any of the System Voices, Live Captions or Personal Voice in a profit, non-profit, public sharing or commercial context.' Reading: AVSpeechSynthesizer live playback on the user's own device is the normal, universally-practiced use ('while running the Apple Software') and is what every commercial AAC app does. But using AVSpeechSynthesizer.write(_:toBufferCallback:) to pre-render phrase audio and SHIP those files in the app binary is recording + redistribution in a commercial context — prohibited. On-device caching for that user only is grey but defensible; shipping is not.
THEIR CLAIMED SOURCES: https://www.apple.com/legal/sla/docs/macOSSequoia.pdf, https://www.apple.com/legal/sla/docs/macOSVentura.pdf
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
