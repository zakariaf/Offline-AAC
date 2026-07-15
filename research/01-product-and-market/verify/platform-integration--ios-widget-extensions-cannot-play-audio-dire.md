# platform-integration--ios-widget-extensions-cannot-play-audio-dire

> Phase: **verify** · Agent `a7cd99a3addb5abb7` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** iOS widget extensions cannot activate an AVAudioSession from a plain AppIntent — perform() defaults to the widget extension's process, producing AVAudioSession errors 561015905 ('!pla') / 560557684 ('!int') even with background audio modes enabled. However, this does NOT kill the "widget speaks the phrase" design. Apple explicitly supports it: conforming the intent to AudioPlaybackIntent (iOS 17.0+, same release as interactive widgets) makes the system run perform() in the APP's process, where audio works — this is how Apple Music's own widget behaves. Apple's doc directs developers to it: "If the interaction starts or pauses media playback, adopt the AudioPlaybackIntent protocol." Requirements: adopt AudioPlaybackIntent (or set openAppWhenRun, or conform to ForegroundContinuableIntent/LiveActivityIntent/PushToTalkTransmissionIntent), give the intent target membership in BOTH the app and widget extension targets (omitting this passes in Simulator but fails on device — the actual cause of most reported errors), and enable the Audio background mode. The real blockers for this product are different: (1) Apple gates ALL widget buttons behind device unlock — "On a locked device, buttons and toggles are inactive and the system doesn't perform actions unless a person authenticates and unlocks their device" — which breaks the zero-friction/mid-shutdown requirement and has no workaround; (2) AVSpeechSynthesizer from a backgrounded process has reported reliability inconsistency and needs device testing; (3) AudioPlaybackIntent is semantically intended for media playback state, so one-shot TTS is off-label usage with unverified App Review treatment. Recommend prototyping on a physical device rather than abandoning the design.

**Evidence:** The claim's MECHANISM is confirmed verbatim by Apple, but its CONCLUSION ("kills the naive widget speaks the phrase design") is refuted — by the researcher's own third cited source.

CONFIRMED PORTION. Apple's WidgetKit doc "Adding interactivity to widgets and Live Activities" states: "By default, the system runs the app intent in the same process as the widget extension." Widget code "runs in an independent process that's separate from your app." The error codes are also real: 561015905 decodes to FourCC '!pla' (AVAudioSessionErrorCodeCannotStartPlaying) and 560557684 to '!int' (AVAudioSessionErrorCodeCannotInterruptOthers). Background modes alone do not fix it. So the failure mode described is real and correctly diagnosed.

REFUTED PORTION. The same Apple sentence continues: "However, if the app intent's openAppWhenRun property is true, or if the intent conforms to AudioPlaybackIntent, ForegroundContinuableIntent, LiveActivityIntent, or PushToTalkTransmissionIntent, the system performs the app intent in the app's process." The doc further instructs: "If the interaction starts or pauses media playback, adopt the AudioPlaybackIntent protocol." Apple ships a first-party protocol whose entire purpose is solving exactly this. Verified via Apple's docs JSON API: AudioPlaybackIntent is iOS/iPadOS/tvOS 17.0+, macOS 14.0+, watchOS 10.0+ — the same release that introduced interactive widgets, so there is no version gap. Its abstract: "An App Intent that plays, pauses, or otherwise modifies audio playback state when it executes."

SOURCE MISREAD. All three claimed sources contain the solution; all three were reported as only the problem. Forum thread 736445 RESOLVES with AudioPlaybackIntent plus the requirement that the intent have target membership in BOTH the widget extension and the app target (works in Simulator without this, fails on device — explaining the reported errors). The defn.io post's entire thesis is to "implement the AudioPlaybackIntent instead," which "automatically handles routing execution to the main application process." The researcher appears to have read the opening complaint of the forum thread and not the accepted answer, then rated it "high" confidence.

SECONDARY ERROR. The claim attributes the failure to the widget extension having "no audio session entitlement." The fix is process routing, not entitlements — conforming to the right protocol relocates perform() to the app's process, where the existing session/entitlement applies. The stated causal mechanism is wrong even where the symptom is right.

MATERIAL OMISSION (more damaging to the product than the claim itself). Apple: "On a locked device, buttons and toggles are inactive and the system doesn't perform actions unless a person authenticates and unlocks their device." For an AAC user mid-shutdown reaching for a Lock Screen widget, this Face ID/passcode gate directly contradicts the "zero login, instantly, mid-shutdown" requirement — and unlike process routing, it has NO API workaround. This is the constraint the platform-integration research should have surfaced.

PRACTICAL CAVEAT (fairness to the claim). Reliability of AVSpeechSynthesizer specifically from a backgrounded process is separately reported as inconsistent (Apple forum thread 27097: speech "sometimes plays right away, and other times doesn't play until the app is brought to the foreground" because "the OS seems to sometimes queue the audio and sometimes not"). So while the architecture is supported, TTS-from-widget warrants device prototyping before committing. Note also that AudioPlaybackIntent is semantically framed around media playback state; using it to drive one-shot TTS is off-label and its App Review treatment is unverified.

FLUTTER NOTE: all of this is native Swift regardless. A Flutter app needs a hand-written Swift widget extension plus App Group/shared-container plumbing for phrase data either way; no Flutter plugin abstracts WidgetKit interactivity.

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

CLAIM: iOS widget extensions cannot play audio directly — an AppIntent's perform() runs in the widget extension process by default, which cannot activate an AVAudioSession
THEIR DETAIL: Developers hitting this get AVAudioSession activation errors (status 561015905 / 560557684) from ATAudioSessionClientImpl.mm even with Audio/AirPlay/PiP background modes enabled. Default execution context for a widget Button(intent:) is the widget extension's isolated process, which has no audio session entitlement and no access to app state. This kills the naive 'widget speaks the phrase' design.
THEIR CLAIMED SOURCES: https://developer.apple.com/forums/thread/736445, https://defn.io/2025/04/13/performing-widget-intents-in-ios-app/, https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
