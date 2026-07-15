# failure-modes--flutter-is-the-wrong-stack-for-this-specific

> Phase: **verify** · Agent `a1534d7059ee4b51d` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Flutter is a defensible stack for this product; the claim's own evidence does not support its conclusion. Correct version: "flutter_tts does not expose Apple Personal Voice (verified in its iOS source — getVoices() returns only name/locale/quality/gender/identifier, and requestPersonalVoiceAuthorization is never called), so Personal Voice requires a custom platform channel of roughly a few dozen lines of Swift. Separately, Lock Screen/home/Control Center widgets and a watch app require SwiftUI extensions — but this is NOT a Flutter cost, because WidgetKit forbids UIKit and watchOS targets are always separate SwiftUI targets, so a fully native app writes the identical extensions. Back Tap, the Action Button, and Shortcuts 'Open App' require no code at all and work for Flutter apps identically to native. The Accessibility Shortcut cannot launch any third-party app in any stack. Choosing Flutter costs roughly a few hundred lines of platform-channel and extension glue; choosing native costs the entire Android build, which is the more damaging trade for a product whose core pitch is undercutting $299 iOS-only incumbents. The real risks worth escalating are Apple's free, preinstalled Live Speech (already on the Accessibility Shortcut, already on Apple Watch, already Personal Voice-enabled) and the fact that Android has no Personal Voice equivalent at all — a platform gap, not a framework gap."

**Evidence:** The claim's narrow technical facts about flutter_tts hold up, but the headline conclusion ("Flutter is the wrong stack") rests on a category error, and several specifics in the supporting list are wrong.

WHAT CHECKS OUT (verified independently):
1. flutter_tts does NOT expose Personal Voice. I read the plugin's iOS source directly (raw.githubusercontent.com/dlutton/flutter_tts/master/ios/Classes/SwiftFlutterTtsPlugin.swift): getVoices() iterates AVSpeechSynthesisVoice.speechVoices() and returns only name/locale/quality/gender/identifier. There is no reference to requestPersonalVoiceAuthorization, isPersonalVoice, or voiceTraits anywhere in the file. Since personal voices only appear in speechVoices() AFTER authorization is granted — which the plugin never requests — they are unreachable through the package. A platform channel is genuinely required. Latest version is 4.2.5 (published ~6 months ago).
2. The incumbent Speech Assistant AAC (asoft.nl) does ship an Apple Watch app — asoft.nl states it is "designed for iPad, iPhone and Apple Watch."
3. Apple does allow third-party Personal Voice use: Apple Support 104993 states you can "allow third-party apps, such as augmentative and alternative communication (AAC) apps, to request to use your personal voice."

WHERE THE CLAIM BREAKS DOWN:

A. THE CENTRAL CATEGORY ERROR. "Requires native Swift work that Flutter does not cover" is not a Flutter penalty, because a 100% native app pays the identical cost. WidgetKit only supports SwiftUI views; UIKit is not allowed in widget extensions, and UIViewRepresentable does not work there. So a fully native UIKit app must ALSO write its Lock Screen widget, home widget, and Control Center control as a separate SwiftUI extension that shares zero UI code with the main app. Same for watchOS: watch apps are always separate SwiftUI targets, native or not. The Flutter delta is not "you must write Swift" — it's only the data-sharing bridge, which home_widget (BSD-3, actively maintained, documented Lock Screen support at docs.page/abausg/home_widget/features/ios-lock-screen, and an official Google codelab at codelabs.developers.google.com/flutter-home-screen-widgets) already provides. Flutter is not "weakest" at these surfaces; every stack is equally weak at them because Apple made them SwiftUI-only extensions by design.

B. TWO ITEMS IN THE RISK-#1 LIST REQUIRE ZERO CODE IN ANY STACK. Back Tap (Settings > Accessibility > Touch > Back Tap > run a Shortcut containing "Open App") and the Action Button (Settings > Action Button > Shortcut) both route through the Shortcuts app's "Open App" action, which lists "every app on your device... including both native and third-party ones" (Apple Support apdfea15680b, apd897693606). A Flutter app appears in that list identically to a Swift app. These are user-configured OS settings, not an API surface — citing them as evidence against Flutter is simply incorrect.

C. ONE ITEM IN THE LIST IS FACTUALLY IMPOSSIBLE FOR ANY APP. The Accessibility Shortcut (triple-click) can only toggle built-in accessibility features (VoiceOver, Zoom, AssistiveTouch, Guided Access, Live Speech, etc. — Apple Support 111771). Third-party apps cannot be added to it, in Swift or Flutter. Including it as a Flutter shortfall is an invented differentiator.

D. APP INTENTS ARE AVAILABLE TO FLUTTER, AND THE NATIVE COST IS THE SAME. flutter_app_intents (pub.dev, v0.7.0, MIT, iOS 16+) advertises Siri, Shortcuts, Spotlight, and "enhanced widget and control center integration." It does require static AppIntent structs in Swift — but a native app writes those exact same structs. Identical work, not extra work.

E. THE flutter_tts DOCUMENTATION QUOTE IS MISUSED. I could not find "vary heavily between iOS and Android" in the flutter_tts README (raw GitHub) or the pub.dev page; when the phrase surfaces, it is a statement about the underlying OS TTS ENGINES, not a defect in Flutter. Native Swift and native Kotlin apps calling AVSpeechSynthesizer and android.speech.tts also get engines that "vary heavily" — because they are different engines from different vendors. This is a fact about iOS vs. Android, laundered into an argument about Flutter. Likewise, "iOS-specific output bugs" in a package's issue tracker is a bug-fix cost, not an architectural verdict; the two issues surfaced (#323 setVoice latency, #536 no iOS output) are ordinary AVAudioSession configuration issues.

F. THE COST IS BOUNDED AND MISCHARACTERIZED. Adding up the genuine Flutter-specific overhead: a Personal Voice platform channel (tens of lines of Swift wrapping requestPersonalVoiceAuthorization + a speechVoices() filter on .isPersonalVoice), the home_widget data bridge, and a watchOS target added via Xcode (documented workflow; known workaround = manually set Watch App > Build Settings > Supported Platforms to watchOS for Profile/Release). That is a few hundred lines of glue — real, but nowhere near "cross-platform reach is being bought at the price of the two features that determine whether the product works at all." Meanwhile going native costs you the entire Android build, which for a $0-vs-$299 product positioned explicitly against "iOS-only premium options" is the far larger strategic loss the claim never weighs.

THE THING THE CLAIM SHOULD HAVE FLAGGED: Apple's built-in Live Speech is already on the Accessibility Shortcut, already on Apple Watch, and already supports Personal Voice — a free, preinstalled, zero-discoverability-cost competitor. That is a genuine threat to this product, and it is entirely stack-independent.

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

CLAIM: Flutter is the wrong stack for this specific product: the top two risks are both solved by native OS surfaces where Flutter is weakest
THEIR DETAIL: Risk #1 (crisis discoverability) is solved by Lock Screen widgets, Control Center controls, iOS Action Button, Back Tap, Accessibility Shortcut triple-click, App Intents, and watch complications — all of which require native Swift/Kotlin work that Flutter does not cover; Flutter gives you the one surface (the app's own UI) that is least useful when the user cannot remember the app exists. Note the incumbent already ships an Apple Watch app. Risk #2 (voice = identity) requires Apple Personal Voice, which third-party apps CAN use via AVSpeechSynthesizer.requestPersonalVoiceAuthorization + filtering AVSpeechSynthesisVoice.speechVoices() for the .isPersonalVoice trait — but there is no evidence flutter_tts exposes this, so it needs a custom platform channel. flutter_tts is also documented as having platform-variable voice quality, iOS-specific output bugs, and a general warning that TTS engines 'vary heavily between iOS and Android'. Cross-platform reach is being bought at the price of the two features that determine whether the product works at all.
THEIR CLAIMED SOURCES: https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer/personalvoiceauthorizationstatus, https://developer.apple.com/videos/play/wwdc2023/10033/, https://github.com/dlutton/flutter_tts, https://pub.dev/packages/flutter_tts, https://asoft.nl/
THEIR CONFIDENCE: medium

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
