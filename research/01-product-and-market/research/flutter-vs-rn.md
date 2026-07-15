# flutter-vs-rn

> Phase: **research** · Agent `a25cb121d24108f33` · Run `wf_3a8e3c64-43a`

## Result

## Summary

Flutter is a defensible choice for this app, and I'd validate the user's preference — but not for the reasons usually given, and with two named risks. The accessibility "crux" is real but weighted wrong: Flutter's screen-reader story (VoiceOver/TalkBack via SemanticsNode) is genuinely good and arguably better-defaulted than React Native's, which is manual and routinely broken in practice. Where Flutter has a hard, documented gap is iOS Full Keyboard Access — enabling FKA in iOS Accessibility settings actively breaks external keyboard input in Flutter apps (open issues #76497, #148409, #165303, #166683), and at least one accessibility practitioner states it is currently not possible to make a Flutter app fully WCAG-compliant because of it. iOS Switch Control support has been an open, unresolved Flutter proposal since May 2023 (#126377) with no official support statement — that is an unquantified risk for an AAC app, and it is the single thing worth de-risking before writing much code. Everything else favors Flutter or is a wash: Flutter honors system text scaling by default via TextScaler, cold start / time-to-first-frame benchmarks favor Flutter over RN on both platforms, TTS parity is a non-issue (both are thin wrappers over the same native engines), and the widget/Watch pain is real in Flutter but the mitigation (home_widget + native SwiftUI/Glance) is well-trodden. The one place RN + Expo is materially better is the native-target surface: expo-apple-targets makes WidgetKit/App Intents targets a config-plugin concern, whereas Flutter has no official App Intents story at all. None of that surface is MVP.

### Flutter has a documented, unfixed bug where enabling iOS Full Keyboard Access breaks external keyboard input entirely in Flutter apps

*Confidence: high, **LOAD-BEARING***

With an external keyboard attached, a Flutter iOS app responds normally. Turning on Settings > Accessibility > Keyboards > Full Keyboard Access causes the app to stop responding to key presses — no navigation, no button activation. Tracked across multiple open issues: flutter/flutter#76497 (feature request to support FKA navigation events), #148409 (duplicate/parallel request), #165303 and #166683 (both 2025 reports of FKA breaking external keyboards). Accessibility practitioners state flatly that 'FKA on Flutter does not exist' and that full WCAG conformance is therefore not currently achievable in Flutter on iOS. React Native, rendering real UIKit views, gets FKA behavior largely for free.

- https://github.com/flutter/flutter/issues/76497

- https://github.com/flutter/flutter/issues/165303

- https://github.com/flutter/flutter/issues/166683

- https://github.com/flutter/flutter/issues/148409

- https://dev.to/adepto/improving-accessibility-in-flutter-apps-a-comprehensive-guide-1jod

### Flutter has no official statement of iOS Switch Control support; the tracking issue has been an open proposal with no assignee since May 2023

*Confidence: high, **LOAD-BEARING***

flutter/flutter#126377, opened by Hixie (Ian Hickson) on 2023-05-09, is titled as a proposal to 'make sure we fully support switch control accessibility input on iOS and other platforms.' It is labeled 'new feature' / 'c: proposal', remains open, has no assignee, and enumerates no specific gaps — it links only to Apple's Switch Control docs and the WWDC 2020 session. The framing itself implies comprehensive support is not known to be implemented. Flutter's own assistive-technologies doc lists Switch Access (Android) / Switch Control (iOS) as things developers should 'understand', but makes no support claim and lists no caveats — it says only that standard widgets 'generate an accessibility tree automatically' and tells developers to test on real devices.

- https://github.com/flutter/flutter/issues/126377

- https://docs.flutter.dev/ui/accessibility/assistive-technologies

### Flutter honors system text scaling by default — the failure mode is layout, not the setting being ignored

*Confidence: high, **LOAD-BEARING***

Flutter text widgets respect the OS font-size setting automatically via TextScaler; MediaQuery.textScalerOf(context) reads the user's chosen scale. flutter/flutter#22480 (opened 2018, now closed) was a developer asking how to DISABLE iOS Larger Text scaling — i.e. the complaint was that it works, not that it doesn't. The real risk is self-inflicted: if you hardcode textScaleFactor: 1.0 or clamp it, you silently break the user's accessibility setting. AccessibilityFeatures also exposes boldText, highContrast, invertColors, disableAnimations/reduceMotion. What actually breaks at 200%+ scale is fixed-height tiles and grids overflowing — a design problem, not a framework problem.

- https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility

- https://github.com/flutter/flutter/issues/22480

- https://docs.flutter.dev/ui/accessibility/ui-design-and-styling

### Flutter's screen-reader defaults are better than React Native's, not worse — RN's a11y is manual and commonly broken in practice

*Confidence: medium, **LOAD-BEARING***

Flutter's standard widgets auto-generate the accessibility tree and Flutter actually exceeds both native platforms on heading levels (iOS/Android primitives only know 'is a heading', not H2-under-H3). React Native requires hand-authoring accessibilityLabel/accessibilityRole per element — 'on the web accessibility is baked in, in React Native you have to build it yourself.' Flutter's known screen-reader pain is duplicate/double-announced nodes when a Semantics wrapper and the underlying widget both emit nodes — fixed with MergeSemantics. Live-region politeness is the biggest genuine cross-platform divergence and it affects every framework equally (Android has per-view politeness, iOS has only a global imperative post).

- https://www.disabilityworld.org/articles/mobile-native-a11y-apis/

- https://accessibility-test.org/blog/compare/react-native-vs-flutter-mobile-accessibility-development/

- https://reactnative.dev/docs/accessibility

- https://oneuptime.com/blog/post/2026-01-15-react-native-screen-reader-support/view

### The 'Flutter paints to a canvas so it's inaccessible' criticism is a web-only concern and does not apply to Flutter on iOS/Android

*Confidence: high, **LOAD-BEARING***

On mobile, Flutter's SemanticsNode tree maps to real UIAccessibility / AccessibilityNodeInfo objects — assistive tech sees nodes, not pixels. The 'canvas is a black hole for TalkBack' reports trace to (a) Flutter WEB, where accessibility is explicitly opt-in for performance and must be turned on via an invisible 'Enable accessibility' button or SemanticsBinding.instance.ensureSemantics(), and (b) app-specific custom-painted widgets (e.g. a terminal emulator in flutter_server_box #983) that never populate semantics. Do not let this argument decide the mobile framework — but it does directly damage the PWA-as-extra-channel idea.

- https://docs.flutter.dev/ui/accessibility/web-accessibility

- https://github.com/lollipopkit/flutter_server_box/issues/983

- https://medium.com/flutter/accessibility-in-flutter-on-the-web-51bfc558b7d3

### Flutter beats React Native on cold start / time-to-first-frame on both platforms

*Confidence: medium, **LOAD-BEARING***

2025 benchmark (iPhone 16 Plus / Galaxy Z Fold 6, 100-item list, 3 runs each): iOS TTFF — Flutter 16.67ms (SD 1.25), RN 32.96ms (SD 0.16), Swift native 41.37ms (SD 54.75). Android TTFF — Flutter 10.33ms (SD 4.5), RN 15.31ms (SD 0.46), Kotlin native 16ms. Caveat: TTFF is not the same as user-perceived cold launch from a cold process, and these are trivial apps; treat as directional. Directionally it favors Flutter, which matters for a mid-shutdown launch. Impeller is now the default and only renderer on modern Android with Skia removed, eliminating first-run shader-compilation jank — historically Flutter's worst 'first tap feels bad' failure.

- https://www.synergyboat.com/blog/flutter-vs-react-native-vs-native-performance-benchmark-2025

- https://www.bolderapps.com/blog-posts/flutter-vs-react-native-in-2026-why-the-new-architecture-and-impeller-2-0-changed-everything

### App size is a wash — Flutter is actually smaller than RN+Expo in measured 2025 builds, contradicting the folk wisdom

*Confidence: medium*

Same benchmark: iOS binary — Flutter 18.3MB, RN(Expo) 20.2MB, Swift 0.457MB. Android artifact — Flutter 41.6MB, RN(Expo) 52.1MB, Kotlin 13.3MB. Flutter bundles engine + ICU; Expo bundles its runtime + JS. Other sources report Flutter hello-world APK ~5.6MB vs RN ~8MB, or claim RN is '2-4MB smaller' — the numbers are inconsistent across sources because they measure different artifacts (raw APK vs AAB split download vs bare RN vs Expo). Conclusion: neither framework wins meaningfully, and both are ~30MB heavier than native. Not a decision input.

- https://www.synergyboat.com/blog/flutter-vs-react-native-vs-native-performance-benchmark-2025

- https://www.discretelogix.com/react-native-vs-flutter/

### Flutter's custom text field has a long tail of real IME/dictation/autocorrect bugs — directly relevant to the 'type to speak' box

*Confidence: high, **LOAD-BEARING***

Concrete open issues: #171955 (TextInputFormatter + Samsung Keyboard autocorrect race condition producing wrong text, filed 2025-07-10); #133034 (TextInputFormatter breaks dictation on Android, reproduced on Gboard and SwiftKey); #84419 (iOS dictation: onChanged fires after clear()); #134881 (iOS spellCheckingType is always forced to .default — FlutterTextInputView ignores the field's spell-check config, so the auto-suggest bar can't be disabled); #139143 (enableSuggestions:false makes Gboard disable Chinese/Korean/Cantonese entirely); #22828 (autocorrect:false still shows keyboard suggestions). Flutter reimplements the text field and talks to the IME through a platform channel; RN uses the real UITextField/EditText. The mitigation is cheap: do NOT use TextInputFormatter on the type-to-speak field (it's the common thread in the worst bugs) and test dictation + Gboard/SwiftKey/Samsung early.

- https://github.com/flutter/flutter/issues/171955

- https://github.com/flutter/flutter/issues/133034

- https://github.com/flutter/flutter/issues/84419

- https://github.com/flutter/flutter/issues/134881

- https://github.com/flutter/flutter/issues/139143

- https://github.com/flutter/flutter/issues/22828

### TTS parity is a non-issue — both ecosystems are thin wrappers over the identical native engines, so voice quality is a device concern, not a framework concern

*Confidence: high*

flutter_tts and react-native-tts both wrap AVSpeechSynthesizer (iOS) and android.speech.tts.TextToSpeech (Android). Voice quality therefore depends entirely on the device's installed engine/voices, not the wrapper. flutter_tts additionally exposes per-voice quality/latency/network metadata, which is useful for filtering to on-device voices only. If stock voices prove unacceptable, both ecosystems have ONNX escape hatches (flutter_kitten_tts / KittenML on Flutter; react-native-sherpa-onnx-offline-tts on RN) — but that trades tens of MB and battery for quality. Do not build the framework decision on TTS.

- https://pub.dev/packages/flutter_tts

- https://www.npmjs.com/package/react-native-tts

- https://www.netguru.com/blog/react-native-text-to-speech

- https://pub.dev/packages/flutter_kitten_tts

- https://github.com/kislay99/react-native-sherpa-onnx-offline-tts

### Flutter cannot write Home Screen widgets in Dart and has no official App Intents story; Expo's tooling here is genuinely better

*Confidence: high, **LOAD-BEARING***

home_widget's own docs state it 'does not allow writing Widgets with Flutter itself. It still requires writing the Widgets with native code' — it is a data bridge (App Groups on iOS, SharedPreferences on Android) plus an update trigger. You write SwiftUI/WidgetKit and Jetpack Glance by hand; home_widget added Glance support to reduce the Android half. glance_widget claims zero-native-code widgets on both platforms but is young and unproven — do not bet a shipping feature on it. For App Intents (which Siri Shortcuts now routes through; SiriKit is on a deprecation path), flutter/flutter#170589 is open and there is no official integration nor a stated plan — only early community packages (flutter_app_intents, monterail/intelligence). Apple Watch requires writing the watchOS app in SwiftUI plus a WatchConnectivity bridge either way. On the RN side, EvanBacon/expo-apple-targets is a config plugin that generates Apple targets (widgets, App Clips) and links them outside /ios, and Expo has first-party docs for iOS widgets — this is a real, material RN advantage on exactly this surface. Note RN doesn't escape SwiftUI either; it just has better scaffolding. Also: EAS does not support Watch apps out of the box.

- https://pub.dev/packages/home_widget

- https://github.com/flutter/flutter/issues/170589

- https://pub.dev/packages/flutter_app_intents

- https://github.com/monterail/intelligence

- https://github.com/EvanBacon/expo-apple-targets

- https://expo.dev/blog/how-to-implement-ios-widgets-in-expo-apps

- https://verygood.ventures/blog/wwdc-2026-through-a-flutter-lens/

- https://pub.dev/packages/glance_widget

- https://chethiyakd.medium.com/how-to-build-an-apple-watch-app-with-expo-b254ea3aec6c

### Both ecosystems are healthy in 2026; the old performance argument is dead and shouldn't drive the choice

*Confidence: medium*

Flutter stable is 3.4x / Dart 3.1x with Impeller default-and-only on modern Android. RN's New Architecture (Fabric/JSI, no bridge) has been stable since 0.74 and bridgeless default since 0.78; Expo SDK is now the recommended way to use RN rather than an add-on. One source cites Flutter 46% vs RN 35% market share. Consensus across 2026 comparisons: 'for around 90% of apps, performance is no longer the thing that decides it.' Caveat: these comparison posts are largely agency/SEO content and their market-share and CPU numbers should be treated as soft. For a solo dev the real maintainability question is which language you're fast in — Dart+Flutter gives one toolchain, one layout model, and fewer moving parts than JS+native-modules, which favors the user's stated preference.

- https://www.bolderapps.com/blog-posts/flutter-vs-react-native-in-2026-why-the-new-architecture-and-impeller-2-0-changed-everything

- https://www.pkgpulse.com/guides/react-native-vs-flutter-vs-expo-2026

- https://foresightmobile.com/blog/flutter-vs-react-native-2026

- https://tech-insider.org/flutter-vs-react-native-2026/

### A Flutter web PWA is a poor extra channel for this specific app; if a web channel matters, build it as plain HTML instead

*Confidence: high, **LOAD-BEARING***

Flutter web accessibility is off by default for performance reasons — the semantics DOM tree isn't built until the user hits an invisible aria-label='Enable accessibility' button or the app calls SemanticsBinding.instance.ensureSemantics(). Flutter web paints to canvas with a synthesized semantic layer rather than native HTML, so custom components need explicit SemanticsRole. Combined with Flutter web's large initial payload, that's a bad fit for an app whose entire value proposition is 'instant, zero-load, works in an ER'. Separately, a browser tab is the wrong container for a disability accommodation someone reaches for mid-shutdown — the offline-first argument in the product brief argues against the web channel generally, not just against Flutter's version of it.

- https://docs.flutter.dev/ui/accessibility/web-accessibility

- https://medium.com/flutter/accessibility-in-flutter-on-the-web-51bfc558b7d3

### The accessibility crux is real but over-weighted for THIS app's primary user, which changes the verdict

*Confidence: low, **LOAD-BEARING***

This is my synthesis, not a sourced claim — flag it as an assumption to test. The framework a11y gaps that are hardest in Flutter (Full Keyboard Access, Switch Control, screen-reader tree quality) are motor and vision accommodations. The core user here is someone who can see the screen and tap a tile but cannot speak — the app's job is output, not input navigation. That means the dominant a11y requirements are large touch targets, honored text scaling, high contrast, and reduce-motion, all of which Flutter handles by default. The overlap population is real but secondary: post-seizure users with temporary motor impairment, and autistic users who also use switch access. Verdict: Flutter's a11y weaknesses are unlikely to block the MVP, but they cap how far the app can serve the adjacent motor-impaired AAC audience later — and that's a strategic ceiling worth knowing about now, not a discovery for month nine.

## Product implications

- **[must-have-mvp]** Go with Flutter — the user's preference is validated, but for different reasons than the usual pitch
  - The decisive factors are cold-start (Flutter wins TTFF on both platforms; Impeller killed first-run shader jank, which was exactly the 'first tap feels bad mid-crisis' failure), full control over the visual system (an adult, dark, calm design that deliberately departs from platform defaults is Flutter's home turf — RN's native-view advantage is worth least when you're overriding native look anyway), and solo-dev velocity with one toolchain. App size and TTS are ties and shouldn't have been in the argument. Crucially, Flutter's screen-reader defaults are BETTER than RN's, not worse — the a11y objection to Flutter is narrower than it sounds.
- **[must-have-mvp]** Spike iOS Switch Control and VoiceOver against a throwaway Flutter tile grid before writing real code
  - This is the one unquantified risk that could invalidate the framework choice, and it costs a day to retire. Flutter's Switch Control tracking issue (#126377) has sat open with no assignee since May 2023 and Flutter publishes no support statement. Build a 12-tile grid, turn on Switch Control (item scanning + point scanning) and VoiceOver on a real device, and confirm you can traverse and activate every tile. Do this FIRST — it is cheap now and catastrophic to discover at month six. If it fails badly, that's the signal to reconsider, and it's the only finding here that should move the verdict.
- **[must-have-mvp]** Never hardcode or clamp textScaleFactor; build every tile to grow with TextScaler from day one
  - Flutter honors system text scaling automatically — the framework does the right thing until you break it. The #22480 history shows the common developer instinct is to disable it for layout stability, which silently destroys the accessibility setting for the exact users this app exists for. Use intrinsic/flexible tile heights and let text wrap; test at 200%+ and with Larger Accessibility Sizes on. Auto-shrinking text to fit a fixed tile is the same bug wearing a disguise.
- **[must-have-mvp]** Keep the 'type to speak' field dumb — no TextInputFormatter — and test dictation, Gboard, SwiftKey and Samsung Keyboard early
  - TextInputFormatter is the common thread across Flutter's worst text-input bugs (#171955 Samsung autocorrect race, #133034 dictation breakage on Gboard/SwiftKey). This is Flutter's genuine structural weakness — it reimplements the text field and talks to the IME over a platform channel, where RN uses the real native widget. For an AAC app, a keyboard that drops or garbles characters is a total failure of the core job, and dictation matters specifically for users with fluctuating speech. The mitigation is nearly free: accept raw text, format nothing.
- **[must-have-mvp]** Honor AccessibilityFeatures.boldText, highContrast, invertColors and disableAnimations in the design system
  - Cheap to wire, directly serves the sensory-overload use case, and reduce-motion is arguably a therapeutic requirement rather than a nicety for a user mid-shutdown. Flutter exposes all of these through MediaQuery/AccessibilityFeatures — the only cost is deciding to read them.
- **[should-have-v1]** Cut Home Screen widget, Lock Screen widget, Control Center tile, Action Button, Siri/App Intents, Watch and Wear OS from the MVP entirely
  - This is where Flutter genuinely hurts and where the cost is easiest to avoid by sequencing. home_widget is a data bridge only — you hand-write SwiftUI/WidgetKit and Jetpack Glance regardless. There is no official Flutter App Intents integration and no stated plan (#170589), only early community packages, while SiriKit is on a deprecation path. Ship the grid + type-to-speak + TTS first; add ONE native surface after, and make it the iOS Home Screen widget via home_widget since instant access from the lock/home screen is the highest-value non-core surface for a crisis app.
- **[should-have-v1]** Budget real Swift and Kotlin learning time as a known cost of the Flutter choice — do not pretend it away
  - Every high-value platform surface on the roadmap (widgets, Action Button, App Intents, Watch) requires native code in Flutter, and the tooling gap vs Expo's expo-apple-targets config plugin is real. This is the honest price of the recommendation. If the roadmap's centre of gravity ever shifts to being mostly widgets/Watch/Siri rather than the in-app grid, the Flutter calculus genuinely flips — that's the trigger condition to watch for, and it's worth naming now so it's recognised if it happens.
- **[explicitly-avoid]** Drop the Flutter web PWA channel; if a web reach story is needed later, hand-write plain HTML/JS
  - Flutter web ships accessibility OFF by default for performance, requiring an invisible 'Enable accessibility' button or an explicit ensureSemantics() call, and paints to canvas with a synthesized semantic layer instead of native HTML. Combined with a heavy initial payload, that inverts the product's core promise of instant, zero-load, private access. A hand-written offline HTML page would be smaller, faster, and more accessible than a Flutter web build — and it shares nothing with the Flutter codebase anyway, so there's no reuse argument to preserve. Flutter's multi-platform reach is not a reason to pick it here.

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


YOUR DIMENSION: Flutter vs React Native for THIS SPECIFIC app in 2026. The user prefers Flutter — validate or challenge that honestly.

Research using WebSearch and WebFetch. Consider 2026 state: Flutter (post-Impeller, current stable), React Native (New Architecture / Fabric, Expo).

Answer specifically:
- ACCESSIBILITY: This is the crux. An AAC app must itself be accessible (VoiceOver/TalkBack, Switch Control/Switch Access, Dynamic Type / font scaling, Reduce Motion, high contrast, AssistiveTouch). Flutter renders its own canvas and maps to platform a11y APIs via SemanticsNode — how good is Flutter's accessibility in 2026 really? Known gaps? React Native uses native views — is it materially better for a11y? Find specific evidence, bug reports, and expert opinion. Does Flutter support iOS Switch Control properly? Does Flutter respect iOS Dynamic Type automatically? What about Android Switch Access?
- Does Flutter honor system text scaling by default? What breaks?
- App size: baseline Flutter vs RN app size on iOS and Android.
- Cold start time: Flutter vs RN — matters because user launches mid-crisis.
- Platform integrations needed: Home Screen widget (iOS WidgetKit / Android App Widget), Lock Screen widget, Control Center / Quick Settings tile, Siri Shortcuts / App Intents, Action Button (iPhone 15 Pro+), Apple Watch app, Wear OS. Flutter CANNOT write widgets in Dart — they must be native SwiftUI/Jetpack Glance. How painful is this in Flutter vs RN? Which packages help (home_widget)?
- Text input / IME quality: Flutter's custom text field vs native. Any issues with keyboards, autocorrect, dictation, or third-party keyboards?
- TTS support parity in each ecosystem.
- Long-term maintainability for a solo dev; ecosystem health of both in 2026.
- Desktop/web reach: does Flutter's web/desktop support matter here? Would a web build (PWA, offline via service worker) be a good extra channel?

Give an honest recommendation with reasoning. If Flutter is right, say why. If there are real risks, name them and name the mitigation.
````

</details>
