# flutter-tts--ios-avspeechsynthesizer-is-on-device-by-defa

> Phase: **verify** · Agent `a63c92067ac61bef6` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** iOS AVSpeechSynthesizer synthesizes Apple's own voices entirely on-device (including Personal Voice, per WWDC23-10033), and Apple exposes no network-voice attribute — so there is no network round-trip to defend against for system voices, and flutter_tts's iOS voice map (quality/gender/identifier only) reflects this. Android is indeed the real exposure: Voice.isNetworkConnectionRequired() is real, flutter_tts surfaces it as network_required on Android voices, and open issue #429 (Android, still open) documents a user hitting the "en-us-x-sfg-network" voice — so filtering network voices on Android is mandatory. Two corrections: (1) issue #136 is NOT evidence of accidental network voices — it is a 2020 report against flutter_tts 0.1.x that was never diagnosed, the maintainer said he speaks fine offline, and its only stack trace is a SocketException to the reporter's own dev server at 192.168.0.101:3000; drop it. (2) iOS is "low risk, no filter available" rather than a non-problem: iOS 16+ third-party Speech Synthesis Provider extensions register voices system-wide into AVSpeechSynthesisVoice.speechVoices() with no isNetworkConnectionRequired equivalent to screen them. More importantly, iOS's actual offline risk is voice availability, not network — enhanced/premium voices are 100MB+ user-downloaded and user-deletable, and an unknown identifier silently falls back to the default compact voice, which for an AAC app is a real quality regression that needs explicit handling (existence check at speak time, availableVoicesDidChangeNotification, first-run download guidance).

**Evidence:** CORE CLAIM SURVIVES; TWO SPECIFICS ARE WRONG.

CONFIRMED:
1. WWDC23 session 10033 exists and is correctly titled "Extend Speech Synthesis with personal and custom voices." It states verbatim: "Your Personal Voice is generated on the device and not on a server. This voice will appear amongst the rest of the System voices." Personal Voice on-device claim = accurate.
2. AVSpeechSynthesizer on-device synthesis corroborated by Apple docs and third-party technical writeups (callstack.com 2025 on-device TTS writeup: "All text-to-speech conversion happens locally. No user data ever leaves the device... runs entirely on-device... works flawlessly without an internet connection"). Apple's AVSpeechSynthesisVoice exposes quality (default/enhanced/premium) and traits (isPersonalVoice/isNoveltyVoice) — no network attribute exists at all.
3. Voice.isNetworkConnectionRequired() exists as claimed (API 21+): "Starting from API level 21, to select network synthesis, call TextToSpeech#getVoices(), find a suitable network voice using Voice#isNetworkConnectionRequired(), and pass it to TextToSpeech#setVoice(Voice)." Android exposure is real.
4. flutter_tts DOES expose the needed filter, asymmetrically — README: Android voice maps include "quality, latency, network_required, features"; iOS/macOS maps include only "quality, gender, identifier". The package's own data model confirms no iOS network tier and provides no iOS filter. The Android-side filter is implementable and the recommendation is sound.
5. Issue #429 verified via GitHub API: exact title "setProgressHandler seems to be inaccurate for voices that are \"network\".", opened 2023-11-02, still OPEN, 0 comments, platform checkbox = Android ONLY, and it names the offending voice explicitly: "en-us-x-sfg-network" vs "en-us-x-sfg-local". This is genuine, direct evidence that Android users land on network voices. Quoted accurately.
6. Issue #136 verified: exact title "Audio playing doen't work when Internet goes off" (sic), opened 2020-07-07, OPEN. Platform checkboxes are iOS=[ ] UNCHECKED, Android=[x] CHECKED — i.e. Android-only, which is consistent with (not contrary to) the researcher's thesis.

WRONG / OVERSTATED:
A. Issue #136 is misused as "direct evidence that users do land on network voices by accident." It is not. Filed 2020 against flutter_tts 0.1.x / Flutter 1.17.5. It was NEVER diagnosed as a network voice. Maintainer dlutton replied twice, contradicting the premise: "As long as I have the TTS engine installed on my device, I can run the speak method successfully with the internet off." The only stack trace in the thread (aarzhou, 2020-08-21) is "SocketException: Connection failed... address = 192.168.0.101, port = 3000" — that is the reporter's OWN local dev backend, not the Android TTS engine. Contaminated, undiagnosed, 6-year-old evidence. #429 alone carries the Android argument; #136 should be dropped.
B. "There is no network-voice tier to defend against on iOS" is an assumption, not a documented guarantee. iOS 16+ Speech Synthesis Provider audio-unit extensions (AVSpeechSynthesisProviderVoice / AVSpeechSynthesisProviderAudioUnit) let third-party apps register voices system-wide INTO AVSpeechSynthesisVoice.speechVoices(), which AVSpeechSynthesizer will then route to. Apple documents no requirement that these be on-device, and — critically — iOS ships NO isNetworkConnectionRequired equivalent, so there is no filter available if one were network-backed. WWDC23 10033's provider sample uses local App Groups + local audio buffers, and I found no network-backed provider shipping in the wild, so real exposure is LOW — but the correct statement is "low risk with zero available defense," not "non-problem."
C. The framing misdirects the real iOS risk for THIS product. iOS's offline failure mode is voice AVAILABILITY, not network. Enhanced/premium voices (added iOS 16) are each 100MB+, must be manually downloaded by the user via Settings > Accessibility > Spoken Content/Live Speech > Voices, and are user-deletable. Passing an unknown/deleted voice identifier causes iOS to SILENTLY fall back to the default compact voice. For an AAC app whose own stated risk is "TTS must sound acceptable," that silent quality downgrade is the iOS thing to defend against (check voice existence at speak time via AVSpeechSynthesisVoice(identifier:), subscribe to availableVoicesDidChangeNotification, guide first-run voice download). Calling iOS "a non-problem" would lead the team to skip this.

NET FOR THE PRODUCT DECISION: "Android needs a mandatory network_required filter; iOS needs no force-offline network work" is correct and actionable. But iOS is not zero-work — it needs voice-availability handling, and the #136 citation should be removed from the evidence base.

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

CLAIM: iOS AVSpeechSynthesizer is on-device by default, so 'force offline' on iOS is a non-problem — the risk is Android routing to network voices
THEIR DETAIL: AVSpeechSynthesizer synthesizes locally; there is no network-voice tier to defend against on iOS (Personal Voice included — generated and synthesized on device). Android is where the exposure is: Google's TTS engine historically ships network-backed voice variants, and a voice with isNetworkConnectionRequired()==true will attempt a server round-trip. This is why the Android-side filter above is mandatory rather than optional. flutter_tts open issue #429 ('setProgressHandler seems to be inaccurate for voices that are network') and #136 ('Audio playing doesn't work when Internet goes off') are direct evidence that users do land on network voices by accident.
THEIR CLAIMED SOURCES: https://developer.apple.com/videos/play/wwdc2023/10033/, https://github.com/dlutton/flutter_tts, https://developer.android.com/reference/android/speech/tts/Voice
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
