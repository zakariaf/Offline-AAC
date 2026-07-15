# tile-grid-design--edge-to-edge-is-forced-on-android-16-and-can

> Phase: **verify** · Agent `ac43dcca38d5e2332` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Two corrections, neither of which overturns the resolution.

1. Fix the stale Flutter fact. Not "Flutter has targeted Android 15 by default since 3.27." Correct as of stable 3.44: Flutter's default targetSdk is 36 (verified in FlutterExtension.kt on the stable branch: compileSdk 36, minSdk 24, targetSdk 36; bump landed master 2025-05-12 via PR #168577). Flutter supports API 24–36. The 3.27 fact is history, not current state — and the current state makes the mandate MORE binding on a default Flutter app, not less.

2. Fix the scope. Not "edge-to-edge is forced on Android 16." Correct: edge-to-edge is forced for apps TARGETING Android 16 (API 36) WHEN RUNNING ON an Android 16 device; windowOptOutEdgeToEdgeEnforcement still works for such apps on Android 15 devices, and apps still targeting 35 retain the opt-out. Since Flutter 3.44 defaults to targetSdk 36, the practical conclusion for this project is unchanged: the opt-out is unavailable.

3. Separate the taste from the mandate. "Full-bleed plane, inset grid" is defensible as a design position and is compatible with the platform requirement — but "a grid crammed to the bezel reads cheap" is an unsourced aesthetic preference, not a finding. State it as a design decision the team is making, not as something the Android or Flutter docs imply. The platform forces the plane to be edge-to-edge; it says nothing whatsoever about where the tiles sit. That is the claim's own point, and it should be applied to the claim's own aesthetics.

**Evidence:** I could not refute the core mechanism — it survives primary-source checking. But two things are wrong, and one of the claim's own supporting facts is version-rotted.

CONFIRMED (verbatim from developer.android.com/about/versions/16/behavior-changes-16):
"For apps targeting Android 16 (API level 36), R.attr#windowOptOutEdgeToEdgeEnforcement is deprecated and disabled, and your app can't opt-out of going edge-to-edge."
The same page confirms the Android 15 opt-out the claim describes, and scopes it precisely:
- targets 36 + running on Android 15 device → opt-out "continues to work"
- targets 36 + running on Android 16 device → opt-out "is disabled"

CONFIRMED: docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge — SystemUiMode.edgeToEdge default landed in 3.26.0-0.0.pre, stable in 3.27; prior to 3.27 Flutter targeted Android 14 and did not opt into edge-to-edge.

CONFIRMED: SafeArea exists on api.flutter.dev with that exact name ("A widget that insets its child with sufficient padding to avoid intrusions by the operating system"), top/bottom/left/right all default true, plus a `minimum` parameter. The named API in the resolution is real.

FAILURE MODE 3 — VERSION ROT (the claim's own detail is stale): "Flutter has targeted Android 15 by default since 3.27" was true in 3.27 but is NOT true at 3.44. I read the actual stable branch source, packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt: compileSdkVersion 36, minSdkVersion 24, **targetSdkVersion 36**. The targetSdk bump to 36 landed on master 2025-05-12 (flutter/flutter PR #168577, split out from #166464 which did compileSdk 36 / AGP 8.9.1 / Gradle 8.11.1 for rollback safety). Note this rot cuts IN FAVOR of the conclusion, not against it — a default Flutter 3.44 app targets 36, so it is squarely inside the enforcement.

SCOPE ERROR in the headline: "Edge-to-edge is FORCED on Android 16" is loose. The enforcement is targetSdk-conditioned, not OS-conditioned. An app targeting SDK 35 running on an Android 16 device can still opt out — the trigger is targeting 36 AND running on 16. "Forced on Android 16" would wrongly imply the OS forces it on all apps.

METHODOLOGY WARNING (failure mode 1/2) — the aesthetic half is not evidence: "the full-bleed-plane/inset-grid composition is also the more beautiful answer — a grid crammed to the bezel reads cheap" has zero sourcing and none of the three cited sources speak to it. This is taste asserted in the same breath as a verified platform mandate, which is exactly how folklore acquires borrowed authority. The composition may well be right, but nothing here establishes it, and it should not inherit the confidence of the Android 16 citation.

One caveat I did not chase: SafeArea reads MediaQuery padding, which under edge-to-edge can differ from viewPadding depending on how insets are consumed. If the grid must clear the gesture navigation bar in all states, SafeArea alone is worth testing rather than assuming.

The claim's central logical move — that window treatment and target insetting are two separate decisions, and that the mandate settles only the first — is sound and is what the sources actually support.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "tile-grid-design" made this claim, and a design decision depends on it.

CLAIM: Edge-to-edge is FORCED on Android 16 and cannot be opted out — but this settles nothing about the grid, because the window and the targets are different questions
DETAIL: Android 15 (targetSdk 35) enforces edge-to-edge by default but allows opt-out via R.attr#windowOptOutEdgeToEdgeEnforcement (e.g. a values-35 resource dir). For apps targeting Android 16 (targetSdk 36) that attribute is DEPRECATED AND DISABLED — the app cannot opt out. Flutter has targeted Android 15 by default since 3.27 and sets SystemUiMode.edgeToEdge as the default. Resolution: the background PLANE is edge-to-edge (mandatory), the tile grid is inset via SafeArea + margin. These were never the same decision, and the full-bleed-plane/inset-grid composition is also the more beautiful answer — a grid crammed to the bezel reads cheap.
CLAIMED SOURCES: https://developer.android.com/about/versions/16/behavior-changes-16, https://medium.com/androiddevelopers/insets-handling-tips-for-android-15s-edge-to-edge-enforcement-872774e8839b, https://docs.flutter.dev/release/breaking-changes/default-systemuimode-edge-to-edge
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
