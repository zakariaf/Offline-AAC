# color-system--mediaquery-highcontrast-is-ios-only-and-alwa

> Phase: **verify** · Agent `a9dd9dcce0aec8b66` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** The design decision stands — the in-app one-tap theme switcher IS the only mechanism that will work on Android, and MediaQuery.highContrastOf(context) will silently never fire there. Confirm this using the stronger primary source: dart:ui AccessibilityFeatures.highContrast, which states plainly "Only supported on iOS." Two corrections to the supporting detail: (1) ColorScheme.fromSeed's contrastLevel range is -1.0 to 1.0, NOT 0.0 to 1.0 — Flutter documents "0.0 is the default (normal); -1.0 is the lowest; 1.0 is the highest." The 0.5="medium" mapping is a material-color-utilities convention and is not documented in the Flutter API or on m3.material.io; do not attribute it to "the M3 spec." (2) flutter/flutter#48418 is CLOSED and was FIXED by PR #48811; it was an iOS plumbing bug, not an Android tracker. Stop citing it as live evidence of the Android gap — the correct framing is that Android support is documented out of scope, not broken and pending. Drop the issue citation and cite AccessibilityFeatures.highContrast instead.

**Evidence:** CORE CLAIM CONFIRMED — and by a stronger source than cited. (1) api.flutter.dev/flutter/widgets/MediaQueryData/highContrast.html states verbatim: "Whether the user requested a high contrast between foreground and background content on iOS, via Settings -> Accessibility -> Increase Contrast. This flag is currently only updated on iOS devices that are running iOS 13 or above." The claim's quote is accurate. (2) DECISIVE, UNCITED: the underlying dart:ui flag that MediaQueryData derives from — api.flutter.dev/flutter/dart-ui/AccessibilityFeatures/highContrast.html — states: "The platform is requesting that UI be rendered with darker colors. Only supported on iOS." Android never sets the bit. MediaQuery.highContrastOf(context) returns false permanently on Android. The operative recommendation (do not gate the HC theme on this flag; drive from app state; read the flag opportunistically for future iOS) is correct and the design decision is safe. (3) ColorScheme.fromSeed's contrastLevel parameter EXISTS, is not deprecated, and is the right knob for generated schemes — confirmed on api.flutter.dev.

SPECIFICS WRONG IN TWO PLACES:

ERROR 1 (invented specific / range rot): Claim says contrastLevel is "0.0 normal / 0.5 medium / 1.0 high, per M3 spec". Flutter's actual doc: "The contrastLevel parameter indicates the contrast level between color pairs, such as primary and onPrimary. 0.0 is the default (normal); -1.0 is the lowest; 1.0 is the highest." Real range is -1.0 to 1.0. The claim omits the negative half and asserts 0.5="medium" as being "per M3 spec" — that value is not named in the Flutter API docs nor on the m3.material.io pages returned by search; the 0.0/0.5/1.0 convention originates in the material-color-utilities library, not the spec pages the claim attributes it to.

ERROR 2 (citation argues against itself): flutter/flutter#48418 title is quoted correctly ("MediaQuery highContrast is always false"), but the issue is CLOSED, resolved by PR #48811. It was an iOS-side bug — the flag was not being plumbed from AccessibilityFeatures into MediaQueryData at all (reporter: "the value is set to false by default but never assigned to other value. Only set to true in some tests."), tested on iOS 13.3 simulator, labeled platform-iOS. It is evidence that iOS was REPAIRED, not evidence of the Android gap. Citing it in present tense as a tracker for the Android behavior is backwards. This matters for the decision: a tracked open bug implies "wait for a fix," whereas the Android gap is documented intended scope and will not arrive without a custom platform channel.

UNVERIFIED (stated but not substantiated here): the claim's characterization of Android's "high contrast text" setting as painting outlines behind text. Directionally consistent with the Android accessibility setting but not confirmed against developer.android.com in this pass; it is not load-bearing for the decision.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "color-system" made this claim, and a design decision depends on it.

CLAIM: MediaQuery.highContrast is iOS-ONLY and always false on Android — a blocker for this Android-first app
DETAIL: Flutter's own API docs for MediaQueryData.highContrast state: 'This flag is currently only updated on iOS devices that are running iOS 13 or above' (it maps to iOS Settings → Accessibility → Increase Contrast). flutter/flutter#48418 tracks 'MediaQuery highContrast is always false.' Android's own 'high contrast text' setting is a separate, cruder OS-level force (it paints outlines behind text) and is not surfaced through this flag. Consequence: the brief's in-app one-tap theme switcher is not a nicety, it is the ONLY mechanism that will work on the target platform. Do not gate the HC theme behind MediaQuery.highContrastOf(context) — it will silently never fire. Read the flag if present (free win on any future iOS build) but drive the theme from app state. Related and useful: ColorScheme.fromSeed exposes contrastLevel (0.0 normal / 0.5 medium / 1.0 high, per M3 spec), which is the right knob if you generate rather than hand-author.
CLAIMED SOURCES: https://api.flutter.dev/flutter/widgets/MediaQueryData/highContrast.html, https://github.com/flutter/flutter/issues/48418, https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html
CONFIDENCE: high

REFUTE IT. Use WebSearch and WebFetch against PRIMARY sources: m3.material.io, developer.apple.com, api.flutter.dev, docs.flutter.dev, the actual type foundry, the actual paper.

Hunt for these failure modes, in order of likelihood:
1. **Marketing repeated as research.** Google's M3 Expressive claims (46 studies, 18,000 participants, "4x faster") and Lexend's readability claims are the specific hazards. Did anyone publish a methodology? Is it peer-reviewed, or is it a blog post? If a number has no methodology behind it, SAY SO — a design direction is being justified with it.
2. **Design folklore presented as evidence.** "Autistic people prefer muted colors", "sans-serif is more legible", "the aesthetic-usability effect", color psychology. Find the actual study, check the sample and whether it replicated, and check whether the popular claim matches what the paper found.
3. **Version/API rot.** Flutter lags the Material spec — a spec feature is NOT a Flutter feature. If the claim says Flutter can do something, VERIFY on api.flutter.dev or the release notes. Check whether a named API exists with that exact name.
4. **Invented specifics** — hex values, token names, type sizes, shape counts, font axes, license terms. If it's specific, verify it's real.
5. **License claims** about typefaces or assets. Verify against the actual foundry/repo.

Default to refuted=true if you cannot substantiate it. CONFIRMED if it checks out. PARTIALLY_TRUE + correction if directionally right but wrong in the specifics. UNVERIFIABLE if nothing settles it — say so plainly rather than guessing.
````

</details>
