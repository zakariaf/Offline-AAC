# platform-integration--ios-18-controls-controlwidget-run-appintents

> Phase: **verify** · Agent `abc0128d9d86f5a35` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** Claim stands as written; no correction needed. Three material caveats the researcher should carry forward, none of which contradict the claim:

(a) SCOPE: Lock Screen controls require a Face ID iPhone. Touch ID models (iPhone SE) get Control Center and no Lock Screen control slots — so "two always-visible one-tap-from-lock buttons" is not universal across the iOS install base. Action button is iPhone 15 Pro/Pro Max and all iPhone 16 models (incl. 16e), not iPhone 15 non-Pro.

(b) THE UNPROVEN STEP — biggest real risk: the claim establishes that a control can fire an AppIntent from lock with no auth, but NOT that the intent can speak. perform() runs in the widget extension process, and AVAudioSession configuration from extensions is a documented trouble spot (widget extensions failing audio session init). AudioPlaybackIntent exists and is the intended vehicle, but "control tile -> AVSpeechSynthesizer speaks aloud while locked" is not demonstrated by any source found and needs a hands-on spike before any roadmap depends on it. The claim's own "shortest THEORETICAL time-to-word" wording is appropriately hedged; treat it as theoretical until proven.

(c) STACK COST: this is iOS-only and entirely native Swift/WidgetKit + App Intents. No Flutter plugin exposes ControlWidget. For a Flutter target stack this means a hand-written app-extension target, an App Group for shared phrase storage, and no Android analog (Android's closest equivalents are Quick Settings tiles and app shortcuts, which behave differently). Budget it as platform-specific work, not a cross-platform feature.

**Evidence:** Attempted refutation on four fronts; all four sub-claims survived against primary Apple sources.

1) ControlWidgetButton takes an AppIntent — CONFIRMED. Apple's WidgetKit docs (fetched via developer.apple.com JSON API, since the HTML pages are JS-rendered and returned no usable content) list init(action:label:), init(action:label:actionLabel:), and init(_:action:actionLabel:), with a generic `Action` parameter. Availability: iOS 18.0+, iPadOS 18.0+, Mac Catalyst 18.0+, macOS 26.0+, watchOS 26.0+.

2) ControlWidgetToggle takes SetValueIntent<Bool> — CONFIRMED verbatim in WWDC24 session 10157: "This app intent is a SetValueIntent since it sets the timer's 'Running' state to the value provided by the system," with code showing `struct ToggleTimerIntent: SetValueIntent, LiveActivityIntent` and `@Parameter var value: Bool`. WidgetKit sets the value before perform() is called.

3) Third-party controls can replace the two default Lock Screen controls — CONFIRMED. WWDC24 10157 shows the control "working on the Lock Screen and with the Action button." MacRumors confirms the flashlight/camera buttons are removable and replaceable with third-party app controls, with exactly two slots ("Repeat for the second Lock Screen button if desired"). Still true in iOS 26, the current release as of 2026-07-15.

4) Action button binding on iPhone 15 Pro+ — CONFIRMED. Controls are available in the Action button picker on iPhone 15 Pro and all iPhone 16 models. Assignment is user-driven via Settings UI; there is no programmatic API to bind a control to the Action button (the developer only publishes the control; the user assigns it).

DECISIVE BONUS FINDING (strengthens rather than refutes): the obvious refutation path was that a locked-device tap would demand Face ID, destroying the time-to-word argument. It does not. AppIntent.authenticationPolicy defaults to IntentAuthenticationPolicy.alwaysAllowed — Apple's docs: "The default value of this property is alwaysAllowed, which allows the intent to run without authentication, including when the device is locked." The enum's three cases are alwaysAllowed ("allows the app intent to run at any time, including when the device is locked"), requiresAuthentication, and requiresLocalDeviceAuthentication. Note the corollary: setting openAppWhenRun = true, or any intent that opens the app, forfeits this — the zero-auth path only holds for a background intent.

The researcher's "high" confidence is warranted for the API-level facts. Their sources check out and were not misread.

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

CLAIM: iOS 18 Controls (ControlWidget) run AppIntents, can REPLACE the Lock Screen flashlight/camera buttons, and can be bound to the Action Button on iPhone 15 Pro+
THEIR DETAIL: ControlWidgetButton takes an AppIntent action; ControlWidgetToggle takes a SetValueIntent<Bool>. Third-party controls can be mapped to the Action button and can replace the two default Lock Screen controls. This gives up to two always-visible, one-tap-from-lock phrase buttons plus a physical button — the shortest theoretical time-to-word on iOS.
THEIR CLAIMED SOURCES: https://developer.apple.com/videos/play/wwdc2024/10157/, https://rudrank.com/exploring-widgetkit-first-control-widget-ios-18-swiftui, https://www.macstories.net/roundups/control-center-and-lock-screen-controls-a-roundupof-my-favorites/
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
