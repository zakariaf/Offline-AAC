# flutter-tts

> Phase: **research** · Agent `a82a6ae632d2f7c60` · Run `wf_3a8e3c64-43a`

## Result

## Summary

Offline TTS in Flutter is feasible and the MVP is buildable on flutter_tts 4.2.5 — but the package is a single-maintainer project with 212 open issues and a 7-month commit gap, and it has ZERO Personal Voice support, which is the single most product-defining gap. The good news: Apple explicitly designed Personal Voice (iOS 17+) for AAC apps, it needs no entitlement, and it synthesizes fully on-device. The bad news: Personal Voice cannot be written to a file or buffer ("Cannot use AVSpeechSynthesizerBufferCallback with Personal Voices"), so it cannot be pre-rendered and does not work backgrounded — it is live-foreground-playback only. The pre-render-tiles-to-audio-files idea is sound and I recommend it: it defeats the well-documented iOS 16+ first-utterance delay (0.6-1s+) and gives true zero-latency playback, but it works only for system voices, creating a hard architectural fork between "cached system voice" and "live Personal Voice" paths. Two product assumptions are wrong: (1) default iOS voices are Compact quality and sound robotic — Enhanced/Premium are >100MB, must be downloaded manually in Settings, and NO API can trigger or even detect available-but-undownloaded voices; (2) forcing speech to the SPEAKER while earbuds are connected is essentially not achievable on iOS — overrideOutputAudioPort(.speaker) does not override an active Bluetooth route, and defaultToSpeaker only applies to .playAndRecord, not .playback.

### flutter_tts is at 4.2.5 and is a viable MVP base, but carries real bus-factor and maintenance risk

*Confidence: high, **LOAD-BEARING***

Latest 4.2.5, published ~Jan 2026. GitHub dlutton/flutter_tts: 748 stars, 212 open issues, MIT, last push 2026-01-05, not archived. pub.dev: 1,590 likes, 150 pub points, 285k weekly downloads. Effectively single-maintainer (dlutton). Commit history shows a ~7-month dead gap between 2025-06-15 and 2026-01-05, then a burst of merges. Android package was renamed com.tundralabs.fluttertts -> com.eyedeadevelopment.fluttertts in Jan 2026 (source now at android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt) — a signal of maintainer/ownership churn worth watching. Notable open issues: #538 'Any way to buffer the next text?', #619 'Sudden non-deterministic TTS timeouts' (2025-12-22), #408 'Very slow english reading... big delay before reading' (2023, still open), #271 'synthesizeToFile runs really slow on iOS', #323 'After setVoice it takes a while until speaking starts'.

- https://pub.dev/packages/flutter_tts

- https://api.github.com/repos/dlutton/flutter_tts

- https://github.com/dlutton/flutter_tts

### flutter_tts has ZERO Personal Voice support — using Personal Voice requires forking the plugin or writing a platform channel

*Confidence: high, **LOAD-BEARING***

I grepped the plugin's iOS source (ios/Classes/SwiftFlutterTtsPlugin.swift) for personal/requestPersonalVoiceAuthorization/voiceTraits/isPersonalVoice — no matches. A GitHub issue search for 'personal voice' on the repo returns 1 result, and it is an unrelated 2020 issue about Linux/Windows desktop support. The plugin DOES surface voice.quality (premium/enhanced/default) in getVoices, so it reads AVSpeechSynthesisVoice, but never calls the authorization API and never exposes voiceTraits. Since Personal Voice only appears in speechVoices() AFTER requestPersonalVoiceAuthorization succeeds, an unmodified flutter_tts app will never see a Personal Voice at all.

- https://github.com/dlutton/flutter_tts

- https://raw.githubusercontent.com/dlutton/flutter_tts/master/ios/Classes/SwiftFlutterTtsPlugin.swift

### Personal Voice IS usable by third-party AAC apps, works fully offline, and needs no entitlement or Apple approval — Apple named AAC as its intended use case

*Confidence: high, **LOAD-BEARING***

iOS 17+. Flow: AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in ... }, then voices appear in AVSpeechSynthesisVoice.speechVoices() carrying the .isPersonalVoice trait (filter via $0.voiceTraits). WWDC23-10033: 'Your Personal Voice is generated on the device and not on a server' and 'usage of Personal Voice is sensitive and should be primarily used for augmentative or alternative communication apps' — the session literally demos an AAC app. Per Ben Dodson's implementation writeup, NO special entitlement and NO Info.plist key are required, and no approval beyond standard app review. Constraints: user must first record Personal Voice (~150 prompts, ~15 min) and processing takes 3+ hours plugged in and idle; user must enable Settings > Accessibility > Personal Voice > 'Allow Apps to Request to Use'; users can revoke anytime; there is NO openSettingsURLString deep link to the Personal Voice panel, so you cannot send the user straight to the toggle; older-but-supported devices return .denied rather than .unsupported, so you cannot cleanly explain failure.

- https://developer.apple.com/videos/play/wwdc2023/10033/

- https://wwdcnotes.com/documentation/wwdc23-10033-extend-speech-synthesis-with-personal-and-custom-voices/

- https://bendodson.com/weblog/2024/04/03/using-your-personal-voice-in-an-ios-app/

- https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/personalvoiceauthorizationstatus-swift.type.property

### Personal Voice CANNOT be pre-rendered to a file and CANNOT speak in the background — this is a documented, by-design limitation with no workaround

*Confidence: high, **LOAD-BEARING***

Attempting writeUtterance:toBufferCallback with a Personal Voice yields the runtime message: 'Cannot use AVSpeechSynthesizerBufferCallback with Personal Voices, defaulting to output channel.' Standard system voices work fine with buffer callbacks. Apple Developer Forums thread 736148 confirms this also blocks background playback for Personal Voice specifically, with multiple developers reproducing and no Apple workaround offered. This directly collides with the pre-render caching strategy: flutter_tts's synthesizeToFile on iOS is implemented with AVSpeechSynthesizer.write() into an AVAudioFile (SwiftFlutterTtsPlugin.swift line ~170), i.e. exactly the buffer-callback path Personal Voice rejects. So: pre-rendered tile cache = system voices only; Personal Voice = live, foreground, uncached only.

- https://developer.apple.com/forums/thread/736148

- https://raw.githubusercontent.com/dlutton/flutter_tts/master/ios/Classes/SwiftFlutterTtsPlugin.swift

### iOS default voices are Compact (robotic); Enhanced/Premium are >100MB manual downloads and NO API can trigger or discover them

*Confidence: high, **LOAD-BEARING***

AVSpeechSynthesisVoiceQuality has three tiers: .default (Compact), .enhanced, .premium. Enhanced and premium 'must be downloaded to use' and each exceed ~100MB. Users download them manually via Settings > Accessibility > Spoken Content > Voices (also reachable via Live Speech > Voices). Apple Developer Forums thread 758460 confirms there is NO API to enumerate voices that are available-for-download-but-not-installed; speechVoices() returns only what is already on device. Therefore the app cannot trigger a download and cannot even tell the user 'a better voice exists'. What you CAN do: flutter_tts's iOS getVoices returns a 'quality' key mapping to premium/enhanced/default, so you can detect that the user is stuck on a Compact voice and show hand-written instructions to go download a better one. This is a first-run onboarding problem, and it lands squarely on the project's stated #1 risk that 'TTS must sound acceptable'.

- https://developer.apple.com/documentation/avfaudio/avspeechsynthesisvoicequality

- https://developer.apple.com/forums/thread/758460

- https://bendodson.com/weblog/2024/04/03/using-your-personal-voice-in-an-ios-app/

### On Android you CAN reliably force offline-only, and flutter_tts already surfaces the needed fields — no fork required

*Confidence: high, **LOAD-BEARING***

The Voice class exposes isNetworkConnectionRequired(), getFeatures(), getQuality(), getLatency(). Feature keys: KEY_FEATURE_NOT_INSTALLED, KEY_FEATURE_EMBEDDED_SYNTHESIS (engine must synthesize on-device with no network requests), KEY_FEATURE_NETWORK_SYNTHESIS, KEY_FEATURE_NETWORK_TIMEOUT_MS, KEY_FEATURE_NETWORK_RETRIES_COUNT. Verified in flutter_tts's Kotlin source (FlutterTtsPlugin.kt ~line 621): getVoices returns per-voice map keys 'quality', 'latency', 'network_required' ('1'/'0' string), and 'features' (tab-joined string). So in Dart you filter to voices where network_required == '0' and features does NOT contain KEY_FEATURE_NOT_INSTALLED. The plugin's own isLanguageAvailable check already does `if (v.locale == locale && !v.isNetworkConnectionRequired)` (line 484). Engine selection via getEngines/setEngine/getDefaultEngine (Android-only) lets you prefer Google TTS vs Samsung TTS. Belt-and-braces: ship with no INTERNET permission at all in AndroidManifest — this makes 'nothing leaves device' provable and is a strong trust/marketing claim for this audience.

- https://developer.android.com/reference/android/speech/tts/Voice

- https://developer.android.com/reference/android/speech/tts/TextToSpeech

- https://raw.githubusercontent.com/dlutton/flutter_tts/master/android/src/main/kotlin/com/eyedeadevelopment/fluttertts/FlutterTtsPlugin.kt

### iOS AVSpeechSynthesizer is on-device by default, so 'force offline' on iOS is a non-problem — the risk is Android routing to network voices

*Confidence: high, **LOAD-BEARING***

AVSpeechSynthesizer synthesizes locally; there is no network-voice tier to defend against on iOS (Personal Voice included — generated and synthesized on device). Android is where the exposure is: Google's TTS engine historically ships network-backed voice variants, and a voice with isNetworkConnectionRequired()==true will attempt a server round-trip. This is why the Android-side filter above is mandatory rather than optional. flutter_tts open issue #429 ('setProgressHandler seems to be inaccurate for voices that are network') and #136 ('Audio playing doesn't work when Internet goes off') are direct evidence that users do land on network voices by accident.

- https://developer.apple.com/videos/play/wwdc2023/10033/

- https://github.com/dlutton/flutter_tts

- https://developer.android.com/reference/android/speech/tts/Voice

### 'Instant' is NOT achievable with live TTS on iOS — there is a documented 0.6-1s+ first-utterance delay — but pre-rendering to cached audio files solves it

*Confidence: high, **LOAD-BEARING***

Apple Developer Forums thread 715339 documents that since iOS 16, the gap between speak(utterance) and the didStart delegate callback runs 0.6s to >1s, and is caused by loading per-language pronunciation rule data from disk: English ~862KB / ~0.25s, Italian ~536KB / ~0.7s, German ~4.4MB / ~3+s. Console shows '[AXTTSCommon] Invalid rule:'. Apple requested sysdiagnose then went quiet; unresolved. Mitigations: (a) instantiate AVSpeechSynthesizer at app launch and keep it alive as a singleton — never construct per tap; (b) pre-activate the AVAudioSession at launch, not at first tap; (c) fire a warm-up utterance of ' ' at volume 0 on launch to force the rule data load. Rule-data load is a first-utterance-per-language cost, not per-tap. Note the delay is far worse for German than English, so this is a localization risk, not just a launch risk.

- https://developer.apple.com/forums/thread/715339

- https://github.com/dlutton/flutter_tts

### The pre-render-tiles-to-audio-at-edit-time idea is sound and I recommend it as the primary path for tiles — with a Personal Voice carve-out

*Confidence: medium, **LOAD-BEARING***

flutter_tts exposes synthesizeToFile (iOS 13+ and Android) plus awaitSynthCompletion (iOS). At tile edit/save time, synthesize the phrase to a local file; at tap time, play the cached file via just_audio/audioplayers. Benefits: genuinely ~0ms time-to-first-audio (file already decoded/warm), bypasses the iOS 16 rule-load delay entirely, and removes the nondeterministic-timeout class of bug (open issue #619). Costs and caveats: (1) does NOT work for Personal Voice (buffer callback blocked) — those tiles must fall back to live speak(); (2) the whole cache must be invalidated and re-rendered whenever the user changes voice, rate, or pitch — treat rate/pitch as cache-key inputs; (3) flutter_tts open issue #271 says synthesizeToFile is slow on iOS and #240 says it ignores the provided path — so budget debugging time and do the render off the interaction path (on save, with a progress indicator); (4) the free-typed 'type to speak' box can never be pre-rendered and must use live TTS, so you still need the warm-up work regardless. Recommend: cached-file path for tiles, warm live path for typing.

- https://pub.dev/packages/flutter_tts

- https://github.com/dlutton/flutter_tts

- https://developer.apple.com/forums/thread/736148

### TTS through the silent switch works — but ONLY if you set AVAudioSession category to .playback, which flutter_tts supports

*Confidence: high, **LOAD-BEARING***

AVAudioSession .ambient respects the silent switch and will mute your speech — catastrophic for an AAC user who does not realize their phone is on silent. .playback ignores the silent switch and plays anyway. This is the correct category for AAC: speech is the app's primary, essential function. flutter_tts exposes setIosAudioCategory(category, options, mode) and setSharedInstance(bool) — verified in SwiftFlutterTtsPlugin.swift (setAudioCategory at ~line 289, setSharedInstance at ~line 280), backed by AudioCategory.swift / AudioCategoryOptions.swift / AudioModes.swift enums. Config: category .playback, options [.duckOthers] (or .interruptSpokenAudioAndMixWithOthers so podcasts/audiobooks pause rather than merely dip), and call setSharedInstance(true). The plugin's shouldDeactivateAndNotifyOthers() already inspects .duckOthers / .interruptSpokenAudioAndMixWithOthers to decide whether to deactivate and notify others after speaking, so ducking-then-restoring music is handled.

- https://developer.apple.com/documentation/avfaudio/avaudiosession/category-swift.struct/ambient?language=objc

- https://developer.apple.com/forums/thread/703799

- https://raw.githubusercontent.com/dlutton/flutter_tts/master/ios/Classes/SwiftFlutterTtsPlugin.swift

### Forcing speech out of the SPEAKER while the user has earbuds connected is essentially NOT achievable on iOS — this product requirement must be rethought

*Confidence: medium, **LOAD-BEARING***

The brief states 'user in a shop with earbuds in must have speech come out the SPEAKER'. iOS fights this hard: (1) AVAudioSession.CategoryOptions.defaultToSpeaker is only applicable to the .playAndRecord category — it is ignored under .playback, which is the category you need for silent-switch bypass; so you cannot have both trivially. (2) overrideOutputAudioPort(.speaker) does not win against a connected Bluetooth device — when BT is connected the system keeps routing to it; the override reliably works only when no BT route is active. (3) Adopting .playAndRecord to get defaultToSpeaker forces a microphone-permission prompt, which is actively hostile for a privacy-first, no-account AAC app and undermines the 'nothing leaves device' promise. Android is more tractable — you can set AudioAttributes usage (the plugin already has setAudioAttributesForNavigation using USAGE_ASSISTANCE_NAVIGATION_GUIDANCE) and have more routing latitude — but iOS is the blocker. Realistic answer: detect the active output route and, when it is not the built-in speaker, show a clear persistent UI warning ('Audio will play in your earbuds') plus a one-tap route control, rather than promising a silent automatic override you cannot deliver.

- https://developer.apple.com/forums/thread/62954

- https://medium.com/simform-engineering/audio-input-device-switch-management-in-avaudiosession-4a7c4dd78eb5

- https://github.com/livekit/client-sdk-flutter/issues/725

### sherpa_onnx is a genuinely viable Flutter neural-TTS fallback in 2026, permissively licensed, at roughly +55MB app size

*Confidence: medium*

pub.dev sherpa_onnx v1.13.4, published ~July 2026 (7 days before research date), Apache-2.0, 116 likes, 150 pub points, 28.4k weekly downloads. Caveat: listed as published by an unverified uploader (upstream is k2-fsa/sherpa-onnx, a well-established project). Platforms: Android, iOS, Windows, macOS, Linux, HarmonyOS across x64/x86/arm64/arm32/riscv64. TTS models supported: Piper, VITS, Matcha, Kokoro-82M, ZipVoice. Size: ~25MB native runtime + ~30MB Piper voice = ~55MB one-time install footprint; can be reduced by downloading models in-app, but that contradicts the zero-network premise, so bundle it. Licensing: Kokoro-82M is Apache-2.0 with no commercial restrictions; Piper engine is MIT BUT individual voice models are a mix and some were trained on datasets with their own terms — you must audit the specific voice you ship. Quality in 2026 is reported at or above stock Google voices, and Kokoro-82M is described as running well even on modest hardware (e.g. Helio G99). Tradeoffs: higher battery draw, thermal load on long sessions, and worse latency on low-end phones — all of which argue for combining sherpa_onnx with the pre-render-to-file strategy, where its slower synthesis is hidden at edit time and playback is a cached file.

- https://pub.dev/packages/sherpa_onnx

- https://github.com/k2-fsa/sherpa-onnx

- https://huggingface.co/hexgrad/Kokoro-82M

- https://www.promptquorum.com/power-local-llm/local-tts-voice-cloning-piper-coqui-xtts

- https://speechcentral.net/2026/04/01/android-ai-system-voices-the-rise-of-offline-tts-on-mobile/

### Android offline voice quality in 2026 is acceptable from stock Google TTS and good from neural engines, so Android is the lower-risk platform for the 'sounds acceptable' test

*Confidence: medium*

Stock Google TTS offline voices are serviceable but open-source neural engines (Piper/Kokoro via sherpa-onnx) are reported to 'sound more natural, more expressive and more pleasant' than many stock Google voices. VoxSherpa (open source, on Google Play) now installs Piper neural voices as system-level Android TTS voices — meaning some users will already have good neural voices exposed through the standard TextToSpeech engine list, reachable via getEngines/setEngine. Android's advantage over iOS here is real: Android exposes engine selection and per-voice quality/latency metadata, whereas iOS gives you a Compact voice you cannot upgrade programmatically.

- https://speechcentral.net/2026/05/03/android-piper-tts-voxsherpa-brings-offline-neural-voices-to-system-text-to-speech/

- https://speechcentral.net/2026/04/01/android-ai-system-voices-the-rise-of-offline-tts-on-mobile/

- https://developer.android.com/reference/android/speech/tts/TextToSpeech

### Background/lock-screen speaking is possible for system voices but not for Personal Voice

*Confidence: medium*

For system voices, background audio works with UIBackgroundModes 'audio' in Info.plist plus an active .playback AVAudioSession. For Personal Voice, Apple Developer Forums thread 736148 documents that background use fails with the same buffer-callback restriction. Product judgment: for this use case (tap a tile, phone speaks, user is looking at the screen mid-shutdown), background speaking is a marginal requirement and should not be allowed to drive architecture. Do not spend MVP budget here.

- https://developer.apple.com/forums/thread/736148

- https://developer.apple.com/forums/thread/714984

## Product implications

- **[must-have-mvp]** Build the MVP on flutter_tts 4.2.5 — it clears the MVP bar on both platforms. Do not start with a custom platform channel.
  - It already exposes everything the stated MVP needs: getVoices with quality/latency/network_required/features, setIosAudioCategory + setSharedInstance for silent-switch bypass and ducking, engine selection on Android, and synthesizeToFile on both. 285k weekly downloads and MIT licensing. The maintenance risk (212 open issues, single maintainer, 7-month gap) is real but is a fork-later risk, not a start-elsewhere risk — MIT means you can vendor it the day it breaks.
- **[must-have-mvp]** Set AVAudioSession to .playback with .duckOthers and call setSharedInstance(true) at launch. Never use .ambient.
  - Under .ambient, the phone's silent switch mutes the app — an AAC user mid-shutdown would tap a tile and produce nothing, which is the worst possible failure for this product. .playback ignores the silent switch. This is a one-line config decision with disproportionate stakes.
- **[must-have-mvp]** On Android, filter getVoices to network_required=='0' and reject voices whose features contain KEY_FEATURE_NOT_INSTALLED. Ship with NO INTERNET permission in AndroidManifest.
  - Android is the only platform that can silently route to Google's servers; iOS is on-device by default. Open issues #136 and #429 prove real users land on network voices accidentally. Omitting INTERNET entirely converts 'nothing leaves device' from a marketing claim into a machine-verifiable guarantee — which for an audience that is privacy-sensitive and distrustful of infantilizing mainstream apps is a genuine differentiator, not a checkbox.
- **[must-have-mvp]** Instantiate the synthesizer and activate the audio session at app launch, and fire a silent warm-up utterance. Never construct AVSpeechSynthesizer per tap.
  - The documented iOS 16+ 0.6-1s first-utterance delay comes from per-language rule-data disk loading (~0.25s for English, 3+s for German). It is a once-per-language cost that can be paid at launch instead of at the moment of distress. This is cheap to implement and directly serves the 'must speak instantly' requirement.
- **[must-have-mvp]** Detect the installed voice's quality tier on iOS and run a first-launch voice-quality onboarding that walks the user to Settings > Accessibility > Spoken Content > Voices.
  - Default iOS voices are Compact and sound robotic; Enhanced/Premium are >100MB manual downloads, and there is NO API to trigger the download or even list undownloaded voices. flutter_tts does return a 'quality' key, so you can at least detect the bad state. Since 'TTS must sound acceptable' is the project's own #1 risk, and the platform gives you no programmatic lever, onboarding copy IS the mitigation. Note you also cannot deep-link to this settings panel, so the instructions must be written and illustrated carefully.
- **[should-have-v1]** Pre-render tile phrases to cached audio files at edit/save time and play the file on tap; use live TTS only for the type-to-speak box.
  - This is the single best answer to 'instant' — it bypasses the iOS rule-load delay and the nondeterministic-timeout bug class (#619) entirely. But sequence it after the MVP: synthesizeToFile has known iOS bugs (#271 slow, #240 ignores path), and the cache must be keyed on voice+rate+pitch and invalidated on any change. Get the simple live path working first, then layer caching in once you can measure the real latency on device.
- **[should-have-v1]** Treat Personal Voice as the headline differentiator for iOS 17+ — and budget for forking flutter_tts or writing a thin platform channel to get it.
  - Apple explicitly built this for AAC apps, it needs no entitlement or special approval, and it runs fully on-device — it is exactly aligned with 'dignified' and 'nothing leaves device'. For a user with degenerative speech loss or who is intermittently non-speaking, hearing their OWN voice is a categorically different product than hearing Siri. flutter_tts cannot do it today (zero support, confirmed by source inspection), so this requires ~1 platform-channel method (requestPersonalVoiceAuthorization) plus surfacing voiceTraits. That is a small, well-bounded native patch for a very large product payoff.
- **[should-have-v1]** Architect the audio layer with two explicit paths from day one: cached-file playback (system voices) and live-only playback (Personal Voice).
  - Personal Voice cannot be written to a file or buffer ('Cannot use AVSpeechSynthesizerBufferCallback with Personal Voices') and cannot speak in the background. If you build the pre-render cache assuming it works for all voices, adding Personal Voice later forces a painful refactor. Knowing this now makes it a clean interface boundary instead of a rewrite.
- **[explicitly-avoid]** Drop the 'always force audio to the speaker even with earbuds in' requirement. Replace it with route detection plus a visible warning and a one-tap route control.
  - iOS makes this effectively impossible: defaultToSpeaker only applies to .playAndRecord (not the .playback you need for silent-switch bypass), and overrideOutputAudioPort(.speaker) loses to an active Bluetooth route. The only path to defaultToSpeaker is adopting .playAndRecord, which triggers a microphone permission prompt — actively corrosive to a no-account, privacy-first AAC app. Honest UI ('Audio will play in your earbuds' + tap to change) is achievable and more trustworthy than a promise the OS will silently break in exactly the high-stakes moment the feature exists for.
- **[nice-to-have-later]** Keep sherpa_onnx (Kokoro-82M) as a v2 escape hatch if OS voice quality tests poorly with real users — do not bundle it in the MVP.
  - It is genuinely viable in 2026: v1.13.4, Apache-2.0, active, 28.4k weekly downloads, and Kokoro-82M is Apache-2.0 with no commercial restrictions. But it costs ~55MB install, more battery, and thermal load — and it pairs best with the pre-render strategy, which itself is v1. Ship OS voices first and let real user feedback decide whether the 55MB is warranted. If you do ship Piper voices, audit each voice's individual license: the MIT engine license does not cover the voice models.
- **[explicitly-avoid]** Do not build background or lock-screen speaking for the MVP.
  - It is blocked for Personal Voice regardless, and the core use case (tap a tile while looking at the phone mid-shutdown) does not need it. Spending MVP budget here buys nothing for the target user and adds an audio-session edge case surface.

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


YOUR DIMENSION: Flutter + offline TTS technical feasibility. This is the #1 technical risk.

Research using WebSearch and WebFetch (pub.dev, GitHub issues, Flutter docs, Apple docs, Android docs, Stack Overflow).

Answer specifically for 2026:
- flutter_tts package: current version, maintenance status, open issue count, known bugs. Does it support offline/on-device voices? How do you FORCE offline-only and guarantee no network call? (AVSpeechSynthesizer is on-device by default; Android TextToSpeech may route to Google's servers for some voices — verify, and find how to check/require KEY_FEATURE_NOT_INSTALLED / isNetworkTts / EngineInfo)
- On iOS: AVSpeechSynthesizer — voice quality tiers (Compact / Enhanced / Premium), how a user downloads Enhanced/Premium voices, can an app trigger that download or prompt? What are Personal Voice (iOS 17+) and can a third-party app use it? (AVSpeechSynthesisProviderVoice / Personal Voice authorization API) Is Personal Voice usable offline by a 3rd party app? THIS IS A BIG DEAL for this product — verify carefully.
- On Android: Google TTS engine vs Samsung TTS vs others. How to enumerate voices, check offline availability, force offline. Quality of Android offline voices in 2026.
- Latency: what is realistic time-to-first-audio for on-device TTS on iOS and Android? Is "instant" achievable? Any warm-up trick (pre-synthesizing to a file/buffer)? Can you pre-render tile phrases to audio files at edit time and just play a cached file for zero latency? Evaluate this idea.
- Alternatives if flutter_tts is inadequate: writing a thin platform channel to AVSpeechSynthesizer/Android TextToSpeech directly; bundling a neural TTS (Piper, Sherpa-ONNX, Coqui, Kokoro) — is on-device neural TTS via sherpa_onnx viable in Flutter in 2026? App size cost? Licensing? Quality vs OS voices? Which packages exist (e.g. sherpa_onnx Flutter bindings)?
- Audio session config: does the app duck other audio? Play through silent switch? Route to speaker vs bluetooth? Interruption handling? This matters — user in a shop with earbuds in must have speech come out the SPEAKER.
- Does TTS work when device is on silent/mute? (iOS AVAudioSession category .playback vs .ambient)
- Background/lock screen speaking?

Be brutally specific with package names, versions, API names, and known pitfalls.
````

</details>
