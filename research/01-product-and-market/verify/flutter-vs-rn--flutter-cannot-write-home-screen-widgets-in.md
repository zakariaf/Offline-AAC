# flutter-vs-rn--flutter-cannot-write-home-screen-widgets-in

> Phase: **verify** · Agent `a0a4ebe5c69cbc148` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep the claim as stated — "Flutter cannot write Home Screen widgets in Dart and has no official App Intents story; Expo's tooling here is genuinely better" is correct and fully substantiated. Amend one detail: the hedge "RN doesn't escape SwiftUI either; it just has better scaffolding" is outdated as of Expo SDK 57. Expo ships an official first-party expo-widgets package that authors iOS home screen widgets and Live Activities in TypeScript via @expo/ui/swift-ui components "without writing native code" — no hand-written SwiftUI required for widget UI. Caveats: iOS-only, dev build required (not Expo Go), and it does NOT deliver App Intents (interaction is limited to button/toggle events via addUserInteractionListener()). Corrected framing: on home screen widgets specifically, Expo now has a first-party no-native-code path while Flutter's mature option (home_widget) is explicitly a data bridge requiring hand-written WidgetKit/Glance; on App Intents, BOTH ecosystems still require native Swift, so that half is a wash rather than an RN win. Separately, note the researcher's Apple Watch and EAS claims were not independently verified.

**Evidence:** Headline claim CONFIRMED on every load-bearing point, and the supporting detail is almost entirely accurate. One specific is outdated — and it makes the claim MORE true, not less.

VERIFIED AGAINST PRIMARY SOURCES:
1. home_widget README states verbatim: "HomeWidget does **not** allow writing Widgets with Flutter itself. It still requires writing the Widgets with native code." Package is actively maintained (v0.9.3, published ~37 days ago; iOS+Android). Changelog confirms Jetpack Glance Support shipped as a feature (0.5.0 Flutter stable / 0.6.0 Flutter beta), matching "home_widget added Glance support to reduce the Android half."
2. flutter/flutter#170589 "Support iOS/macOS app intents" — OPEN as of 2026-07-15, opened 2025-06-13, labeled P3, assigned to iOS platform team. Issue body confirms the structural blocker researcher implied: App Intents must be defined in Swift at build time rather than runtime, making a plugin approach hard. No official integration, no stated plan. CONFIRMED.
3. Very Good Ventures WWDC-2026 post (published 2026-06-12) states verbatim: "SiriKit is now on a deprecation path, and Apple is directing new work to App Intents" and "There is no official App Intents integration in Flutter, neither a clear plan to create one yet." Both quotes as characterized. CONFIRMED.
4. flutter_app_intents: v0.7.0, published 9 months ago, 6 likes, ~1,680 weekly downloads, UNVERIFIED uploader (cbonello), MIT. Community package, not official. CONFIRMED as "early community package."
5. glance_widget: v1.0.1, published 3 months ago, 7 likes, 69 weekly downloads, pub points 150. "Young and unproven — do not bet a shipping feature on it" is well-calibrated. ADDITIONAL SUPPORT: its own docs concede the iOS path still requires creating a Widget Extension target in Xcode, so its "zero native code" claim is already self-qualified.
6. expo-apple-targets: 1.4k stars, actively maintained, generates Apple targets (widgets, App Clips, Safari extensions) into a root /targets dir linked into the Xcode project at prebuild — i.e. "outside /ios," exactly as described. Correctly identified as Evan Bacon's community/personal project rather than official Expo. Requires Expo SDK 53+, Xcode 16, CocoaPods 1.16.2+, macOS 15+.
7. No official Flutter App Intents or Dart-authored-widget support announced through Flutter 3.44 (Google I/O 2026); 2026 roadmap priorities are GenUI, Material/Cupertino decoupling, embedded systems.

THE ONE ERROR (an under-claim): Researcher wrote "Note RN doesn't escape SwiftUI either; it just has better scaffolding." This is OUTDATED as of Expo SDK 57. Expo now ships an official first-party expo-widgets SDK package (docs.expo.dev/versions/latest/sdk/widgets/, npm expo-widgets v57.0.3) whose docs state verbatim: "expo-widgets enables the creation of iOS home screen widgets and Live Activities using Expo UI components, without writing native code." Widget layouts are authored in JS/TS via @expo/ui/swift-ui components and modifiers. Not marked experimental/alpha; the underlying @expo/ui SwiftUI (iOS) and Jetpack Compose (Android) APIs went stable in SDK 56. Constraints: iOS-only, not available in Expo Go (dev build required), and interaction is limited to addUserInteractionListener() for button/toggle events — it does NOT provide App Intents. So RN does now partially escape hand-written SwiftUI for widgets, widening rather than narrowing the gap the researcher described. The researcher leaned on a community config plugin (expo-apple-targets) and a blog post and missed Expo's own SDK package.

UNVERIFIED (not independently checked, low materiality): the Apple Watch / WatchConnectivity assertions and "EAS does not support Watch apps out of the box." These are plausible and consistent with the cited Medium walkthrough existing at all, but I did not confirm them against primary Expo/EAS docs. They do not bear on the headline claim.

NET: verdict PARTIALLY_TRUE only because one stated specific is factually outdated. The claim's direction, conclusion, and decision-relevance are sound and if anything understated. Researcher's stated confidence of "high" is justified.

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


You are an ADVERSARIAL FACT-CHECKER. Another researcher made this claim while researching the dimension "flutter-vs-rn". A product decision depends on it, so it must be right.

CLAIM: Flutter cannot write Home Screen widgets in Dart and has no official App Intents story; Expo's tooling here is genuinely better
THEIR DETAIL: home_widget's own docs state it 'does not allow writing Widgets with Flutter itself. It still requires writing the Widgets with native code' — it is a data bridge (App Groups on iOS, SharedPreferences on Android) plus an update trigger. You write SwiftUI/WidgetKit and Jetpack Glance by hand; home_widget added Glance support to reduce the Android half. glance_widget claims zero-native-code widgets on both platforms but is young and unproven — do not bet a shipping feature on it. For App Intents (which Siri Shortcuts now routes through; SiriKit is on a deprecation path), flutter/flutter#170589 is open and there is no official integration nor a stated plan — only early community packages (flutter_app_intents, monterail/intelligence). Apple Watch requires writing the watchOS app in SwiftUI plus a WatchConnectivity bridge either way. On the RN side, EvanBacon/expo-apple-targets is a config plugin that generates Apple targets (widgets, App Clips) and links them outside /ios, and Expo has first-party docs for iOS widgets — this is a real, material RN advantage on exactly this surface. Note RN doesn't escape SwiftUI either; it just has better scaffolding. Also: EAS does not support Watch apps out of the box.
THEIR CLAIMED SOURCES: https://pub.dev/packages/home_widget, https://github.com/flutter/flutter/issues/170589, https://pub.dev/packages/flutter_app_intents, https://github.com/monterail/intelligence, https://github.com/EvanBacon/expo-apple-targets, https://expo.dev/blog/how-to-implement-ios-widgets-in-expo-apps, https://verygood.ventures/blog/wwdc-2026-through-a-flutter-lens/, https://pub.dev/packages/glance_widget, https://chethiyakd.medium.com/how-to-build-an-apple-watch-app-with-expo-b254ea3aec6c
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
