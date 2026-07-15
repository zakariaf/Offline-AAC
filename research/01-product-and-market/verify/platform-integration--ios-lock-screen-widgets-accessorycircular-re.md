# platform-integration--ios-lock-screen-widgets-accessorycircular-re

> Phase: **verify** · Agent `aa699df997a88c6eb` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** CORRECTED CLAIM: iOS Lock Screen widgets ARE interactive and CAN run AppIntents. Since iOS 17, WidgetKit supports Button(intent:) and Toggle(isOn:intent:) in accessoryCircular and accessoryRectangular on iPhone and iPad; the intent's perform() runs in the widget extension without launching the app. accessoryInline is NOT interactive (glanceable only), and the watchOS-complication analogy applies only to Apple Watch, which is excluded by the docs' explicit "on iPhone and iPad" qualifier.

The actual constraint is authentication, not API capability: "On a locked device, buttons and toggles are inactive and the system doesn't perform actions unless a person authenticates and unlocks their device." A Face-ID-authenticated user still viewing the Lock Screen CAN tap a widget button and have it speak, without entering the app.

REVISED RECOMMENDATION: A lock-screen speaking path is technically buildable and worth prototyping as a secondary fast path (glance-authenticate -> tap -> speak, staying on the Lock Screen). It should NOT be the primary or only speaking surface, because Face ID is unreliable in exactly the distress states this app targets (averted gaze, covered face, lying down). Keep the in-app grid as the guaranteed path. Note also that Flutter cannot implement this — interactive widgets require native Swift/SwiftUI + AppIntents in a widget extension, with TTS invoked from the extension process (a real feasibility constraint worth its own research, since AVSpeechSynthesizer in an extension and audio-session behavior on the Lock Screen need verification). That native-extension cost, not API non-support, is the strongest reason to defer this past MVP.

**Evidence:** The claim's central technical assertion is FALSE and is contradicted by the researcher's own cited source. Apple's "Adding interactivity to widgets and Live Activities" doc (retrieved 2026-07-15 via developer.apple.com/tutorials/data/.../adding-interactivity-to-widgets-and-live-activities.json, resolving the reference identifiers in the list, which render as bare links in HTML scrapes) states verbatim: "Widgets of the following sizes can include buttons and toggles:" followed by WidgetFamily.systemSmall, systemMedium, systemLarge, systemExtraLarge, systemExtraLargePortrait, accessoryCircular ("on iPhone and iPad"), accessoryRectangular ("on iPhone and iPad").

Therefore:
- "Lock Screen widgets are NOT interactive and cannot run AppIntents" — REFUTED. accessoryCircular and accessoryRectangular support Button/Toggle with AppIntent on iPhone and iPad (since iOS 17).
- "Interactive Button/Toggle with AppIntent is a Home Screen / StandBy / Live Activity capability only" — REFUTED.
- "Lock screen widgets behave like watchOS complications: glanceable only" — REFUTED for iOS/iPadOS. The "on iPhone and iPad" qualifier is load-bearing: it EXCLUDES watchOS, so the complication analogy holds only on Apple Watch.
- "Tapping enters the app (optionally deep-linked via .widgetURL())" — this is the fallback for non-interactive widgets, not the only option.

WHAT THE RESEARCHER GOT RIGHT (why this is PARTIALLY_TRUE, not fully REFUTED):
1. accessoryInline is genuinely ABSENT from the supported-families list — inline really is glanceable-only. Confirmed the family exists and is Lock Screen-capable (iOS 16.0+) but it is not in the interactivity list.
2. Their bottom-line recommendation ("do not plan a lock-screen-widget speaking path") is defensible — but for a completely different reason than they gave, which they did not identify.

THE REAL CONSTRAINT (missed by the researcher, materially important): the same Apple doc states verbatim: "On a locked device, buttons and toggles are inactive and the system doesn't perform actions unless a person authenticates and unlocks their device." This is an AUTHENTICATION gate, not an API gate. Once Face ID authenticates (which occurs on glance without leaving the Lock Screen), the buttons become live. So a genuine "glance -> tap -> speak" path exists that never enters the app — a materially better path than the researcher's "tap opens the app," and their advice would have discarded it.

PRODUCT JUDGMENT for this AAC app: the lock-screen path is technically AVAILABLE but should not be the primary speaking surface — Face ID is unreliable during a shutdown/meltdown (averted gaze, covered face, lying down, sensory overload all defeat it), and a speaking button that silently does nothing when authentication fails is worse than no button. This is a UX reliability argument, not the API impossibility asserted. Also note Apple's guidance that "an interaction with a button or toggle should do more than open the app."

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

CLAIM: iOS Lock Screen widgets (accessoryCircular/Rectangular/Inline) are NOT interactive and cannot run AppIntents — this is a design constraint, not a bug
THEIR DETAIL: Lock screen widgets behave like watchOS complications: glanceable only. Tapping enters the app (optionally deep-linked via .widgetURL()). Interactive Button/Toggle with AppIntent is a Home Screen / StandBy / Live Activity capability only. Do not plan a lock-screen-widget speaking path.
THEIR CLAIMED SOURCES: https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications, https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
