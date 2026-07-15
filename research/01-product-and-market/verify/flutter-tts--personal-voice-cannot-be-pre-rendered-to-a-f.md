# flutter-tts--personal-voice-cannot-be-pre-rendered-to-a-f

> Phase: **verify** · Agent `a7a5f5b3b76f2fb05` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Personal Voice cannot be captured via AVSpeechSynthesizer's buffer-callback path (writeUtterance:toBufferCallback), which is exactly how flutter_tts implements synthesizeToFile on iOS (SwiftFlutterTtsPlugin.swift ~lines 158-211) — so Personal Voice cannot be pre-rendered to a file for a tile cache. However: (a) this is UNDOCUMENTED runtime behavior, not a documented by-design limitation — Apple has never stated it in docs, WWDC, or any forum reply; (b) thread 736148 does NOT confirm a background-playback restriction — the OP asked exactly that question and received no answer, and the only corroborating reply reproduced the buffer issue, not background playback; (c) rather than failing, the API "defaults to output channel," meaning it speaks aloud while producing a silent/empty file — guard with voiceTraits.contains(.isPersonalVoice) before calling synthesizeToFile; (d) a macOS-only DYLD-injection workaround exists (limneos/SavePersonalVoiceAudio) but is unusable on iOS/App Store. Confidence should be MEDIUM pending on-device retest on current iOS, not HIGH.

**Evidence:** The buffer-callback half is substantiated; the background-playback half and the "documented/by-design/no workaround" framing are not.

CONFIRMED:
1. The error string is verbatim-accurate. Apple Developer Forums thread 736148 ("Unable to use Personal Voice in background playback", Aug '23, poster kauai) contains exactly: "Cannot use AVSpeechSynthesizerBufferCallback with Personal Voices, defaulting to output channel." A second poster (developer555) reproduced it via writeUtterance:toBufferCallback. Other voices work fine.
2. The flutter_tts source claim is accurate. SwiftFlutterTtsPlugin.swift synthesizeToFile (lines ~158-211, so "line ~170" is fair) is implemented as: `self.synthesizer.write(utterance) { (buffer: AVAudioBuffer) in ... try! output!.write(from: pcmBuffer) }` into an AVAudioFile — exactly the buffer-callback path. The collision with a pre-render tile cache is real.
3. Corroborating: limneos/SavePersonalVoiceAudio documents the parallel macOS limitation (`say -o` cannot save Personal Voice to file).

REFUTED / OVERSTATED:
1. NOT "documented" and NOT confirmed "by-design". No Apple documentation, no WWDC23 statement (session 10033 says only that Personal Voice is authorization-gated and "should be primarily used for augmentative or alternative communication apps"), and no Apple staff reply anywhere states this restriction. It is an undocumented runtime behavior inferred from a log string.
2. The background-playback claim is a direct misread of the cited thread — the thread does the opposite of confirming it. The OP ASKED the question and never got an answer: "Is this a published limitation of Personal Voice within applications, i.e. no background playback?" No reply addressed it. Thread has 2 posters, 2 replies, no resolution, no Apple response.
3. "Multiple developers reproducing" background blockage is false. Exactly one other developer replied, and he reproduced the BUFFER issue, not background playback. General AVSpeechSynthesizer background-audio problems are a long-standing framework/audio-session issue not specific to Personal Voice; the OP's background failure was plausibly audio-session misconfiguration (Playback category + Audio background mode) misattributed to a log line about a different subsystem.
4. "No workaround" is overstated in the absolute: limneos/SavePersonalVoiceAudio works around it on macOS Sonoma via DYLD_INSERT_LIBRARIES injection into `say`. This does NOT rescue the iOS strategy (macOS-only, private-injection, App Store-illegal), so the practical conclusion survives, but the absolute phrasing does not.

MISSED DETAIL THAT MATTERS: "defaulting to output channel" means the API degrades rather than fails — the synthesizer still SPEAKS ALOUD. So flutter_tts synthesizeToFile with a Personal Voice will likely produce a silent/empty file WHILE the device unexpectedly speaks out loud. That is a worse failure mode than described and needs an explicit guard (check voice.voiceTraits.contains(.isPersonalVoice) before any synthesizeToFile call).

Currency check: the sole evidence base is a 2023-era thread, still unanswered by Apple as of 2026-07-15. No source found showing the buffer restriction was lifted in iOS 18-26, but equally no source showing Apple ever affirmed it as intentional. Nobody has retested and published since iOS 17. The researcher's "high" confidence is not earned on the background half and rests on an unmaintained single data point on the buffer half; the engineering conclusion is sound but the evidence is thinner than presented and should be validated empirically on-device.

PRODUCT IMPACT: essentially unchanged. Pre-rendered tile cache = system voices only; Personal Voice = live/foreground/uncached. The background-playback error is immaterial to this AAC app anyway (tapping a tile speaks in the foreground), so the corrected claim does not alter the architecture decision — but do not cite thread 736148 as evidence of a background limitation, because it is not.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "flutter-tts". A product decision depends on it, so it must be right.

CLAIM: Personal Voice CANNOT be pre-rendered to a file and CANNOT speak in the background — this is a documented, by-design limitation with no workaround
THEIR DETAIL: Attempting writeUtterance:toBufferCallback with a Personal Voice yields the runtime message: 'Cannot use AVSpeechSynthesizerBufferCallback with Personal Voices, defaulting to output channel.' Standard system voices work fine with buffer callbacks. Apple Developer Forums thread 736148 confirms this also blocks background playback for Personal Voice specifically, with multiple developers reproducing and no Apple workaround offered. This directly collides with the pre-render caching strategy: flutter_tts's synthesizeToFile on iOS is implemented with AVSpeechSynthesizer.write() into an AVAudioFile (SwiftFlutterTtsPlugin.swift line ~170), i.e. exactly the buffer-callback path Personal Voice rejects. So: pre-rendered tile cache = system voices only; Personal Voice = live, foreground, uncached only.
THEIR CLAIMED SOURCES: https://developer.apple.com/forums/thread/736148, https://raw.githubusercontent.com/dlutton/flutter_tts/master/ios/Classes/SwiftFlutterTtsPlugin.swift
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
