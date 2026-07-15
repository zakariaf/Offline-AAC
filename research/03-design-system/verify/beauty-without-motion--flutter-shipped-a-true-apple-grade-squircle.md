# beauty-without-motion--flutter-shipped-a-true-apple-grade-squircle

> Phase: **verify** · Agent `a7dda5ff0a1d166b8` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**

**Correction:** Two fixes. (1) PR #167784 is "[Cupertino] Apply RSuperellipse to most Cupertino widgets" — it added the shape, it did not revert it. The revert-to-RRect-for-Web-cost PR is #171830, "[Cupertino] Make some widgets no longer use RSuperellipse." Swap the citation. (2) The pre-API-29 Skia fallback landed in Flutter 3.29.2 (PR #165075), not 3.29.3. Additionally, "the fast path applies" holds only on API 29+; on API 28 and below the app runs on Skia, where RSuperellipse cost is undocumented and unmeasured — do not assume the Impeller fast path there.

**Evidence:** I could not refute the central thesis — it survives primary-source checking. But two named specifics are wrong, one of them a citation that says the OPPOSITE of what the claim asserts.

WHAT CHECKS OUT (verified on primary sources):

1. The APIs exist with those exact names. api.flutter.dev serves RoundedSuperellipseBorder (painting library, "mimic the rounded rectangle style commonly seen in iOS design") and RSuperellipse (dart:ui). The 3.32.0 release notes list PR #161111 (add clipRSuperellipse, use for dialogs), #166303 (add RoundedSuperellipseBorder, apply to CupertinoActionSheet), #165744 (drawRSuperellipse), and #164755 ("RoundSuperellipse algorithm v3: Ultrawideband heuristic formula"). Impeller has round_superellipse_param.cc. 3.32 stable = May 20, 2025. CONFIRMED.

2. Issue #91523 is real and is exactly what's claimed: "ContinuousRectangleBorder doesn't match iOS implementation" — reporter notes Flutter needs ~24 radius to match SwiftUI's ~10.2, which is where 2.3529 comes from. CONFIRMED.

3. RydMike's squircle_study README confirms every sub-detail, including the counterintuitive ones: RoundedSuperellipseBorder is "the only super ellipse shape that is a match for the one used in iOS on UI elements" and "the only known shape that can handle all edge cases correctly"; ContinuousRectangleBorder is "NOT at all an acceptable option"; figma_squircle "claims to be identical to the iOS squircle shape" at smoothing 0.6; the multiplier makes degeneration happen EARLIER ("The TIE fighter shape issue occurs earlier since the radius ContinuousRectangleBorder is multiplied by 2.3529"); and smooth_corner's "performance of SmoothCorner has no known feedback, since it is not used as much as the FigmaSquircle." All CONFIRMED, including the researcher's nuance that smooth_corner's silence is non-adoption, not proof of good perf.

4. The Web/RRect fallback is real. Issue #163718 ([Web] Implement RSuperellipse on Web): "Currently drawing or clipping an RSE falls back as RRect on Web. Part of the reason is because RSE has to be implemented as Bezier paths on Web, but historically we've found that such implementations have poor performance." CONFIRMED.

WHAT IS WRONG:

5. PR #167784 IS MISATTRIBUTED — it says the opposite. #167784 is "[Cupertino] Apply RSuperellipse to most Cupertino widgets" by dkwingsmt. It APPLIED the new shape; it did not revert anything. The actual revert is PR #171830, "[Cupertino] Make some widgets no longer use RSuperellipse": "These shapes are either too small to make a difference between the two shapes, or indifferent at all. After observing how costly RSuperellipses are on Web, I decided that this is a good compromise." The claim cited the thesis PR as if it were the antithesis PR. The underlying fact (some Cupertino widgets were reverted to RRect over Web cost) is true — the citation is not.

6. The Impeller version is off by a patch. PR #165075 ("Change fallback behavior for devices pre API 29 to Skia regardless of Impeller state," jonahwilliams) landed in 3.29.2, not 3.29.3, cherry-picked via #165090. Motivation was "a large amount of crashes coming from older devices." The substance (API 29+ Impeller, API 28 and below Skia) is correct and still current: docs.flutter.dev/perf/impeller says "Impeller is available and enabled by default on Android API 29+."

ONE UNVERIFIED ASSUMPTION THE DESIGN DECISION RESTS ON:

7. "This project is Android-first with Impeller, so the fast path applies" is in tension with the claim's own API 28 caveat. On API 28 and below the renderer is Skia, not Impeller — so the GPU fast path does NOT apply there. I found no primary source establishing what RSuperellipse costs on the Skia/Android path (the documented perf problem is specifically the Web Bezier-path implementation). If the project supports API 28, that gap is unresolved and should be measured, not assumed. Note also that #171830 is evidence the Flutter team itself judged RSuperellipse expensive enough to be worth avoiding on small shapes — on Web, but it undercuts "the old workarounds are obsolete" as a blanket statement.

The "obsolete" framing is slightly stronger than RydMike supports — he recommends RoundedSuperellipseBorder unreservedly for shape correctness, and flags figma_squircle perf as something that "should be studied further" rather than as settled. But for an Android-first, API 29+, Impeller target, the practical conclusion stands.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "beauty-without-motion" made this claim, and a design decision depends on it.

CLAIM: Flutter shipped a true Apple-grade squircle in 3.32 stable (May 20, 2025): RoundedSuperellipseBorder, ClipRSuperellipse, Canvas.drawRSuperellipse, with a GPU implementation in Impeller. The old workarounds are obsolete.
DETAIL: Prior to 3.32 the options were all compromised: ContinuousRectangleBorder needs its radius multiplied by 2.3529 to approximate iOS (derived from 24dp ≈ iOS 10.2dp radius, 24/10.2 = 2.3529) and still degenerates into a 'TIE-fighter' shape at higher radii — and the multiplier makes the degeneration happen EARLIER. figma_squircle matches iOS at smoothing 0.6 but has documented jank/perf complaints. smooth_corner has no perf feedback because nobody uses it. RydMike's squircle_study concludes RoundedSuperellipseBorder is the only shape that matches iOS and handles all edge cases. Caveat that does NOT apply here: RSuperellipse falls back to RRect on Web because it must be drawn as Bezier paths there; flutter/flutter PR #167784 reverted several Cupertino widgets to RRect for Web cost. This project is Android-first with Impeller, so the fast path applies. Second caveat: Impeller is default only on Android API 29+; API 28 and below use legacy Skia (since 3.29.3).
CLAIMED SOURCES: https://github.com/rydmike/squircle_study/blob/master/README.md, https://api.flutter.dev/flutter/painting/RoundedSuperellipseBorder-class.html, https://docs.flutter.dev/release/release-notes/release-notes-3.32.0, https://github.com/flutter/flutter/issues/91523, https://github.com/flutter/flutter/pull/167784
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
