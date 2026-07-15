# flutter-vs-rn--flutter-honors-system-text-scaling-by-defaul

> Phase: **verify** · Agent `ac40dfd11b36f1c60` · Run `wf_3a8e3c64-43a`

## Result

## Verdict

**CONFIRMED**

**Correction:** No correction to the substance. Two refinements: (1) "Flutter text widgets respect the OS setting automatically" is true for Text/Text.rich but NOT for RichText, whose constructor defaults to TextScaler.noScaling — system scaling is ignored there unless you explicitly pass MediaQuery.textScalerOf(context). (2) One of the three cited sources is mis-attributed: the accessibility-and-internationalization/accessibility overview page does NOT contain the text-scaling statement (it only says "The UI should remain legible and usable at very large scale factors" in its release checklist). The verbatim support comes from docs.flutter.dev/ui/accessibility/ui-design-and-styling. Additionally, the self-inflicted-risk point is now stronger than stated: textScaleFactor is deprecated (after v3.12.0-2.0.pre) precisely because Android 14 nonlinear scaling (stable in Flutter 3.16) cannot be represented by a single double.

**Evidence:** I attempted to refute this on five independent fronts and every specific held against primary sources.

1. THE CORE CLAIM — confirmed nearly verbatim by the official docs. docs.flutter.dev/ui/accessibility/ui-design-and-styling states: "Both Android and iOS contain system settings to configure the desired font sizes used by apps. Flutter text widgets respect this OS setting when determining font sizes" and "Font sizes are calculated automatically by Flutter based on the OS setting."

2. THE LAYOUT-NOT-SETTING FRAMING — confirmed by the same page, which places the burden squarely on the developer: "as a developer you should make sure your layout has enough room to render all its contents when the font sizes are increased. For example, you can test all parts of your app on a small-screen device configured to use the largest font setting." The Android 14 migration guide independently reinforces this, telling devs to "test with maximum font size (200%)" — the exact 200% figure the researcher cited.

3. ISSUE #22480 — their reading is exactly right, which is the kind of detail that is usually where a claim like this falls apart. Title: "Larger Text setting scale the app font size in iOS," opened by ParkinWu on 2018-09-30, now closed. The reporter calls the scaling "a great feature" and asks "is there some properties or configs that i can disable it?" He is asking how to OPT OUT. The issue is evidence the setting works, not that it's ignored — precisely as characterized. (Sibling issue #25587 is literally titled "Disable Dynamic Type on iOS," same direction.)

4. THE APIs — all real and correctly named. MediaQuery.textScalerOf(context) exists and returns a TextScaler reflecting the system font scaling preference (falling back to TextScaler.noScaling with no ancestor). AccessibilityFeatures does expose boldText, highContrast, invertColors, disableAnimations, AND reduceMotion — all five, as claimed.

5. THE SELF-INFLICTED-RISK POINT — substantiated, and if anything the researcher is UNDER-stating it. textScaleFactor was deprecated after v3.12.0-2.0.pre in favor of TextScaler, because Android 14 nonlinear scaling (landed 3.14.0-11.0.pre, stable in 3.16) scales large text at a lesser rate and can't be expressed as one double. So hardcoding textScaleFactor: 1.0 not only breaks the user's setting, it now uses a deprecated API that cannot represent the platform's actual scaling curve. This makes the claim MORE true in 2026 than when written.

ONE MINOR CAVEAT (does not change the verdict): the blanket phrasing "Flutter text widgets respect the OS setting automatically" has a real exception — RichText's constructor defaults to `TextScaler textScaler = TextScaler.noScaling`, so RichText does NOT pick up system scaling unless you explicitly pass MediaQuery.textScalerOf(context). This is a low-level widget (Text and Text.rich do scale automatically), and it arguably strengthens rather than weakens the "self-inflicted" thesis — but it means the failure can come from a widget's default, not only from a developer actively hardcoding a value. Worth knowing for an AAC grid where tiles may use RichText for mixed styling.

PRODUCT BEARING: the decision this supports is sound. For this AAC app, Flutter will honor a distressed user's 200% font setting for free; the engineering work is fluid/wrapping tile layouts (avoid fixed-height tiles), not fighting the framework. The one thing to add to the build checklist: never clamp textScaler, and pass MediaQuery.textScalerOf(context) explicitly to any RichText.

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

CLAIM: Flutter honors system text scaling by default — the failure mode is layout, not the setting being ignored
THEIR DETAIL: Flutter text widgets respect the OS font-size setting automatically via TextScaler; MediaQuery.textScalerOf(context) reads the user's chosen scale. flutter/flutter#22480 (opened 2018, now closed) was a developer asking how to DISABLE iOS Larger Text scaling — i.e. the complaint was that it works, not that it doesn't. The real risk is self-inflicted: if you hardcode textScaleFactor: 1.0 or clamp it, you silently break the user's accessibility setting. AccessibilityFeatures also exposes boldText, highContrast, invertColors, disableAnimations/reduceMotion. What actually breaks at 200%+ scale is fixed-height tiles and grids overflowing — a design problem, not a framework problem.
THEIR CLAIMED SOURCES: https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility, https://github.com/flutter/flutter/issues/22480, https://docs.flutter.dev/ui/accessibility/ui-design-and-styling
THEIR CONFIDENCE: high

Your job is to REFUTE this claim. Use WebSearch and WebFetch to independently check it. Today is 2026-07-15 — a claim that was true in 2023 may be false now (prices change, APIs change, packages get abandoned, features ship). Check whether the claim is outdated, overstated, based on a misread, or simply invented. Verify prices, version numbers, API names, license terms, and statistics DIRECTLY against primary sources where possible.

Default to refuted=true if you cannot independently substantiate it. Be skeptical but fair: if it checks out, say CONFIRMED. If it is directionally right but the specifics are wrong, say PARTIALLY_TRUE and give the correction. If no source can settle it, say UNVERIFIABLE.
````

</details>
