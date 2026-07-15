# platform-integration

> Phase: **research** · Agent `af7a683f0683734e4` · Run `wf_3a8e3c64-43a`

## Result

## Summary

The killer feature is real but narrower than hoped. On iOS, a Home Screen widget button CAN speak a phrase without opening the app — but not because widgets can play audio (they can't; widget extensions cannot activate an AVAudioSession). The mechanism is that conforming an AppIntent to `AudioPlaybackIntent` (or `LiveActivityIntent`) makes the system run `perform()` in the MAIN APP's process, background-launching it if needed, where AVSpeechSynthesizer works normally. That is the single most important technical fact in this dimension. iOS Lock Screen *widgets* are a dead end (not interactive, by design), but iOS 18 *Controls* can replace the Lock Screen flashlight/camera buttons and be bound to the Action Button, both running AppIntents. On Android the story is better and simpler: a Quick Settings tile's `TileService.onClick()` runs arbitrary code without the app open, is reachable from the lock-screen shade, and per Android docs only needs `unlockAndRun()` for *sensitive* actions — speaking a phrase is not sensitive. The big honest risk: iOS Live Speech (triple-click side button → typed/saved phrases, categories, offline, also on Apple Watch via Digital Crown triple-click) already does the core job and is free, on-OS, and gets the triple-click accessibility shortcut that third-party apps cannot have. Personal Voice, however, IS open to third parties and Apple names AAC as its intended use case — that's the strongest wedge against Live Speech.

### iOS widget extensions cannot play audio directly — an AppIntent's perform() runs in the widget extension process by default, which cannot activate an AVAudioSession

*Confidence: high, **LOAD-BEARING***

Developers hitting this get AVAudioSession activation errors (status 561015905 / 560557684) from ATAudioSessionClientImpl.mm even with Audio/AirPlay/PiP background modes enabled. Default execution context for a widget Button(intent:) is the widget extension's isolated process, which has no audio session entitlement and no access to app state. This kills the naive 'widget speaks the phrase' design.

- https://developer.apple.com/forums/thread/736445

- https://defn.io/2025/04/13/performing-widget-intents-in-ios-app/

- https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities

### THE KILLER MECHANISM: conforming an AppIntent to AudioPlaybackIntent (or LiveActivityIntent) makes the system run the intent in the main app's process, not the widget extension — enabling a Home Screen widget tile to speak a phrase without opening the app

*Confidence: high, **LOAD-BEARING***

Apple: 'if you adopt the LiveActivityIntent or AudioPlaybackIntent protocol, the system runs the app intent in the app's process.' AudioPlaybackIntent is documented as 'an App Intent that plays, pauses, or otherwise modifies audio playback state when it executes.' No openAppWhenRun needed — the app is background-launched. Combined with UIBackgroundModes:audio + AVAudioSession .playback + AVSpeechSynthesizer, a tap on a widget tile speaks aloud with the app never coming to foreground. Gotcha confirmed by multiple devs: the shared code must have target membership in BOTH the widget extension AND the app target, or it works in Simulator but fails on device. ForegroundContinuableIntent is the third option but it's unavailable in widgets (needs @available(iOSApplicationExtension, unavailable)) and brings the app to foreground.

- https://developer.apple.com/documentation/appintents/audioplaybackintent

- https://zachwaugh.com/posts/forcing-appintent-to-run-in-main-app-process

- https://defn.io/2025/04/13/performing-widget-intents-in-ios-app/

- https://developer.apple.com/forums/thread/736445

### App Store review risk: AudioPlaybackIntent is semantically intended for media playback apps, and an AAC app using it to trigger TTS is off-label

*Confidence: low, **LOAD-BEARING***

Apple's framing is media transport controls (play/pause). No documentation found sanctioning or forbidding TTS use. This is a real but unquantified rejection risk, and Apple could tighten process-hosting rules in a future iOS. Mitigation: AAC is a first-class accessibility category Apple actively courts (see Personal Voice guidance), so an appeal has a strong story. Recommend building a fallback path (openAppWhenRun:true) behind a flag.

- https://developer.apple.com/documentation/appintents/audioplaybackintent

### iOS Lock Screen widgets (accessoryCircular/Rectangular/Inline) are NOT interactive and cannot run AppIntents — this is a design constraint, not a bug

*Confidence: high, **LOAD-BEARING***

Lock screen widgets behave like watchOS complications: glanceable only. Tapping enters the app (optionally deep-linked via .widgetURL()). Interactive Button/Toggle with AppIntent is a Home Screen / StandBy / Live Activity capability only. Do not plan a lock-screen-widget speaking path.

- https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications

- https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities

### iOS 18 Controls (ControlWidget) run AppIntents, can REPLACE the Lock Screen flashlight/camera buttons, and can be bound to the Action Button on iPhone 15 Pro+

*Confidence: high, **LOAD-BEARING***

ControlWidgetButton takes an AppIntent action; ControlWidgetToggle takes a SetValueIntent<Bool>. Third-party controls can be mapped to the Action button and can replace the two default Lock Screen controls. This gives up to two always-visible, one-tap-from-lock phrase buttons plus a physical button — the shortest theoretical time-to-word on iOS.

- https://developer.apple.com/videos/play/wwdc2024/10157/

- https://rudrank.com/exploring-widgetkit-first-control-widget-ios-18-swiftui

- https://www.macstories.net/roundups/control-center-and-lock-screen-controls-a-roundupof-my-favorites/

### UNVERIFIED: whether a third-party Lock Screen Control can run its AppIntent without Face ID/passcode unlock, and whether AudioPlaybackIntent conformance works from a Control

*Confidence: low, **LOAD-BEARING***

Apple's own flashlight/camera Lock Screen controls work without unlock, but no documentation found confirming third-party control intents run pre-authentication, nor confirming a Control can host an AudioPlaybackIntent to reach the app process for audio. Both are plausible and both are load-bearing for the best-case iOS design. MUST be settled by a device spike before committing to this path.

- https://developer.apple.com/videos/play/wwdc2024/10157/

### iOS Back Tap CAN run a Shortcut (double or triple tap on the back of the phone), works offline, but REQUIRES the phone to be unlocked

*Confidence: high, **LOAD-BEARING***

Settings > Accessibility > Touch > Back Tap > Double/Triple Tap > choose a Shortcut. iPhone 8+ / iOS 14+. The unlock requirement substantially weakens the 'mid-shutdown, phone in pocket' scenario — it saves navigation time, not unlock time. Still valuable: unlocked-phone-in-hand → double tap → speaks, with no app navigation. Requires the app to expose App Intents/Shortcuts actions (e.g. a 'Speak Phrase' intent with a phrase parameter).

- https://support.apple.com/guide/shortcuts/run-shortcuts-tapping-iphone-apd897693606/ios

- https://support.apple.com/en-us/111772

### iOS Live Speech is a serious, free, built-in competitor that already does the core MVP job — including saved phrases, user-created categories, offline operation, and Apple Watch support

*Confidence: high, **LOAD-BEARING***

Invoked by triple-click of the side/Home button (Accessibility Shortcut). Settings > Accessibility > Live Speech > Phrases supports saved phrases AND custom categories with icons. Available iPhone/iPad/Mac/Watch; on Apple Watch via triple-click of the Digital Crown → type or pick a favorite phrase. Crucially, Live Speech gets the triple-click Accessibility Shortcut, which is reserved for built-in accessibility features — third-party apps CANNOT register for it. This is an unbeatable structural advantage on time-to-first-word.

- https://support.apple.com/en-us/105018

- https://support.apple.com/guide/iphone/type-to-speak-iphcf92d2d9b/ios

- https://support.apple.com/guide/watch/type-to-speak-apd86a007717/watchos

- https://www.apple.com/lae/accessibility/speech/

### Live Speech's weaknesses are real and match this product's thesis: it is text/keyboard-first with a flat phrase list, no symbol/tile grid, no large-target one-handed grid design, and it is buried in Settings to configure

*Confidence: medium, **LOAD-BEARING***

Phrase management lives in Settings > Accessibility > Live Speech > Phrases; in-use you tap a keyboard icon to switch to Phrases, then pick a category, then a phrase — a multi-tap drill-down, not a grid. Independent AAC research on autistic adults names Speed, Voice quality, and device restrictions as the dominant complaints with existing AAC. Live Speech is a text-entry tool with a phrase shortcut bolted on, not a tile-grid AAC surface. The differentiation is grid ergonomics + speed, NOT the basic 'type and speak' function — which is now commoditized by the OS.

- https://support.apple.com/guide/iphone/type-to-speak-iphcf92d2d9b/ios

- https://arxiv.org/html/2404.17730

- https://pmc.ncbi.nlm.nih.gov/articles/PMC8992808/

### Personal Voice IS available to third-party apps via AVSpeechSynthesizer, and Apple explicitly names AAC apps as the intended use case

*Confidence: high, **LOAD-BEARING***

requestPersonalVoiceAuthorization() on AVSpeechSynthesizer; once authorized, personal voices appear in AVSpeechSynthesisVoice.speechVoices() marked with the .isPersonalVoice voiceTrait, then assigned to an AVSpeechUtterance like any voice. Voice model stays on-device (secure enclave) unless the user opts into iCloud sharing — fully offline, matching the product's privacy stance. Apple guidance: Personal Voice should primarily serve AAC and assistive contexts; general-purpose apps requesting it face review scrutiny. This is a strong wedge — an AAC app is the blessed consumer of this API.

- https://developer.apple.com/videos/play/wwdc2023/10033/

- https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/personalvoiceauthorizationstatus-swift.type.property

- https://bendodson.com/weblog/2024/04/03/using-your-personal-voice-in-an-ios-app/

- https://support.apple.com/en-us/104993

### ANDROID'S BEST PATH: a Quick Settings tile's TileService.onClick() runs arbitrary code with the app not running, is reachable from the lock-screen shade, and does NOT require unlock for non-sensitive actions like speaking

*Confidence: medium, **LOAD-BEARING***

TileService is a bound service executed without the application running. onClick() can initialize TextToSpeech and speak directly — the anti-pattern is calling startActivityAndCollapse(). Android docs confirm tiles display on the lock screen; isLocked() reports lock state, isSecure() reports whether a secure lock is set, and unlockAndRun(Runnable) is the opt-in path required only for SENSITIVE actions. Speaking a stored phrase is not sensitive, so it can run pre-unlock. Caveat: showDialog() won't render under the lock screen; keep the tile action UI-free. Second caveat: OEM skins and the user's 'lock screen > quick settings' setting can restrict shade access when locked.

- https://developer.android.com/develop/ui/views/quicksettings-tiles

- https://developer.android.com/reference/android/service/quicksettings/TileService

- https://medium.com/androiddevelopers/quick-settings-tiles-e3c22daf93a8

### Android home screen widgets can speak: tapping a widget is an explicit documented exemption to the Android 12+ background foreground-service start restriction

*Confidence: high, **LOAD-BEARING***

Android 12 (API 31) blocks starting an FGS from the background, but the documented exemption list includes 'the service starts by interacting with app widgets' and PendingIntents sent from a visible app. So widget button → PendingIntent → foreground service → TextToSpeech.speak() is a legal, documented path. In practice TTS is short enough that a plain service or even the broadcast receiver's goAsync() window may suffice, but the FGS path is the safe one.

- https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start

- https://proandroiddev.com/foreground-service-launch-restrictions-android12-ee00bf8a1674

### Wear OS standalone AAC is viable: TextToSpeech works on Wear OS 4+ through the watch speaker, and Tiles support loadAction() to run logic in TileService without opening the app

*Confidence: medium*

Google's 2024 Wear OS TTS engine post names accessibility and reading alerts aloud through the watch speaker or BT headphones as target use cases; TextToSpeech#speak is the same API, Wear OS 4+. Tiles: loadAction() re-invokes TileService.onTileRequest() so you can run logic in-service rather than launching an activity. Unknown/unverified: watch speaker loudness in a noisy shop or ER — likely the binding constraint on whether a watch tile is actually useful vs. a nice demo.

- https://android-developers.googleblog.com/2024/03/introducing-new-text-to-speech-engine-wear-os.html

- https://developer.android.com/training/wearables/tiles/interactions

- https://developer.android.com/training/wearables/tiles

### Flutter cannot write the widgets — home_widget wires Flutter to natively-written widgets, and there are working recipes for interactive widgets on both platforms

*Confidence: high, **LOAD-BEARING***

home_widget explicitly 'does not allow writing Widgets with Flutter itself - it still requires writing the Widgets with native code' (SwiftUI/WidgetKit on iOS, Jetpack Glance on Android). iOS interactive recipe: create a custom AppIntent in the App Target (Runner) calling HomeWidgetBackgroundWorker.run with a URL + app group; works while the app is backgrounded. Adding ForegroundContinuableIntent wakes the app but starts the full Flutter app via the normal main entrypoint in the background. Android: Glance widgets only update on state change; since home_widget 0.8.1 the background service no longer needs manifest registration. Note Glance is NOT Compose — many Compose features don't work in Glance.

- https://pub.dev/packages/home_widget

- https://docs.page/abausg/home_widget/features/interactive-widgets

- https://medium.com/@ABausG/interactive-homescreen-widgets-with-flutter-using-home-widget-83cb0706a417

- https://codelabs.developers.google.com/flutter-home-screen-widgets

### ARCHITECTURAL CONSEQUENCE: the speaking path should be native (Swift/Kotlin) reading from shared storage, NOT a Flutter engine spin-up

*Confidence: medium, **LOAD-BEARING***

home_widget's iOS interactive path routes through HomeWidgetBackgroundWorker (a Flutter background isolate) and the ForegroundContinuableIntent variant boots the full Flutter app via the main entrypoint — both add latency and failure modes on the one path that must be instant. Since AudioPlaybackIntent already gets you into the app's native process, the correct design is: phrases persisted to an App Group (iOS) / SharedPreferences or DataStore (Android); the AppIntent/TileService reads the phrase natively and calls AVSpeechSynthesizer/TextToSpeech directly, with zero Flutter involvement. Flutter owns only the editor UI. This makes 'time to first word' a native-code budget, not a Flutter engine-start budget.

- https://docs.page/abausg/home_widget/features/interactive-widgets

- https://pub.dev/packages/home_widget

- https://developer.apple.com/documentation/appintents/audioplaybackintent

### The iOS Accessibility Shortcut (triple-click side button) is closed to third-party apps — this asymmetry cannot be engineered around

*Confidence: medium*

Triple-click routes only to built-in accessibility features (Live Speech, AssistiveTouch, Guided Access, Zoom, etc.). Third-party apps have no registration API for it. The closest third-party equivalents are Back Tap→Shortcut (requires unlock), the Action Button (iPhone 15 Pro+ only), and Lock Screen Controls (iOS 18+, two slots). Accept this and compete on grid ergonomics instead of raw invocation speed.

- https://support.apple.com/en-us/105018

- https://support.apple.com/en-us/111772

### Notification actions are a weak-but-cheap path on Android and near-useless on iOS

*Confidence: low*

Android: an ongoing/persistent low-priority notification with action buttons whose PendingIntents hit a receiver/FGS can speak — same exemption logic as widgets, and it's visible on the lock screen. iOS: notification actions require the notification to exist (you can't keep a permanent one), and handling runs in the app's notification service/app process only in constrained ways — not a reliable always-available speak surface. Treat Android persistent notification as a cheap bonus surface; skip on iOS.

- https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start

### Screen-off / in-pocket speaking is not achievable on iOS and only marginally on Android

*Confidence: medium*

Every iOS path (widget, control, Back Tap, Action Button) requires the screen on and, except for Lock Screen Controls, the device unlocked. Back Tap explicitly requires unlock. The Action Button works with screen off on iPhone 15 Pro+ but launching a Shortcut that speaks still involves Shortcuts runtime latency. On Android, a hardware key mapped via an accessibility service, or a QS tile from the lock shade, is the closest — still requires waking the screen. Realistic best case is 'phone out, screen on, locked → one tap → speech', not 'in pocket'.

- https://support.apple.com/en-us/111772

- https://developer.android.com/develop/ui/views/quicksettings-tiles

## Product implications

- **[must-have-mvp]** Build the iOS speak path as an AppIntent conforming to AudioPlaybackIntent, hosted in a Home Screen widget, reading phrases from an App Group and calling AVSpeechSynthesizer natively — no Flutter engine on this path
  - This is the only verified way to make a widget tile speak without opening the app: AudioPlaybackIntent forces perform() into the main app process where an audio session can be activated. Widget extensions cannot activate AVAudioSession, so every other widget design fails on device (often after passing in Simulator). Keeping it native avoids Flutter isolate/engine start latency on the one path that must be instant.
- **[must-have-mvp]** Spike three unknowns on real hardware in week 1 before committing the architecture: (1) does a Lock Screen Control run its AppIntent without unlock, (2) can a ControlWidget host an AudioPlaybackIntent and actually produce audio, (3) does App Review accept AudioPlaybackIntent for TTS
  - These three are load-bearing and unverifiable from documentation. If (1) and (2) are true, a Lock Screen Control is the fastest time-to-first-word on iOS and reshapes the whole product; if false, the Home Screen widget is the ceiling. (3) is an existential risk to the headline feature and should be de-risked with an early TestFlight/review probe, with an openAppWhenRun:true fallback behind a flag.
- **[must-have-mvp]** Ship the Android Quick Settings tile as a first-class launch surface, not a v2 extra
  - It is the single best time-to-first-word affordance found on either platform: TileService.onClick() runs with the app not running, reaches TextToSpeech directly, and is available from the lock-screen shade without unlock because speaking a stored phrase is not a sensitive action requiring unlockAndRun(). Android beats iOS here — lead with it rather than treating Android as an iOS port.
- **[must-have-mvp]** Do NOT compete with Live Speech on 'type and speak' — differentiate on the tile grid, one-handed reachability, and large targets under distress
  - Live Speech is free, built into iOS/iPadOS/macOS/watchOS, works offline, already has saved phrases AND custom categories, and owns the triple-click Accessibility Shortcut that third-party apps can never register for. The basic function is commoditized by the OS. What Live Speech lacks is a symbol/tile grid, large one-handed targets, and non-Settings-buried editing — plus it does not exist on Android at all. That gap, not TTS itself, is the product.
- **[should-have-v1]** Integrate Personal Voice via requestPersonalVoiceAuthorization() and market it prominently
  - Personal Voice is open to third parties, stays on-device (matching the privacy stance), and Apple explicitly names AAC as its intended use case — meaning an AAC app is the blessed consumer and review scrutiny works in this product's favor. It directly answers the 'TTS must sound acceptable' risk and the 'dignity' thesis better than any voice-picker could, and it is a feature Live Speech has but cheap AAC competitors do not.
- **[should-have-v1]** Ship an iOS 18 Control that users can bind to the Action Button and/or a Lock Screen slot, plus a 'Speak Phrase' App Intent exposed to Shortcuts for Back Tap
  - These are the only third-party substitutes for the closed triple-click shortcut. Back Tap requires unlock so it saves navigation, not unlock time — real but partial value. The Action Button and Lock Screen Controls are the fastest available, but are gated on iPhone 15 Pro+ / iOS 18 and on the unverified no-unlock question, so they belong just behind the widget rather than in the critical path.
- **[must-have-mvp]** Plan for Flutter to own only the editor/settings UI, with phrases persisted to App Group (iOS) and SharedPreferences/DataStore (Android) as the contract between Flutter and native speak paths
  - home_widget cannot write widgets in Flutter — WidgetKit/SwiftUI and Jetpack Glance are mandatory native work, and Glance is notably not Compose. Budget real native engineering on both platforms from day one. Treating shared storage as the boundary keeps the speak path native and instant while letting Flutter deliver the cross-platform value it was chosen for.
- **[explicitly-avoid]** Skip iOS Lock Screen widgets and iOS notification actions entirely
  - Lock Screen accessory widgets are non-interactive by design — they cannot run AppIntents and tapping only deep-links into the app, so they can never speak. iOS notification actions cannot provide a permanently available speak surface. Both are dead ends that will consume sprint time; iOS 18 Controls are the correct lock-screen story instead.
- **[explicitly-avoid]** Do not promise screen-off or in-pocket speaking in positioning or roadmap
  - No verified path achieves it on iOS: Back Tap requires unlock, and every widget/control path requires the screen on. The honest and still-compelling claim is 'phone out, screen on, one tap from the lock screen or home screen → speech, offline, no login'. Over-promising here would break trust with exactly the community whose trust is the product's core asset.
- **[nice-to-have-later]** Treat Wear OS / Apple Watch as a post-v1 bet, gated on a speaker-loudness test in a real noisy environment
  - The mechanics work — Wear OS 4+ supports TextToSpeech through the watch speaker and Tiles' loadAction() runs logic in TileService without opening the app. But Live Speech already ships on Apple Watch via Digital Crown triple-click, and watch speaker volume in a shop or ER is unverified and is the likely binding constraint. Test loudness before investing; if it fails, the whole surface is a demo, not an accommodation.

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


YOUR DIMENSION: "Time to first word" — every OS-level path to speaking FAST, and what's possible in 2026.

The core insight to test: if a user is mid-shutdown, unlocking a phone, finding an app, waiting for launch, and navigating to a tile may itself be too slow/too hard. Research every OS affordance that shortens this.

Research using WebSearch and WebFetch (Apple developer docs, Android developer docs, WWDC/Google IO content, Flutter packages).

Answer specifically for iOS and Android in 2026:
- iOS Home Screen widgets (WidgetKit): can a widget contain tappable buttons that trigger an action WITHOUT opening the app? (AppIntent + interactive widgets, iOS 17+). Can a widget SPEAK audio directly? Verify — this is the killer feature if true. What are the limits (memory, execution time, audio playback from an AppIntent in a widget extension)?
- iOS Lock Screen widgets: interactive? Can they run AppIntents? (iOS 18+?) Can you speak from the lock screen without unlocking?
- iOS Control Center widget / Controls (iOS 18 ControlWidget) — can a third-party control run an AppIntent? Could a Control speak a phrase?
- iPhone Action Button + Apple Watch Action button: can it launch a Shortcut that speaks a phrase? Does that work offline?
- Siri Shortcuts / App Intents: "Hey Siri, say I need help" — but user cannot speak. Shortcuts run from Back Tap? Accessibility > Touch > Back Tap can run a Shortcut — verify. That's a double-tap-on-back-of-phone to speak. Huge if true.
- Apple Watch: standalone AAC on the wrist? Watch speaker volume? Is a watch app worth it?
- iOS Live Speech (Accessibility feature, iOS 17+): what is it exactly, how is it invoked (triple-click side button?), does it have saved phrases, and does it already do this job? Be honest — this may be a serious competitor built into the OS.
- iOS Personal Voice: how it works, offline, and whether Live Speech / third-party apps can use it.
- Android: App Widgets (Jetpack Glance), Quick Settings Tiles (can a QS tile speak?), Assistant shortcuts, Android accessibility shortcuts, lock screen options, Wear OS.
- Android: can an app play TTS audio from a widget/tile broadcast without opening? (Foreground service? Broadcast receiver?)
- Flutter interop: home_widget package, quick_actions, flutter_shortcuts, app_intents. What's the state of writing AppIntents/WidgetKit widgets alongside a Flutter app? Any known working recipes for interactive widgets from Flutter?
- What about a persistent notification with action buttons that speak? Android notification actions / iOS notification actions.
- Screen-off / pocket use?

Rank these paths by (impact x feasibility). Be concrete about what is actually possible vs. marketing.
````

</details>
