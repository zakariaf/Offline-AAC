# beauty-without-motion--backdropfilter-is-the-single-most-expensive

> Phase: **verify** · Agent `af8440c47933acc4c` · Run `wf_f237e8a6-694`

## Result

## Verdict

**PARTIALLY_TRUE**  (refuted)

**Correction:** Directionally defensible conclusion, wrong evidence and wrong ordering.

DEFENSIBLE: BackdropFilter is genuinely expensive ("relatively expensive, especially if the filter is non-local, such as a blur" — api.flutter.dev). ImageFiltered is officially cheaper for single-widget filtering. Pre-rendered blurred PNG behind translucent fill is ~free for a static backdrop. For an AAC app premised on instant speech, avoiding runtime blur is reasonable engineering.

MUST BE CORRECTED:
1. Drop "single most expensive widget Flutter ships" — unsupported superlative; Flutter's own perf guidance never mentions BackdropFilter and names saveLayer() as the expensive operation.
2. Stop citing #126353/#149368 as current — both closed as FIXED (2023-05-22, 2024-10-22). #126353 is iOS/iPhone 12/Flutter 3.7.10, not mid-tier Android.
3. Remove #161297 entirely — closed as no-repro for reporter silence; it is not evidence of anything.
4. Drop the vs-Skia argument — Skia is gone from iOS (3.27+); there is no Skia baseline to regress against in 2026.
5. Acknowledge BackdropGroup/BackdropFilter.grouped (3.35+), which collapses multiple blurs into one engine operation and directly addresses the cited multi-blur regression.
6. Label 6-9ms @ sigma 20 as unmeasured estimate, not a finding. If latency is load-bearing, measure it on target hardware on 3.44.0.

REORDER: Lead with accessibility. Contrast over arbitrary content is non-certifiable by construction and no engine release will fix it — that argument alone carries a ban for an AAC app and does not decay. Latency is the weaker, staler, version-dependent argument and should be supporting, not primary.

Recommended ban still lands; the reasoning must be rebuilt on the accessibility argument plus a fresh measurement, not on three closed issues and a dead renderer comparison.

**Evidence:** CITATION ROT — all three perf issues are CLOSED, quoted as if live:

#126353: Real; numbers quoted VERBATIM CORRECTLY (Impeller 16ms avg/24ms max vs Skia 6ms avg/5ms max). But it is iOS/iPhone 12/Flutter 3.7.10 — NOT "mid-tier Android" as the claim frames it. Closed 2023-05-22 COMPLETED, bdero: "perf is significantly improved for this case in the master channel, so I'll close this as completed." Fixed by engine PR #42039. Three years stale.

#149368: Real; closed 2024-10-22 COMPLETED, jonahwilliams: "The performance spikes appear to have been fixed."

#161297: WORST FAILURE. Closed NOT as fixed but as NO-REPRO by github-actions bot 2025-01-29: "Without additional information, we are unfortunately not sure how to resolve this issue." Carried `waiting for response` label; reporter never supplied traces or repro. It documents NOTHING. The claim attributes a finding ("iOS issues vanish when Impeller is disabled") to an unreproduced report auto-closed for silence.

VS-SKIA FRAME IS MOOT IN 2026: Skia removed from iOS entirely as of 3.27+; FLTEnableImpeller opt-out no longer works (docs.flutter.dev/perf/impeller: Impeller is "the only supported" engine on iOS with "no ability to switch to Skia"). "Impeller regressed vs Skia" cannot inform a decision when there is no Skia. The remediation #161297 implies is unavailable on the platform it concerns.

MISSING API: BackdropGroup / BackdropFilter.grouped / BackdropKey exist (Flutter 3.35+). api.flutter.dev: multiple filters sharing a BackdropKey are "combined into a single rendering operation by the Flutter engine"; this "can significantly reduce the overhead of using multiple backdrop filters in a scene." Directly dissolves #126353's five-blurs-in-a-ListView case. Also #156455 ("multiple blur effects... Impeller performs worse than Skia") closed COMPLETED 2025-03-28.

SUPERLATIVE UNSUPPORTED: docs.flutter.dev/perf/best-practices does not mention BackdropFilter AT ALL. It names saveLayer() as the expensive operation (ShaderMask, ColorFilter, Chip, Text w/ overflowShader as triggers), opacity and clipping secondary. api.flutter.dev says only "This effect is relatively expensive, especially if the filter is non-local, such as a blur." That is not "the single most expensive widget Flutter ships."

6-9ms @ sigma 20: no methodology; claim itself concedes "not measured here." This is the load-bearing latency premise and it is unsourced.

WHAT SURVIVES: ImageFiltered cheaper — CONFIRMED VERBATIM: "If all you want to do is apply an ImageFilter to a single widget... use ImageFiltered instead. For that scenario, ImageFiltered is both easier to use and less expensive than BackdropFilter." Pre-baked blurred PNG advice sound. Contrast non-determinism sound and untouched.

STRUCTURAL ERROR: Claim insists on latency "before the accessibility argument" — but latency is the part that rotted (2023 engine) and contrast is the part that cannot rot. Arguments ranked in reverse order of durability.

MISSED LIVE ISSUE: #188971, opened 2026-07-04 (11 days ago), OPEN: "BackdropFilter blur ignores ClipOval when a UiKitView is in the tree (Impeller, iOS, regression persists in 3.44.4)." Live BackdropFilter bugs exist — correctness, not the perf bugs cited.

---

<details>
<summary>The prompt that produced this (reusable — this is the template)</summary>

````
You are an ADVERSARIAL FACT-CHECKER for a design-system research corpus. Today is **2026-07-15**. Flutter stable is 3.44.0.

A researcher studying "beauty-without-motion" made this claim, and a design decision depends on it.

CLAIM: BackdropFilter is the single most expensive widget Flutter ships and must be banned outright in this app — on latency grounds alone, before the accessibility argument.
DETAIL: Reported cost: a single full-width BackdropFilter at sigma 20 costs roughly 6–9ms of raster on mid-tier Android (treat the exact number as indicative, not measured here). Impeller specifically regressed vs Skia on blur: flutter/flutter #126353 documents raster thread 16ms avg / 24ms max on Impeller vs 6ms avg / 5ms max on Skia for multiple blurred widgets; #149368 documents Impeller blurs being WORSE than Skia when covering only a small screen region; #161297 documents iOS BackdropFilter issues that vanish when Impeller is disabled. In an app whose entire premise is 'tap and it speaks instantly', spending 6–9ms of raster per frame on decoration is indefensible. Separately, translucency over arbitrary content makes text contrast non-deterministic — you cannot certify a contrast ratio against a background you do not control. If a frosted look is ever wanted: pre-render a blurred PNG behind a translucent fill (approximately free when the backdrop is static), or use ImageFiltered (cheaper than BackdropFilter) — but the honest recommendation is don't.
CLAIMED SOURCES: https://github.com/flutter/flutter/issues/126353, https://github.com/flutter/flutter/issues/149368, https://github.com/flutter/flutter/issues/161297, https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html
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
