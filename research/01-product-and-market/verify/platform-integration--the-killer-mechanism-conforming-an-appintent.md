# platform-integration--the-killer-mechanism-conforming-an-appintent

> Phase: **verify** · Agent `a75e073d56568104f` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Conforming an AppIntent to AudioPlaybackIntent (or LiveActivityIntent, ForegroundContinuableIntent, or PushToTalkTransmissionIntent) does make the system run the intent in the app's process rather than the widget extension, and no openAppWhenRun is needed — this is confirmed verbatim in Apple's WidgetKit "Adding interactivity to widgets and Live Activities" doc (not on the AudioPlaybackIntent page, which the researcher miscited and which says nothing about processes). The target-membership gotcha (both targets; Simulator hides the failure) is confirmed in Apple Forums thread 736445. However, the "speaks instantly" framing is wrong: because the intent runs in the app's process, iOS must cold-launch the app when it isn't already running, which Apple Forums thread 761677 reports as "several seconds" — a diagnosis an Apple DTS engineer endorsed by pointing to launch-time optimization rather than any bug. For a Flutter AAC app whose core scenario is a non-resident app tapped mid-shutdown, this is the normal path, and Flutter engine boot makes it worse. The widget tile is a fast-path only when the app is already resident; it is not a reliable instant-speech mechanism from cold, and the speech path would have to be pure Swift (App Group-shared phrases, AVSpeechSynthesizer) to avoid Dart startup entirely.

**Evidence:** I tried to break this claim and mostly failed — the core mechanism is real and verbatim-accurate. But two specifics are wrong, one of them product-critical.

WHAT SURVIVES (confirmed against primary source):
Apple's WidgetKit doc "Adding interactivity to widgets and Live Activities" states verbatim: "By default, the system runs the app intent in the same process as the widget extension. However, if the app intent's `openAppWhenRun` property is `true`, or if the intent conforms to `AudioPlaybackIntent`, `ForegroundContinuableIntent`, `LiveActivityIntent`, or `PushToTalkTransmissionIntent`, the system performs the app intent in the app's process." And: "If you adopt the LiveActivityIntent or AudioPlaybackIntent protocol, the system runs the app intent in the app's process. Make sure to add your custom app intent to your app target." So the mechanism, the no-openAppWhenRun point, and background launch all hold. Not deprecated or changed as of iOS 26 — I found no release-note change.

The target-membership gotcha is confirmed near-verbatim in Apple Forums thread 736445 (riceay13, Oct '23): "make sure that your widget code has target membership for your widget extension AND your iOS app. This is required otherwise the background audio capability doesn't work. What's frustrating is it works on the simulator even if the iOS app isn't included in the target membership. If you run on a real device you'll get the error." The OP's original blocker (AVAudioSession error 561015905) was resolved by AudioPlaybackIntent. Marco Arment's reported failure (error 560557684) is the same root cause, not a separate limitation.

ERROR 1 — MISATTRIBUTED QUOTE (minor, but it's the load-bearing citation):
The "runs the app intent in the app's process" quote is NOT on https://developer.apple.com/documentation/appintents/audioplaybackintent, which the researcher cites for it. That page says only: "An App Intent that plays, pauses, or otherwise modifies audio playback state when it executes" (abstract) and "Adopt this protocol to indicate to the system that your App Intent plays audio. The system can then avoid dialogue or other experiences that might interrupt that audio." (overview) — nothing about processes. The quote lives on the WidgetKit page. Also, Apple's list includes ForegroundContinuableIntent as running in the app's process, so framing it as merely "the third option that brings the app to foreground" is off (Zach Waugh's separate point — that it's unavailable in widgets and needs @available(iOSApplicationExtension, unavailable) — does stand).

ERROR 2 — "INSTANTLY" IS REFUTED (this is the one that matters):
The claim's whole value rests on instant speech. Apple Forums thread 761677 reports that with AudioPlaybackIntent from a widget, response is "significantly slow when the app is not launched — taking several seconds," working fine only when the app is already running/backgrounded. Apple DTS engineer Ed Ford did NOT dispute this; he treated cold app launch as the root cause and pointed to launch-time optimization: "The work you do to optimize your app launch time will then pay benefits when you are launched through an intent." Running "in the app's process" means the app must be cold-launched if not resident — which for this AAC product is the normal case (someone mid-shutdown in a shop or ER, app not running).

FLUTTER COMPOUNDS THIS (unaddressed by the claim):
Cold launch here means booting the Flutter engine + Dart VM on top of app init — strictly worse than the native several-second case DTS was discussing. Mitigation: implement the tile speech path entirely in Swift (AVSpeechSynthesizer + phrases via App Group), never touching Dart — but then this feature is native iOS work, not Flutter, and Android needs a wholly separate implementation. flutter_app_intents (pub.dev, v0.7.0, last published ~9 months ago) does NOT support AudioPlaybackIntent or widget-triggered intents; it covers Siri/Shortcuts voice commands and explicitly notes intents "run outside your Flutter app's UI context."

BOTTOM LINE FOR THE PRODUCT DECISION: The mechanism is real and worth building, but do not treat the widget tile as the instant-speech path. It is reliable and fast only when the app is already resident; cold, it is a multi-second wait — the exact scenario the product promises to serve. Keep the open-app grid as the primary path, treat the widget as a convenience, and prototype cold-launch-to-audible latency on a real device (not Simulator — it hides both the target-membership bug and the launch cost) before committing.

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

CLAIM: THE KILLER MECHANISM: conforming an AppIntent to AudioPlaybackIntent (or LiveActivityIntent) makes the system run the intent in the main app's process, not the widget extension — enabling a Home Screen widget tile to speak a phrase without opening the app
THEIR DETAIL: Apple: 'if you adopt the LiveActivityIntent or AudioPlaybackIntent protocol, the system runs the app intent in the app's process.' AudioPlaybackIntent is documented as 'an App Intent that plays, pauses, or otherwise modifies audio playback state when it executes.' No openAppWhenRun needed — the app is background-launched. Combined with UIBackgroundModes:audio + AVAudioSession .playback + AVSpeechSynthesizer, a tap on a widget tile speaks aloud with the app never coming to foreground. Gotcha confirmed by multiple devs: the shared code must have target membership in BOTH the widget extension AND the app target, or it works in Simulator but fails on device. ForegroundContinuableIntent is the third option but it's unavailable in widgets (needs @available(iOSApplicationExtension, unavailable)) and brings the app to foreground.
THEIR CLAIMED SOURCES: https://developer.apple.com/documentation/appintents/audioplaybackintent, https://zachwaugh.com/posts/forcing-appintent-to-run-in-main-app-process, https://defn.io/2025/04/13/performing-widget-intents-in-ios-app/, https://developer.apple.com/forums/thread/736445
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
