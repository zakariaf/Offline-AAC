# platform-integration--app-store-review-risk-audioplaybackintent-is

> Phase: **verify** · Agent `a89b0ec9236b356f7` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** AudioPlaybackIntent's normative Overview defines a functional criterion — "Adopt this protocol to indicate to the system that your App Intent plays audio" — which TTS satisfies, so an AAC app adopting it for speech output is defensibly on-label, not off-label. Apple's docs do curate it under "Media actions" and WidgetKit frames it as "starts or pauses media playback," so a media association exists, but that is docs navigation and non-binding phrasing rather than an app-category restriction (its bucket-mate CameraCaptureIntent is routinely used by non-media apps). No App Store rejection precedent exists for this pattern; AudioPlaybackIntent is a protocol conformance, not an entitlement or background mode, so there is no review gate — real audio rejections under 2.5.4 concern UIBackgroundModes audio, a different mechanism, and guidelines 2.5.1/2.5.11 are satisfied since speaking aloud IS an AAC app's stated function. Process-hosting in the app's process is explicitly documented behavior for AudioPlaybackIntent, not an exploit. Critically, the recommended mitigation is wrong: openAppWhenRun is deprecated and "generates an error if the app intent runs in an app extension" — use supportedModes: IntentModes (.background / .foreground(.immediate|.dynamic|.deferred)) instead. Finally, this risk applies only to optional widget/Control Center/Siri surfaces; the MVP's in-app tile-tap-to-speak needs no App Intent at all and carries no such risk.

**Evidence:** The "media" framing has partial doc support, but the load-bearing conclusion (off-label → rejection risk) is unsubstantiated, and the mitigation names a DEPRECATED API that errors in extensions.

WHAT SURVIVES (the directional core):
Apple's docs do curate AudioPlaybackIntent under a "Media actions" section, alongside AudioRecordingIntent, CameraCaptureIntent, PlayVideoIntent, VideoCategory. And WidgetKit's guidance says verbatim: "If the interaction starts or pauses media playback, adopt the AudioPlaybackIntent protocol." So a media association genuinely exists in the docs. The researcher did not invent it.

WHAT IS REFUTED:

1. "Apple's framing is media transport controls (play/pause)" — MISREAD. That is the one-line ABSTRACT. The protocol's normative Overview states: "Adopt this protocol to indicate to the system that your App Intent plays audio. The system can then avoid dialogue or other experiences that might interrupt that audio." The adoption criterion Apple actually states is FUNCTIONAL (does your intent play audio?), not CATEGORICAL (are you a media app?). AVSpeechSynthesizer plays audio through AVAudioSession, so an AAC intent satisfies the stated criterion literally. The benefit the protocol buys — the system not interrupting your audio with dialogs — is precisely what an AAC app wants. NOTE: developer.apple.com is JS-rendered and returns an empty body to plain fetches; the researcher likely hit that wall and reasoned from the abstract alone. I retrieved the Overview via the docs JSON API.

2. "Media actions" is a docs-nav bucket, not a normative gate. Its bucket-mates disprove the category reading: CameraCaptureIntent is used by any app that takes a photo (banking check deposit, ID scan), not only media apps. Grouping ≠ restriction.

3. "A real but unquantified rejection risk" — UNSUBSTANTIATED; I found ZERO rejection precedent. Structural reasons it is near-zero:
   - AudioPlaybackIntent is a protocol conformance — not an entitlement, not a restricted API, not a background mode. There is no gate for App Review to trip.
   - The nearest real guidelines are 2.5.1 ("Apps should use APIs and frameworks for their intended purposes") and 2.5.11 (SiriKit/Shortcuts: sign up only for intents "that users would expect from the stated functionality"). An AAC app passes both trivially — its stated function IS "tap tile → phone speaks aloud." 2.5.11's own misuse example is CROSS-DOMAIN (a meal-planning app registering a start-workout intent). An AAC app playing audio is same-domain.
   - Real-world audio rejections (guideline 2.5.4) concern UIBackgroundModes audio — a DIFFERENT mechanism the researcher conflated with this one.
   - Precedent cuts the other way: Speech Aid (AAC, App Store) already ships home + lock screen widgets for speaking saved phrases.

4. "Apple could tighten process-hosting rules" — process-hosting is DOCUMENTED, sanctioned behavior, not an exploit. WidgetKit, verbatim: "By default, the system runs the app intent in the same process as the widget extension. However, if the app intent's openAppWhenRun property is true, or if the intent conforms to AudioPlaybackIntent, ForegroundContinuableIntent, LiveActivityIntent, or PushToTalkTransmissionIntent, the system performs the app intent in the app's process."

5. THE MITIGATION IS BROKEN (most actionable error). openAppWhenRun is DEPRECATED. Apple, verbatim: "This property is deprecated. Use supportedModes instead. Setting this property to true generates an error if the app intent runs in an app extension." So the recommended fallback is both outdated AND errors inside a widget extension — exactly where it would be needed. Correct modern API: static var supportedModes: IntentModes = .background (or .foreground(.immediate/.dynamic/.deferred), or a combination).

6. SCOPE CORRECTION (largest practical point): this risk touches ONLY optional widget / Control Center / Siri surfaces. The MVP core — tap a tile in the open app, phone speaks — needs no App Intent at all, just AVSpeechSynthesizer in the foreground app. This is not a decision-blocking risk for the MVP and should not gate the Flutter/stack decision.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "platform-integration". A product decision depends on it, so it must be right.

CLAIM: App Store review risk: AudioPlaybackIntent is semantically intended for media playback apps, and an AAC app using it to trigger TTS is off-label
THEIR DETAIL: Apple's framing is media transport controls (play/pause). No documentation found sanctioning or forbidding TTS use. This is a real but unquantified rejection risk, and Apple could tighten process-hosting rules in a future iOS. Mitigation: AAC is a first-class accessibility category Apple actively courts (see Personal Voice guidance), so an appeal has a strong story. Recommend building a fallback path (openAppWhenRun:true) behind a flag.
THEIR CLAIMED SOURCES: https://developer.apple.com/documentation/appintents/audioplaybackintent
THEIR CONFIDENCE: low

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
