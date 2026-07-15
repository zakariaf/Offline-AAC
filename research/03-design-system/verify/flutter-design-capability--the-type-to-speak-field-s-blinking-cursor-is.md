# flutter-design-capability--the-type-to-speak-field-s-blinking-cursor-is

> Phase: **verify** · Agent `a4484747a1b0f9212` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Keep: EditableText does schedule frames while focused (500ms half-period on non-iOS; every-vsync during fades on iOS, which is WORSE than claimed), Impeller has no raster cache (confirmed by maintainer Jonah Williams, flutter/flutter#131206), AccessibilityFeatures.deterministicCursor exists with exactly that doc string, and MediaQueryData does not expose it.

Drop: the claim that deterministicCursor is "corroborating evidence that Flutter treats this as a real cost." It is a motion-accessibility mirror of the iOS "Prefer Non-Blinking Cursor" setting (PR #178102), not a performance signal — and EditableText does not even read it yet (only the test-only debugDeterministicCursor exists in editable_text.dart). Do not plan around reading deterministicCursor to stop the blink; that wiring does not exist in the framework today.

Fix the mechanism: a focused field guarantees continuous FRAME PRODUCTION, but not continuous re-render of an expensive background. RenderEditable's cursor painter is a repaint boundary (rendering/editable.dart:2749) and damage is scoped to the cursor rect, so a costly effect elsewhere on the surface is normally NOT re-rasterized. The real hazard is specifically BackdropFilter (or any backdrop-sampling effect), which reads the surface behind it and forces the damage region to expand to the filter's bounds — that is what turns a 500ms cursor tick into a full-cost frame. State the argument in terms of BackdropFilter, not "any expensive background effect."

For the design decision: if the concern is an expensive background effect, the load-bearing question is whether that effect samples the backdrop, not whether the cursor blinks. Measure with a real trace before designing around this.

**Evidence:** MECHANICAL FACTS: ALL VERIFIED (rare for this corpus).

1. AccessibilityFeatures.deterministicCursor EXISTS. api.flutter.dev/flutter/dart-ui/AccessibilityFeatures-class.html property list: accessibleNavigation, autoPlayAnimatedImages, autoPlayVideos, boldText, deterministicCursor, disableAnimations, highContrast, invertColors, onOffSwitchLabels, reduceMotion, supportsAnnounce. Doc string matches the claim VERBATIM: "The platform is requesting to show deterministic (non-blinking) cursor in editable text fields."

2. MediaQueryData does NOT expose it — CONFIRMED. Verified full property list (size, devicePixelRatio, textScaler, platformBrightness, padding, viewInsets, accessibleNavigation, invertColors, highContrast, onOffSwitchLabels, disableAnimations, boldText, supportsAnnounce, navigationMode, ...). No deterministicCursor. The claimed PlatformDispatcher.instance.accessibilityFeatures workaround is correct.

3. 500ms — CONFIRMED in source. editable_text.dart:109 `const Duration _kCursorBlinkHalfPeriod = Duration(milliseconds: 500);`, exposed as EditableTextState.cursorBlinkInterval.

4. Impeller has no raster cache — CONFIRMED, and traced past the user-issue citation to a maintainer. Jonah Williams in flutter/flutter#131206: "Because of these issues, we've previously decided not to port the raster cache to Impeller."

THREE DEFECTS:

A. THE "CORROBORATING EVIDENCE" INFERENCE IS WRONG. deterministicCursor is a MOTION ACCESSIBILITY feature, not a performance signal. It landed via PR flutter/flutter#178102 ("Add new motion accessibility features to iOS"), mirroring the iOS "Prefer Non-Blinking Cursor" setting for users with vestibular/attention needs. Flutter exposing it is NOT evidence that Flutter regards cursor blink as a rendering cost. The claim recruits an a11y API as a perf citation.

B. EditableText DOES NOT CONSUME IT. Grep of master packages/flutter/lib/src/widgets/editable_text.dart: `AccessibilityFeatures.deterministicCursor` appears ZERO times; only `EditableText.debugDeterministicCursor` (a test-only hook, lines 4814, 4855) appears. The platform signal is plumbed into dart:ui but not wired to the widget — the field still blinks for users who requested otherwise.

C. "ROUGHLY EVERY 500ms" UNDERSTATES iOS. Two code paths at editable_text.dart:4858-4865. Non-iOS: `_cursorTimer = Timer.periodic(_kCursorBlinkHalfPeriod, ...)` — one frame per 500ms, as claimed. iOS (cursorOpacityAnimates=true, the default for CupertinoTextField and Material-on-iOS): `_cursorBlinkOpacityController.animateWith(_iosBlinkCursorSimulation).whenComplete(_onCursorTick)` — a ticker-driven opacity fade producing a frame EVERY VSYNC during each transition, not one per 500ms.

CONCLUSION DOES NOT FOLLOW CLEANLY: rendering/editable.dart:2749 shows the cursor's foreground/background painter is `isRepaintBoundary => true`, so the blink dirties only that layer. The claim's own wording ("re-renders the damage region") concedes damage is scoped to the cursor rect (~2x20px). If damage is scoped to the cursor, an expensive background effect ELSEWHERE is not re-rendered — which argues against the claim's conclusion rather than for it. The case that would rescue the argument is BackdropFilter, which samples the backdrop and forces damage expansion to the filter's bounds — but the claim never names it. App-specific premise ("same surface as the grid") is not verifiable from public sources.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "flutter-design-capability" made this claim, and a design decision depends on it.

CLAIM: The type-to-speak field's blinking cursor is the hidden frame-scheduler that breaks the 'static UI = free' reasoning.
DETAIL: EditableText blinks its cursor while focused, scheduling a frame roughly every 500ms. With no raster cache in Impeller, each of those frames re-renders the damage region. This is the concrete reason an expensive background effect is NOT free in this app: the type-to-speak field is on the SAME surface as the grid, so a focused field means continuous frame production. Corroborating evidence that Flutter treats this as a real cost: dart:ui AccessibilityFeatures now exposes `deterministicCursor` — 'show deterministic (non-blinking) cursor in editable text fields' — though note MediaQueryData does NOT expose it, so you cannot read it via MediaQuery; you'd need ui.window/PlatformDispatcher.instance.accessibilityFeatures.
CLAIMED SOURCES: https://api.flutter.dev/flutter/dart-ui/AccessibilityFeatures-class.html, https://api.flutter.dev/flutter/widgets/MediaQueryData-class.html
CONFIDENCE: medium

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
